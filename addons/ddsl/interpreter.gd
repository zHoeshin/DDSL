extends Node

const OP = {
	"infix": {
		"in": "in",
		
		"()": "call",

		"**": "_pow", "*/": "_root",

		"*": "_mul", "/": "_div", "%": "_mod", "//": "_floordiv",

		"+": "_add", "-": "_sub",

		">": "_lt", "<": "_gt", ">=": "_ge", "<=": "_le",
		
		"==": "_eq", "!=": "_ne",
		
		"&&": "_land", "||": "_lor", "^^": "_lxor",
		
		"&": "_and", "^": "_xor", "|": "_or",
	},
	"prefix": {
		"~": "_inv",
		"!": "_not",
		"+": "_pos",
		"-": "_neg",
	},
}




class Reference:
	pass

class Reference1 extends Reference:
	var parent: Variant
	var key1: Variant
	func _init(p, k1):
		parent = p
		key1 = k1
	func getValue():
		return parent[key1]
	func setValue(v):
		parent[key1] = v
	func getMember(key):
		return Reference2.new(parent, key1, key)
class Reference2 extends Reference:
	var parent: Variant
	var key1: Variant
	var key2: Variant
	func _init(p, k1, k2):
		parent = p
		key1 = k1
		key2 = k2
	func getValue():
		return parent[key1][key2]
	func setValue(v):
		parent[key1][key2] = v
	func getMember(key):
		return Reference3.new(parent, key1, key2, key)
class Reference3 extends Reference:
	var parent: Variant
	var key1: Variant
	var key2: Variant
	var key3: Variant
	func _init(p, k1, k2, k3):
		parent = p
		key1 = k1
		key2 = k2
		key3 = k3
	func getValue():
		return parent[key1][key2][key3]
	func setValue(v):
		parent[key1][key2][key3] = v
	func getMember(key):
		return Reference3.new(parent[key1], key2, key3, key)


class Alias:
	var name
	var value
	func _init(n, v):
		name = n
		value = v

