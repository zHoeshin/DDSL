static func processIdentation(tokens: Array[Dialog.ASTNode]) -> Array[Dialog.ASTNode]:
	var emptyident = Dialog.ASTNode.new("ident", "")
	var output: Array[Dialog.ASTNode] = []#[{"type": "bracket", "value": "ident"}]
	var stack: Array[Dialog.ASTNode] = [emptyident]
	var i: int = 0
	while i < len(tokens):
		var t = tokens[i]
		if t.type not in ["ident", "newline"]:
			output.push_back(t)
			i += 1
			continue
		if t.type == "newline":
			output.push_back(t)
			if not i + 1 < len(tokens): break
			i += 1
			var next = tokens[i]
			if next.type != "ident":
				next = emptyident
				i -= 1
			if len(stack) == 0 or len(next.value) > len(stack[-1].value):
				output.push_back(Dialog.ASTNode.new("bracket", "ident"))
				stack.push_back(next)
			while len(stack) > 0 and len(stack[-1].value) > len(next.value):
				stack.pop_back()
				output.push_back(Dialog.ASTNode.new("bracket", "dent"))
			while len(stack) > 0 and len(stack[-1].value) == len(next.value):
				stack.pop_back()
			stack.push_back(next)
			i += 1
			continue
	while len(stack):
		var check = stack.pop_back()
		#if check.value == "": continue
		output.push_back(Dialog.ASTNode.new("bracket", "dent"))
	return output

static func foldBrackets(tokens: Array[Dialog.ASTNode], insidePhysScope = false) -> Array[Dialog.ASTNode]:
	const OPEN = ["{", "[", "(", "ident"]
	const B = {"(": ")", "[": "]", "{": "}", "}": "{", "]": "[", ")": "(", "ident": "dent", "dent": "ident"}
	
	var L := len(tokens)
	var i = 0
	
	var o: Array[Dialog.ASTNode] = []
	
	while i < L:
		var t = tokens[i]
		if t.type == "newline" and insidePhysScope:
			i += 1
			continue
		if t.type == "bracket":
			if insidePhysScope and (t.value == "ident" or t.value == "dent"):
				i += 1
				continue
			var stack = [t]
			var j = i + 1
			var t2prev = t
			while j < L and len(stack) > 0:
				var t2 = tokens[j]
				if t2.type == "bracket":
					if t2.value in OPEN:
						stack.append(t2)
						j += 1
					else:
						if len(stack) < 1:
							push_error("Bracket never opened at " + str(t2.y + 1) + ":" + str(t2.x + 1))
							return []
						if B[t2.value] != stack[-1].value:
							push_error("Unmatched bracket at " + str(t2.y + 1) + ":" + str(t2.x + 1))
							return []
						
						stack.pop_back()
						if len(stack) == 0:
							break
						j += 1
				else:
					j += 1
			
			while len(stack) > 0:
				var t2 = stack[-1]
				if t2.value == "dent":
					stack.pop_back()
				else:
					push_error("Bracket never closed at " + str(t2.y + 1) + ":" + str(t2.x + 1))
					return []
			var ips = t.value != "ident" or insidePhysScope
			if t.value != "ident" or i + 1 != j:
				o.append(Dialog.ASTNode.new(
					"scope" + t.value + B[t.value], foldBrackets(tokens.slice(i + 1, j), ips) 
				))
			else:
				for tn in tokens.slice(i + 1, j):
					o.append(tn)
			i = j + 1
		else:
			o.append(t)
			i += 1
	
	
	return o

static func skipToNewline(tokens: Array[Dialog.ASTNode], i: int) -> int:
	var L = len(tokens)
	while i < L and tokens[i].type != "newline":
		i += 1
	return i

static func skipNewLines(tokens: Array[Dialog.ASTNode], i: int) -> int:
	var L = len(tokens)
	while i < L and tokens[i].type == "newline": # and tokens[i].type != "scopeidentdent":
		i += 1
	return i

static func parseStandaloneExpression(tokens: Array[Dialog.ASTNode]):
	tokens = processIdentation(tokens)
	tokens = foldBrackets(tokens)
	var pexpr = parseExpression(tokens)
	return pexpr[0]

