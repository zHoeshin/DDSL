@tool

static func regex(string):
	var r = RegEx.new()
	r.compile(string)
	return r

static var tokenspecs = [
	[regex(r"#[^\n]*"), "comment", 0, null],
	#[regex(r"\d\w+"), "id", -1, null],
	[regex(r"((?<=\n)|^)[ \t\h]*"), "ident", -1, null],
	[regex(r"\d+\.\d+"), "numdec", -1, func(n: String): return float(n)],
	[regex(r"\d+"), "numint", -1, func(n: String): return int(n)],
	[regex(r"""(["'])(?:(?=(\\?))\2.|[^\1\\])*?\1"""), "string", -1, func(s: String): return s.substr(1, len(s) - 2).c_unescape()],
	[regex(r"\b(in|await)\b"), "op", -1, null],
	[regex(r"[\p{L}_][\p{L}\p{N}_]*"), "varid", -1, null],
	[regex(r"@[\p{L}\p{N}_]+"), "vartemp", -1, func(s: String): return s.substr(0, len(s))],
	[regex(r"\$[\p{L}\p{N}_]+"), "varfile", -1, func(s: String): return s.substr(0, len(s))],
	[regex(r"%[\p{L}\p{N}_]+"), "varglobal", -1, func(s: String): return s.substr(0, len(s))],
	[regex(r"\^[\p{L}\p{N}\/\\:._\-+=]+"), "varpath", -1, func(s: String): return s.substr(1, len(s))],
	[regex(r"""\^(["'])(?:(?=(\\?))\2.|[^\1\\])*?\1"""), "varpathstr", -1, func(s: String): return s.substr(2, len(s) - 3)],
	[regex(r"((\bawait\b)|\|->|<-\||--|->|\+|\/|-|<=|<-|:|,|\.|>=|&|\||\^|==|!=|>|<|=|\*\*|\?\!|\?|\/\/|\*\/|\*|\/|;|%)"), "op", -1, null],
	[regex(r"[\(\)\[\]\{\}]"), "bracket", -1, null],
	[regex("r\n"), "newline", -1, null],
	[regex(r"[\s\r \t\0]*"), "ws", 0, null],
	[regex(r".+"), "unknown", 0, null]
]
const brackets = {
	"}": "{", "]": "[", ")": "(", "dent": "ident",
	"{": "}", "[": "]", "(": ")", "ident": "dent",
}

static func tokenize(r: String, flags: Array[bool] = [true]) -> Array[Dialog.ASTNode]:
	if len(r) <= 0: return []
	var tokens: Array[Dialog.ASTNode] = []
	var i = 0
	var x = 0
	var y = 0
	while i < len(r):
		#if dodebugprint: print(i, " > ", r[i], " < ", r[i].unicode_at(0))
		var success = false
		if r[i] == "\r":
			i += 1
			continue
		if r[i] == "\n":
			tokens.append(Dialog.ASTNode.new("newline", "\n", x, y, i))
			i += 1
			y += 1
			x = 0
			continue
		if r[i] == "\r":
			i += 1
			continue
		for spec in tokenspecs:
			var regex: RegEx = spec[0]
			var type = spec[1]
			var flag = spec[2]
			var matched = regex.search(r, i)
			#if matched != null: if dodebugprint: prints(regex.get_pattern(), matched.get_string(), matched.get_start())
			if matched == null: continue
			if matched.get_start() != i: continue
			var matchlen = matched.get_end() - matched.get_start()
			if matchlen <= 0: continue
			var sx = x; var sy = y; var si = i
			i += matchlen
			x += matchlen
			var s = matched.get_string()
			var n = s.count("\n")
			if n > 0:
				y += n
				var ls = s.rsplit("\n", true, 1)
				x = len(ls[-1])
				#if dodebugprint: print(s, n)
			success = true
			#if dodebugprint: prints(matched.get_string())
			if flag != -1: if flags[flag]:
				break
			if type == null:
				break
			#if dodebugprint: prints("matched", type, matched.get_string())
			#if dodebugprint: prints(type, matched.get_string())
			var processor = spec[3]
			if processor == null:
				tokens.append(Dialog.ASTNode.new(type, s, sx, sy, si))
			else:
				tokens.append(Dialog.ASTNode.new(type, processor.call(s), sx, sy, si))
			#tokens.append({value = s, pos = [sx, sy, si], type = type})
			break
		#if dodebugprint: print(success)
		if !success:
			return tokens + ["Unknown symbol", r[i], r[i].unicode_at(0), "at", x, y, "(", i, ")"]
	return tokens