class Interpreter:
	static var builtins: Dictionary[String, Variant] = {
		"abs": abs, "absf": absf, "absi": absi, "acos": acos, "acosh": acosh,
		"asin": asin, "asinh": asinh, "atan": atan, "atan2": atan2, "atanh": atanh,
		"bytes_to_var": bytes_to_var, "ceil": ceil, "clamp": clamp, "cos": cos,
		"cosh": cosh, "db_to_linear": db_to_linear, "step_decimals": step_decimals, "deg_to_rad": deg_to_rad,
		"ease": ease, "exp": exp, "floor": floor, "fmod": fmod, "fposmod": fposmod,
		"hash": hash, "instance_from_id": instance_from_id, "inverse_lerp": inverse_lerp, "is_equal_approx": is_equal_approx, "is_inf": is_inf,
		"is_instance_valid": is_instance_valid, "is_nan": is_nan, "is_zero_approx": is_zero_approx, "lerp": lerp, "lerp_angle": lerp_angle,
		"linear_to_db": linear_to_db, "load": load, "log": log, "max": max, "min": min,
		"move_toward": move_toward, "nearest_po2": nearest_po2, "posmod": posmod, "pow": pow,
		"print": print, "print_debug": print_debug, "print_stack": print_stack, "rad_to_deg": rad_to_deg, "randf": randf,
		"randf_range": randf_range, "randi": randi, "randi_range": randi_range, "randomize": randomize,
		"round": round, "seed": seed, "sign": sign, "sin": sin, "sinh": sinh,
		"smoothstep": smoothstep, "snapped": snapped, "sqrt": sqrt, "str": str,
		"str_to_var": str_to_var, "tan": tan, "tanh": tanh, "type_exists": type_exists,
		"var_to_bytes": var_to_bytes, "var_to_str": var_to_str, "wrapf": wrapf, "wrapi": wrapi,
		"printerr": printerr, "push_warning": push_warning, "push_error": push_error, "prints": prints,
		"printraw": printraw, "print_rich": print_rich,
		"true": true, "false": false, "null": null,
		"Time": Time,
		"TranslationServer": TranslationServer, "tr": Object.tr,
		"AudioServer": AudioServer,
		"CameraServer": CameraServer,
		"ClassDB": ClassDB,
		"DisplayServer": DisplayServer,
		"EditorInterface": EditorInterface,
		"Engine": Engine,
		"EngineDebugger": EngineDebugger,
		"GDExtensionManager": GDExtensionManager,
		"GDScriptLanguageProtocol": GDScriptLanguageProtocol,
		"Geometry2D": Geometry2D,
		"Geometry3D": Geometry3D,
		"IP": IP,
		"Input": Input,
		"InputMap": InputMap,
		"JavaClassWrapper": JavaClassWrapper,
		"JavaScriptBridge": JavaScriptBridge,
		"Marshalls": Marshalls,
		"NativeMenu": NativeMenu,
		"NavigationMeshGenerator": NavigationMeshGenerator,
		"NavigationServer2D": NavigationServer2D,
		"NavigationServer2DManager": NavigationServer2DManager,
		"NavigationServer3D": NavigationServer3D,
		"NavigationServer3DManager": NavigationServer3DManager,
		"OS": OS,
		"Performance": Performance,
		"PhysicsServer2D": PhysicsServer2D,
		"PhysicsServer2DManager": PhysicsServer2DManager,
		"PhysicsServer3D": PhysicsServer3D,
		"PhysicsServer3DManager": PhysicsServer3DManager,
		"ProjectSettings": ProjectSettings,
		"RenderingServer": RenderingServer,
		"ResourceLoader": ResourceLoader,
		"ResourceSaver": ResourceSaver,
		"ResourceUID": ResourceUID,
		"TextServerManager": TextServerManager,
		"ThemeDB": ThemeDB,
		"WorkerThreadPool": WorkerThreadPool,
		"XRServer": XRServer,
	}
	static var constructors = {
		"bool": func(...args):
			match args.size():
				0: return false
				1: return args[0]
				_: return null
			,
		"int": func(...args):
			match args.size():
				0: return 0
				1: return args[0]
				_: return null
			,
		"float": func(...args):
			match args.size():
				0: return 0.0
				1: return args[0]
				_: return null
			,
		"Variant": func(...args):
			match args.size():
				0: return null
				1: return args[0]
				_: return null
			,
		"String": func(...args):
			match args.size():
				0: return ""
				1: return str(args[0])
				_: return null
			,
		"StringName": func(...args):
			match args.size():
				0: return StringName()
				1: return StringName(args[0])
				_: return null
			,
		"NodePath": func(...args):
			match args.size():
				0: return NodePath()
				1: return NodePath(args[0])
				_: return null
			,
		"Array": func(...args):
			match args.size():
				0: return []
				1: return args[0]
				_: return args
			,
		"Dictionary": func(...args):
			match args.size():
				0: return {}
				1: return args[0]
				_: return null
			,
		"PackedByteArray": func(...args):
			match args.size():
				0: return PackedByteArray()
				1: return PackedByteArray(args[0])
				_: return null
			,
		"PackedInt32Array": func(...args):
			match args.size():
				0: return PackedInt32Array()
				1: return PackedInt32Array(args[0])
				_: return null
			,
		"PackedInt64Array": func(...args):
			match args.size():
				0: return PackedInt64Array()
				1: return PackedInt64Array(args[0])
				_: return null
			,
		"PackedFloat32Array": func(...args):
			match args.size():
				0: return PackedFloat32Array()
				1: return PackedFloat32Array(args[0])
				_: return null
			,
		"PackedFloat64Array": func(...args):
			match args.size():
				0: return PackedFloat64Array()
				1: return PackedFloat64Array(args[0])
				_: return null
			,
		"PackedVector2Array": func(...args):
			match args.size():
				0: return PackedVector2Array()
				1: return PackedVector2Array(args[0])
				_: return null
			,
		"PackedVector3Array": func(...args):
			match args.size():
				0: return PackedVector3Array()
				1: return PackedVector3Array(args[0])
				_: return null
			,
		"PackedVector4Array": func(...args):
			match args.size():
				0: return PackedVector4Array()
				1: return PackedVector4Array(args[0])
				_: return null
			,
		"PackedColorArray": func(...args):
			match args.size():
				0: return PackedColorArray()
				1: return PackedColorArray(args[0])
				_: return null
			,
		"PackedStringArray": func(...args):
			match args.size():
				0: return PackedStringArray()
				1: return PackedStringArray(args[0])
				_: return null
			,
		"Callable": func(...args):
			match args.size():
				0: return Callable()
				1: return Callable(args[0])
				_: return null
			,
		"Signal": func(...args):
			match args.size():
				0: return Signal()
				1: return Signal(args[0])
				_: return null
			,
		"Vector2": func(...args):
			match args.size():
				0: return Vector2(0, 0)
				1: return Vector2(args[0], args[0])
				2: return Vector2(args[0], args[1])
				_: return null
			,
		"Vector2i": func(...args):
			match args.size():
				0: return Vector2i(0, 0)
				1: return Vector2i(args[0], args[0])
				2: return Vector2i(args[0], args[1])
				_: return null
			,
		"Vector3": func(...args):
			match args.size():
				0: return Vector3(0, 0, 0)
				1:
					if typeof(args[0]) == TYPE_VECTOR2:
						return Vector3(args[0].x, args[0].y, 0)
					return Vector3(args[0])
				3: return Vector3(args[0], args[1], args[2])
				_: return null
			,
		"Vector3i": func(...args):
			match args.size():
				0: return Vector3i(0, 0, 0)
				1: return Vector3i(args[0], args[0], args[0])
				3: return Vector3i(args[0], args[1], args[2])
				_: return null
			,
		"Vector4": func(...args):
			match args.size():
				0: return Vector4(0, 0, 0, 0)
				1: return Vector4(args[0], args[0], args[0], args[0])
				4: return Vector4(args[0], args[1], args[2], args[3])
				_: return null
			,
		"Vector4i": func(...args):
			match args.size():
				0: return Vector4i(0, 0, 0, 0)
				1: return Vector4i(args[0], args[0], args[0], args[0])
				4: return Vector4i(args[0], args[1], args[2], args[3])
				_: return null
			,
		"Rect2": func(...args):
			match args.size():
				0: return Rect2(0, 0, 0, 0)
				1: return Rect2(args[0])
				2: return Rect2(args[0], args[1])
				4: return Rect2(args[0], args[1], args[2], args[3])
				_: return null
			,
		"Rect2i": func(...args):
			match args.size():
				0: return Rect2i(0, 0, 0, 0)
				1: return Rect2i(args[0])
				2: return Rect2i(args[0], args[1])
				4: return Rect2i(args[0], args[1], args[2], args[3])
				_: return null
			,
		"AABB": func(...args):
			match args.size():
				0: return AABB(Vector3(0,0,0), Vector3(0,0,0))
				1: return AABB(args[0])
				2: return AABB(args[0], args[1])
				_: return null
			,
		"Transform2D": func(...args):
			match args.size():
				0: return Transform2D()
				1: return Transform2D(args[0])
				2: return Transform2D(args[0], args[1])
				3: return Transform2D(args[0], args[1], args[2])
				4: return Transform2D(args[0], args[1], args[2], args[3])
				_: return null
			,
		"Transform3D": func(...args):
			match args.size():
				0: return Transform3D()
				1: return Transform3D(args[0])
				2: return Transform3D(args[0], args[1])
				4: return Transform3D(args[0], args[1], args[2], args[3])
				_: return null
			,
		"Basis": func(...args):
			match args.size():
				0: return Basis()
				1: return Basis(args[0])
				2: return Basis(args[0], args[1])
				3: return Basis(args[0], args[1], args[2])
				_: return null
			,
		"Projection": func(...args):
			match args.size():
				0: return Projection()
				1: return Projection(args[0])
				4: return Projection(args[0], args[1], args[2], args[3])
				_: return null
			,
		"Quaternion": func(...args):
			match args.size():
				0: return Quaternion(0, 0, 0, 1)
				1: return Quaternion(args[0])
				4: return Quaternion(args[0], args[1], args[2], args[3])
				_: return null
			,
		"Plane": func(...args):
			match args.size():
				0: return Plane(0, 0, 1, 0)
				1: return Plane(args[0])
				2: return Plane(args[0], args[1])
				4: return Plane(args[0], args[1], args[2], args[3])
				_: return null
			,
		"Color": func(...args):
			match args.size():
				0: return Color(0, 0, 0, 1)
				1: return Color(args[0])
				3: return Color(args[0], args[1], args[2])
				4: return Color(args[0], args[1], args[2], args[3])
				_: return null
			,
		"RID": func(...args):
			match args.size():
				0: return RID()
				1: return RID(args[0])
				_: return null
			,
	}
	
	var variables: Dictionary = {}
	var labels: Dictionary = {}
	var labelsstack: Array[Dictionary] = []
	var ci: int = 0
	var cistack: Array[int] = []
	
	func _init(vars: Dictionary):
		variables = vars
		labels = {}
		ci = 0
	
	func handleMessage(r: Dialog.Message):
		if r.type == "goto":
			if r.data in labels:
				ci = labels[r.data]
			else:
				return r
	
	func start(ast: Array[Dialog.ASTNode]):
		cistack.push_back(ci)
		labelsstack.push_back(labels)
		ci = 0
		labels = {}
		while ci < len(ast):
			var node = ast[ci]
			ci += 1
			if node.type == "label":
				labels[await evaluate(node.value, true, null)] = ci
		ci = 0
		while ci < len(ast):
			var node = ast[ci]
			ci += 1
			match node.type:
				"if":
					for cond_body in node.value:
						if cond_body[0] == null:
							var r = await start(cond_body[1])
							ci = cistack.pop_back()
							labels = labelsstack.pop_back()
							if r != null:
								var r2 = handleMessage(r)
								if r2 != null:
									return r2
							break
						var v = await evaluate(cond_body[0], true, null)
						if v is Object and v.has_method("_to_bool"):
							v = v._to_bool()
						if v:
							var r = await start(cond_body[1])
							ci = cistack.pop_back()
							labels = labelsstack.pop_back()
							if r != null:
								var r2 = handleMessage(r)
								if r2 != null:
									return r2
							break
				"match":
					var matchee = await evaluate(node.value["match"], true, null)
					var matched = false
					for case_body in node.value["braches"]:
						if case_body[0] == null:
							#await start(case_body[1])
							#break
							continue
						elif await evaluate(case_body[0], true, null) == matchee:
							var r = await start(case_body[1])
							ci = cistack.pop_back()
							labels = labelsstack.pop_back()
							if r != null:
								var r2 = handleMessage(r)
								if r2 != null:
									return r2
							matched = true
							break
					if not matched:
						var r = await start(node.value["default"])
						ci = cistack.pop_back()
						labels = labelsstack.pop_back()
						if r != null:
							var r2 = handleMessage(r)
							if r2 != null:
								return r2
				"expr":
					if node.value.type == "infixop" and node.value.subtype == ":":
						await evaluate(node.value, true, null)
					elif node.value.type == "goto":
						var l = await evaluate(node.value.value, true, null)
						if l == null:
							pass
						if l in labels:
							print(labels[l])
							ci = labels[l]
						else:
							return Dialog.Message.new("goto", l)
					else:
						evaluate(node.value, true, null)
				"input":
					var assignee
					if node.value["var"] == null:
						assignee = null
					else:
						assignee = await evaluate(node.value["var"].value, false, null)
					var cases = []
					var bodies = []
					for branch in node.value["branches"]:
						var case = await evaluate(branch[0].value, true, null)
						if case == null: continue
						cases.append(case)
						bodies.append(branch[1])
					var options = await evaluate(node.value["options"], true, null)
					if options == null: options = {}
					Dialog.currentBox.input(await evaluate(node.value["option"].value, true, null), cases, options)
					var value = await Dialog.currentBox.inputComplete
					if assignee == null:
						pass
					elif assignee is Reference:
						assignee.setValue(value)
					else:
						push_error("Trying to assign to a value " + str(assignee) + " at " + str(node.y + 1) + ":" + str(node.x + 1))
					var i = 0
					var matched = false
					while i < len(cases):
						if cases[i] == value:
							if len(bodies[i]) == 0:
								matched = true
								break
							var r = await start(bodies[i])
							ci = cistack.pop_back()
							labels = labelsstack.pop_back()
							if r != null:
								var r2 = handleMessage(r)
								if r2 != null:
									return r2
							matched = true
							break
						i += 1
					if not matched:
						var r = await start(node.value["default"])
						ci = cistack.pop_back()
						labels = labelsstack.pop_back()
						if r != null:
							var r2 = handleMessage(r)
							if r2 != null:
								return r2
				"output":
					var sprite = await evaluate(node.value["sprite"], true, null)
					var text = await evaluate(node.value["text"], true, null)
					var options = await evaluate(node.value["options"], true, null)
					if options == null: options = {}
					Dialog.currentBox.show()
					Dialog.currentBox.output(sprite, str(text), options)
					await Dialog.currentBox.outputComplete
					continue
				"box":
					var box = await evaluate(node.value, true, null)
					if box is not DialogBox:
						push_error("Dialog style must be a DialogBox got " + str(box) + " at " + str(node.y + 1) + ":" + str(node.x + 1))
					Dialog.setBox(box)
	
	func evaluate(expr: Dialog.ASTNode, isValue: bool, _def: Variant, canTuple: bool = false) -> Variant:
		if expr == null:
			return null
		#print(expr.dump())
		match expr.type:
			"output":
				var sprite = await evaluate(expr.value["sprite"], true, null)
				var text = await evaluate(expr.value["text"], true, null)
				var options = await evaluate(expr.value["options"], true, null)
				if options == null: options = {}
				Dialog.currentBox.show()
				Dialog.currentBox.output(sprite, str(text), options)
				await Dialog.currentBox.outputComplete
				return text
			"infixop":
				var op = expr.subtype
				if op == "as":
					return Alias.new(
						await evaluate(expr.value[1], isValue, _def),
						await evaluate(expr.value[0], isValue, _def),
					)
				if op == ":":
					var sprite = await evaluate(expr.value[0], isValue, _def)
					var text = await evaluate(expr.value[1], isValue, _def)
					Dialog.currentBox.show()
					Dialog.currentBox.output(sprite, str(text), {})
					await Dialog.currentBox.outputComplete
					return text
				if op == "." or op == "[]":
					if isValue:
						return (await evaluate(expr.value[0], isValue, _def))[
							await evaluate(expr.value[1], isValue, _def)
						]
					else:
						return getMember(
							await evaluate(expr.value[0], isValue, _def),
							await evaluate(expr.value[1], isValue, _def)
						)
				if op == "()":
					var callable = await evaluate(expr.value[0], true, _def)
					var args = await evaluate(expr.value[1], true, _def, true)
					#if callable is Object and callable.has_method("callv"):
					if callable is Object and callable.has_method("_call"):
						return callable._call.callv(args)
					var result =  (callable).callv(args)
					return result
					#return null
				if op == "?!":
					var value = await evaluate(expr.value[0], true, _def)
					if value != null:
						return value
					return await evaluate(expr.value[1], true, _def)
				if op == "?":
					var cond = await evaluate(expr.value[1], true, _def)
					if cond:
						return await evaluate(expr.value[0], true, _def)
					return null
				if op == "?_":
					var value = await evaluate(expr.value[0], true, _def)
					var cond = await evaluate(expr.value[1], true, value)
					if cond:
						return value
					return null
				var a = await evaluate(expr.value[0], true, _def)
				var b = await evaluate(expr.value[1], true, _def)
				var opid = OP["infix"].get(op)
				#if opid == null: return null
				if a is Object and a.has_method(opid):
					return a.callv(opid, [b])
				if b is Object and b.has_method(opid + "_r"):
					return b.callv(opid + "_r", [a])
				match op:
					"in": return a in b
					"**": return a ** b
					"*/": return a ** (1.0 / b)
					"*": return a * b
					"/":
						if typeof(a) == TYPE_INT and typeof(b) == TYPE_INT:
							return float(a) / float(b)
						return a / b
					"%": return a % b
					"//": return floor(a / b)
					"+": return a + b
					"-": return a - b
					">": return a > b
					"<": return a < b
					">=": return a >= b
					"<=": return a <= b
					"==": return a == b
					"!=": return a != b
					"&&":
						var bool_a = a._to_bool() if a is Object and a.has_method("_to_bool") else a
						var bool_b = b._to_bool() if b is Object and b.has_method("_to_bool") else b 
						return bool_a && bool_b
					"||":
						var bool_a = a._to_bool() if a is Object and a.has_method("_to_bool") else a
						var bool_b = b._to_bool() if b is Object and b.has_method("_to_bool") else b 
						return bool_a || bool_b
					"^^":
						var bool_a = a._to_bool() if a is Object and a.has_method("_to_bool") else a
						var bool_b = b._to_bool() if b is Object and b.has_method("_to_bool") else b 
						return bool(bool_a) != bool(bool_b)
					"&": return a & b
					"^": return a ^ b
					"|": return a | b
				
			"prefixop":
				var op = expr.subtype
				if op == "await":
					return await evaluate(expr.value, true, _def)
				var v = await evaluate(expr.value, true, _def)
				if v is Object and v.has_method(OP["prefix"][op]):
					return v.call(OP["prefix"][op])
				match op:
					"+": return +v
					"-": return -v
					"~": return ~v
					"!": return !v
			"assign":
				var assignee = await evaluate(expr.value[0], false, _def)
				var value = await evaluate(expr.value[1], true, _def)
				if assignee is Reference:
					assignee.setValue(value)
				else:
					push_error("Trying to assign to a value " + str(assignee) + " at " + str(expr.y + 1) + ":" + str(expr.x + 1))
				return value
			"array":
				var a = []
				for t in expr.value:
					a.append(await evaluate(t, true, _def))
				return a
			"tuple":
				var a = []
				for t in expr.value:
					a.append(await evaluate(t, true, _def))
				if canTuple:
					return a
				else:
					if len(a) == 1:
						return a[0]
					return a
			"dict":
				var d = {}
				for pair in expr.value:
					if pair.type == "assign":
						d[await evaluate(pair.value[0], true, _def)] = \
						await evaluate(pair.value[1], true, _def)
					else:
						d[await evaluate(pair, true, _def)] = await evaluate(pair, true, _def)
				return d
			
			"numdec":
				return expr.value
			"numint":
				return expr.value
			"string":
				#return expr.value
				return await evaluateString(expr.value)
			"trstring":
				return await evaluateString(tr(
					await evaluateString(expr.value)
				))
			"varid", "varfile":
				var name = expr.value
				var source = null
				var overridable = true
				if name in variables:
					source = variables
				elif name in Dialog._globals:
					source = Dialog._globals
					overridable = false
				elif name in builtins:
					source = builtins
					overridable = false
				elif name in constructors:
					source = constructors
					overridable = false
				if isValue or not overridable:
					if source == null:
						if _def != null and name == "_":
							return _def
						else:
							source = variables
					return source.get(name, null)
				else:
					if source == null: source = variables
					return Reference1.new(source, name)
			"varglobal":
				if isValue:
					return Dialog.getGlobal(expr.value)
				else:
					return Reference1.new(Dialog._globals, expr.value)
			"varpath", "varpathstr":
				var resource = load(expr.value)
				if resource is PackedScene:
					resource = resource.instantiate()
				elif resource is Script:
					return resource.new()
				return resource
			
		return null
		
	func evaluateString(s: String):
		const escaped = {
			"a": "\a",
			"b": "\b",
			"f": "\f",
			"n": "\n",
			"r": "\r",
			"t": "\t",
			"v": "\v",
		}
		var output = ""
		var i = 0
		var L = len(s)
		while i < L:
			var c = s[i]
			if c == "\\":
				if i + 1 < L:
					i += 1
					output += escaped.get(s[i], s[i])
				else:
					output += c
			elif c == "{":
				var start = i
				var j = i + 1
				var brcount = 1
				while brcount > 0 and j < L:
					var char = s[j]
					if char == "{":
						brcount += 1
					elif char == "}":
						brcount -= 1
					j += 1
				var end = j
				var exprs = s.substr(start + 1, end - start - 2)
				var e = Dialog._exprparser.call(
					Dialog._tokenize.call(exprs)
				)
				var v = await evaluate(e, true, null)
				output += str(v)
				i = j - 1
			else:
				output += c
			i += 1
		return output
	
	func unwrapValue(a):
		if a is Reference:
			return a.getValue()
		return a
	func getMember(a, k):
		if a is Reference:
			return a.getMember(k)
		return Reference1.new(a, k)