static func parse(tokens: Array[Dialog.ASTNode]):
	tokens = processIdentation(tokens)
	tokens = foldBrackets(tokens)
	var o: Array[Dialog.ASTNode] = []
	var i = 0
	var L = len(tokens)
	while i < L:
		i = skipNewLines(tokens, i)
		if i >= L:
			break
		var t = tokens[i]
		#push_error(t)
		if t.type == "scope[]":
			var pexpr = parseExpression(t.value)[0]
			if pexpr == null:
				push_error("Expected a box but got nothing at " + str(t.y + 1) + ":" + str(t.x + 1))
				return null
			o.append(Dialog.ASTNode.new(
				"box", pexpr, t.x, t.y, t.offset
			))
			i += 1
			continue
		if t.type == "op" and t.value == "?":
			var branches: Array = []
			var j = i
			while j < L:
				var t2 = tokens[j]
				if t2.type != "op":
					break
				if t2.value == "?":
					j += 1
					var s = j
					j = skipToNewline(tokens, j)
					if j == s:
						push_error("Expected expression after conditional at " + str(t2.y + 1) + ":" + str(t2.x + 1))
						return [] as Array[Dialog.ASTNode]
					var expr = parseExpression(tokens.slice(s, j))[0]
					j = skipNewLines(tokens, j)
					if j >= L:
						push_error("Expected body after conditional at " + str(t2.y + 1) + ":" + str(t2.x + 1))
						return []
					var scope = tokens[j]
					j += 1
					branches.append([expr, parse(scope.value)])
				elif t2.value == "?!":
					j += 1
					j = skipNewLines(tokens, j)
					if j >= L:
						push_error("Expected body after conditional at " + str(t2.y + 1) + ":" + str(t2.x + 1))
						return []
					var scope = tokens[j]
					j += 1
					if scope.type != "scopeidentdent":
						push_error("Expected body after conditional at " + str(t2.y + 1) + ":" + str(t2.x + 1))
						return []
					branches.append([null, parse(scope.value)])
				elif t2.value == ".":
					j += 1
					break
				else:
					break
			i = j
			o.append(Dialog.ASTNode.new(
				"if", branches, t.x, t.y, t.offset
			))
			continue
		
		
		
		var s = i
		i = skipToNewline(tokens, i)
		if s == i:
			continue
		var expr = tokens.slice(s, i)
		if expr[-1].type == "op" and expr[-1].value == ":":
			if len(expr) == 1:
				push_error("Expected value to match at " + str(expr[0].y + 1) + ":" + str(expr[0].x + 1))
				return []
			var thing = expr.slice(0, -1)
			i = skipNewLines(tokens, i)
			var branches = []
			var defaultBranch = null
			var j = i
			while j < L:
				var t2 = tokens[j]
				if t2.type != "op":
					break
				if t2.value == "-":
					j += 1
					var s2 = j
					j = skipToNewline(tokens, j)
					if j == s2:
						push_error("Expected value to match at " + str(t2.y + 1) + ":" + str(t2.x + 1))
						return [] as Array[Dialog.ASTNode]
					var expr3 = Dialog.ASTNode.new(
						"expr", parseExpression(tokens.slice(s2, j))[0], t.x, t.y, t.offset
					)
					j = skipNewLines(tokens, j)
					if j >= L:
						push_error("Expected body for match branch at " + str(t2.y + 1) + ":" + str(t2.x + 1))
						return []
					var scope = tokens[j]
					j += 1
					branches.append([expr3, parse(scope.value)])
				elif t2.value == "--":
					j += 1
					j = skipNewLines(tokens, j)
					if j >= L:
						push_error("Expected body for match branch at " + str(t2.y + 1) + ":" + str(t2.x + 1))
						return []
					var scope = tokens[j]
					j += 1
					if scope.type != "scopeidentdent":
						push_error("Expected body for match branch at " + str(t2.y + 1) + ":" + str(t2.x + 1))
						return []
					#branches.append([null, parse(scope.value)])
					defaultBranch = parse(scope.value)
				else:
					break
			i = j
			o.append(Dialog.ASTNode.new(
				"match", {
					"match": thing,
					"branches": branches,
					"default": defaultBranch
				}, t.x, t.y, t.offset
			))
			continue
			
		var isInput = false
		var arrow = -1
		for token in expr:
			arrow += 1
			if token.type == "op" and token.value == "<-":
				var hasOptions = false
				var options = null
				isInput = true
				var assignee = expr.slice(0, arrow)
				var option = expr.slice(arrow + 1)
				if len(assignee) == 0:
					assignee = null
				else:
					assignee = Dialog.ASTNode.new(
						"expr", parseExpression(assignee)[0], assignee[0].x, assignee[0].y, assignee[0].offset
					)
				if len(option) == 0:
					option = null
				else:
					if option[-1].type == "scope{}":
						options = parseExpression([option[-1]])[0]
						hasOptions = true
						option.pop_back()
					if len(option) == 0:
						option = null
					else:
						option = Dialog.ASTNode.new(
							"expr", parseExpression(option)[0], option[0].x, option[0].y, option[0].offset
						)
				i = skipNewLines(tokens, i)
				var branches = []
				var defaultBranch = null
				var j = i
				while j < L:
					var t2 = tokens[j]
					if not hasOptions and t2.type == "scope{}":
						options = parseExpression([t2])[0]
						hasOptions = true
						j += 1
						j = skipNewLines(tokens, j)
						continue
					elif t2.type != "op":
						break
					if t2.value == "-":
						j += 1
						var s2 = j
						j = skipToNewline(tokens, j)
						if j == s2:
							push_error("Expected expression to match at " + str(t2.y + 1) + ":" + str(t2.x + 1))
							return [] as Array[Dialog.ASTNode]
						var expr3 = Dialog.ASTNode.new(
							"expr", parseExpression(tokens.slice(s2, j))[0], t.x, t.y, t.offset
						)
						j = skipNewLines(tokens, j)
						if j >= L:
							push_error("Expected body for match branch at " + str(t2.y + 1) + ":" + str(t2.x + 1))
							return []
						var scope = tokens[j]
						j += 1
						branches.append([expr3, parse(scope.value)])
					elif t2.value == "--":
						j += 1
						j = skipNewLines(tokens, j)
						if j >= L:
							push_error("Expected body for match branch at " + str(t2.y + 1) + ":" + str(t2.x + 1))
							return []
						var scope = tokens[j]
						j += 1
						if scope.type != "scopeidentdent":
							push_error("Expected body for match branch at " + str(t2.y + 1) + ":" + str(t2.x + 1))
							return []
						#branches.append([null, parse(scope.value)])
						defaultBranch = parse(scope.value)
					else:
						break
				i = j
				o.append(Dialog.ASTNode.new(
					"input", {
						"var": assignee,
						"option": option,
						"branches": branches,
						"default": defaultBranch,
						"options": options
					}, t.x, t.y, t.offset
				))
				continue
		if isInput:
			continue
		
		var pexpr = parseExpression(expr)[0]
		if pexpr != null:
			#print(pexpr.dump())
			if pexpr.type == "output":
				i = skipNewLines(tokens, i)
				if i >= L:
					o.append(pexpr)
				elif tokens[i].type == "scope{}":
					var oexpr = parseExpression([tokens[i]])[0]
					#print(oexpr.dump())
					o.append(Dialog.ASTNode.new(
						"output", {
							"sprite": pexpr.value["sprite"],
							"text": pexpr.value["text"],
							"options": oexpr
						}, t.x, t.y, t.offset
					))
					i += 1
				else:
					o.append(pexpr)
			elif pexpr.type == "label":
				o.append(pexpr)
			else:
				o.append(Dialog.ASTNode.new(
					"expr", pexpr, t.x, t.y, t.offset
				))
			
	return o


const OP = {
	"infixprec": {
		"in": 200,
		
		"()": 260,

		"[]": 260, ".": 260,

		"**": 150, "*/": 150,

		"*": 140, "/": 140, "%": 140, "//": 140,

		"+": 130, "-": 130,

		"..": 40,

		">": 110, "<": 110, ">=": 110, "<=": 110,
		
		"==": 100, "!=": 100,
		
		"&&": 90, "||": 80, "^^": 70,
		
		"&": 106, "^": 105, "|": 104,
		
		":": 03, "{}": 02,
		
		";": 20,
		
		"=": 9,
		
		"->": 05,
		
		",": 02,
		
		"as": 02,
		
		"?": 10, "?!": 10, "?_": 10
	},
	"prefixprec": {
		"await": 260,
		"~": 260,
		"!": 190,
		"+": 260,
		"-": 260,
		"()": 260,
		"[]": 260,
		"{}": 260,
		"|<-": 1,
		"|->": 1,
	},
	"left": ["**", "*/"]
}

static func preprocessExpression(tokens):
	var output = []
	var prevtype = null
	var i = 0
	while i < len(tokens):
		var t = tokens[i]
		if t.type == "scope[]":
			output.push_back(Dialog.ASTNode.new(
				"op", "[]", t.x, t.y, t.offset
			))
			var pexpr = parseExpression(t.value)[0]
			if pexpr == null:
				pexpr = []
			elif pexpr.type == "infixop" and pexpr.subtype == ",":
				pexpr = pexpr.value
			elif pexpr is not Array:
				pexpr = [pexpr]
			output.push_back(Dialog.ASTNode.new(
				"array", pexpr, t.x, t.y, t.offset
			))
		elif t.type == "scope()":
			output.push_back(Dialog.ASTNode.new(
				"op", "()", t.x, t.y, t.offset
			))
			var pexpr = parseExpression(t.value)[0]
			if pexpr == null:
				pexpr = []
			elif pexpr.type == "infixop" and pexpr.subtype == ",":
				pexpr = pexpr.value
			elif pexpr is not Array:
				pexpr = [pexpr]
			output.push_back(Dialog.ASTNode.new(
				"tuple", pexpr, t.x, t.y, t.offset
			))
		elif t.type == "scope{}":
			output.push_back(Dialog.ASTNode.new(
				"op", "{}", t.x, t.y, t.offset
			))
			var pexpr = parseExpression(t.value)[0]
			if pexpr == null:
				pexpr = []
			elif pexpr.type == "infixop" and pexpr.subtype == ",":
				pexpr = pexpr.value
			#elif pexpr is not Array:
				#pexpr = [pexpr]
			output.push_back(Dialog.ASTNode.new(
				"dict", pexpr, t.x, t.y, t.offset
			))
		elif t.type == "scopedentident" or t.type == "scopeidentdent":
			for thing in preprocessExpression(t.value):
				output.push_back(thing)
		elif t.type == "newline":
			i += 1
			continue
		else:
			output.push_back(t)
		prevtype = t.type
		i += 1
	
	return output

static func parseInfix(start, tokens, left, token):
	var i = start
	var precedence = OP.infixprec[token.value]
	var nextprec = precedence - int(token.value in OP.left)
	var _right = parseExpression(tokens, false, i, nextprec)
	var right = _right[0]
	i = _right[1]
	if token.value == "," and right == null:
		return [left, i]
	return [binaryExpr(left, right, token), i]

static func parsePrefix(start, tokens, token):
	var i = start
	if token == null: return [null, i]
	if token.value in OP.prefixprec:
		var _right = parseExpression(tokens, false, i, OP.prefixprec[token.value])
		var right = _right[0]
		i = _right[1]
		return [unaryExpr(right, token), i]
	elif token.type == "expr":
		return [leafExpr(parseExpression(token.value)[0]), i]
	#elif token.type.begins_with("var") or token.type.begins_with("num") or token.type == "thing" or token.type == "string":
		#return [leafExpr(token), i]
	else:
		return [token, i]
		return [null, i]

static func peek(i, arr):
	if i >= len(arr): return null
	return arr[i]

static func parseExpression(tokens: Array, topLevel: bool = true, start: int = 0, precedence = 0):
	tokens = preprocessExpression(tokens)
	if len(tokens) == 0:
		return [null, 0]
	
	#push_error(tokens.map(func(a): return a.dump()))
	
	var i = start
	var t = peek(i, tokens)
	#prints(t, t.x, t.y)
	i += 1
	var _left = parsePrefix(i, tokens, t)
	var left = _left[0]
	i = _left[1]
	
	while i < len(tokens) and tokens[i].type == "op" and precedence < OP.infixprec[tokens[i].value]:
		var op = tokens[i]
		i += 1
		var _i = parseInfix(i, tokens, left, op)
		left = _i[0]
		i = _i[1]
	
	if topLevel and i < len(tokens):
		var et = tokens[i]
		print(str(tokens.slice(i - 1).map(func(a): return a.dump())))
		push_error("Unparsed leftover tokens in expression " + str(tokens.slice(i).map(func(a): return a.dump())) + " at " + str(et.y + 1) + ":" + str(et.x + 1))
	
	return [left, i]

static func parenExpr(right):
	if right.type == "infixop" \
	and right.subtype == ",":
		return Dialog.ASTNode.fromDict({
			"type": "tuple",
			"value": right.value
		})
	else:
		return Dialog.ASTNode.fromDict({
			"type": "tuple",
			"value": [right]
		})

static func unaryExpr(right, op):
	if op.value == "|->":
		return Dialog.ASTNode.new(
			"label",
			right,
			op.x, op.y, op.offset
		)
	if op.value == "|<-":
		return Dialog.ASTNode.new(
			"goto",
			right,
			op.x, op.y, op.offset
		)
	if op.value == "()":
		return parenExpr(right)
	if op.value == "[]":
		if right.type == "infixop" \
		and right.subtype == ",":
			return Dialog.ASTNode.new(
				"array",
				right.value,
				op.x, op.y, op.offset
			)
		else:
			return Dialog.ASTNode.new(
				"array",
				[right],
				op.x, op.y, op.offset
			)
	if op.value == "{}":
		#if right.type == "infixop" and right.subtype == ",":
			#return Dialog.ASTNode.new(
				#"dict", right.value
			#)
		#else:
			#return Dialog.ASTNode.new(
				#"dict", right.value
			#)
		var i = -1
		if right.value is not Array:
			right.value = [right.value]
		for assign in right.value:
			i += 1
			if assign.type != "assign":
				continue
			if assign.value[0].type == "varid":
				assign.value[0] = Dialog.ASTNode.new(
					"string", assign.value[0].value,
					assign.value[0].x,
					assign.value[0].y,
					assign.value[0].offset
				)
		return right
	#push_error(op.dump())
	return Dialog.ASTNode.fromDict({
		"type": "prefixop",
		"subtype": op.value,
		"value": right
	})
	
static func leafExpr(token):
	return token

static func binaryExpr(left, right, op):
	#prints("!!!", left, right, op)
	if left.type == "infixop" \
	and left.subtype == "," \
	and op.value == ",":
		return Dialog.ASTNode.fromDict({
			"type": "infixop",
			"subtype": ",",
			"value": left.value + [right]
		})
	if op.value == "=":
		return Dialog.ASTNode.fromDict({
			"type": "assign",
			"value": [left, right]
		})
	if op.value == "{}":
		if left.type == "output":
			var i = -1
			if right.value is not Array:
				right.value = [right.value]
			for assign in right.value:
				i += 1
				if assign.type != "assign":
					continue
				if assign.value[0].type == "varid":
					assign.value[0] = Dialog.ASTNode.new(
						"string", assign.value[0].value,
						assign.value[0].x,
						assign.value[0].y,
						assign.value[0].offset
					)
			return Dialog.ASTNode.new(
				"output", {
					"sprite": left.value["sprite"],
					"text": left.value["text"],
					"options": right
				}, left.x, left.y, left.offset
			)
		else:
			push_error("Unexpected dictionary literal at " + str(op.y + 1) + ":" + str(op.x + 1))
	if op.value == ":":
		return Dialog.ASTNode.new(
			"output", {
				"sprite": left,
				"text": right,
				"options": null
			}, left.x, left.y, left.offset
		)
	if op.value in ["."] and right.type == "varid":
		right.type = "string"
		return Dialog.ASTNode.fromDict({
			"type": "infixop",
			"subtype": op.value,
			"value": [left, right]
		})
	if op.value == "?":
		return Dialog.ASTNode.fromDict({
			"type": "infixop",
			"subtype": op.value + "_".repeat(int(scanFor_(right))),
			"value": [left, right]
		})
	return Dialog.ASTNode.fromDict({
		"type": "infixop",
		"subtype": op.value,
		"value": [left, right]
	})

static func scanFor_(expr: Dialog.ASTNode) -> bool:
	if expr == null:
		return false
	match expr.type:
		"infixop":
			var op = expr.subtype
			if op == "()":
				return false
			return scanFor_(expr.value[0]) || scanFor_(expr.value[1])
		"prefixop":
			return scanFor_(expr.value)
		"assign":
			return scanFor_(expr.value[0]) || scanFor_(expr.value[1])
		"array":
			for t in expr.value:
				if scanFor_(t): return true
			return false
		"tuple":
			for t in expr.value:
				if scanFor_(t): return true
			return false
		"dict":
			var d = {}
			for pair in expr.value:
				if pair.type == "assign":
					if scanFor_(pair.value[0]) || scanFor_(pair.value[1]):
						return true
				else:
					if scanFor_(pair):
						return true
			return false
		"varid":
			return expr.value == "_"
		_:
			return false
