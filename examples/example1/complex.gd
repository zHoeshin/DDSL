class Complex:
	var real = 0.0
	var imag = 0.0
	
	func _init(r = 0.0, i = 0.0):
		real = r
		imag = i
	
	func _neg():
		return Complex.new(-real, -imag)
	
	func _pos():
		return Complex.new(real, imag)
	
	func _add(other):
		if other is Complex:
			return Complex.new(real + other.real, imag + other.imag)
		elif typeof(other) in [TYPE_INT, TYPE_FLOAT]:
			return Complex.new(real + other, imag)
		return null
	
	func _sub(other):
		if other is Complex:
			return Complex.new(real - other.real, imag - other.imag)
		elif typeof(other) in [TYPE_INT, TYPE_FLOAT]:
			return Complex.new(real - other, imag)
		return null
	
	func _mul(other):
		if other is Complex:
			return Complex.new(
				real * other.real - imag * other.imag,
				real * other.imag + imag * other.real
			)
		elif typeof(other) in [TYPE_INT, TYPE_FLOAT]:
			return Complex.new(real * other, imag * other)
		return null
	
	func _div(other):
		if other is Complex:
			var denom = other.real * other.real + other.imag * other.imag
			return Complex.new(
				(real * other.real + imag * other.imag) / denom,
				(imag * other.real - real * other.imag) / denom
			)
		elif typeof(other) in [TYPE_INT, TYPE_FLOAT]:
			return Complex.new(real / other, imag / other)
		return null
	
	func _floordiv(other):
		var result = _div(other)
		if result is Complex:
			return Complex.new(floor(result.real), floor(result.imag))
		return null
	
	func _mod(other):
		if imag != 0: return null
		if other is Complex and other.imag == 0:
			return fmod(real, other.real)
		elif typeof(other) in [TYPE_INT, TYPE_FLOAT]:
			return fmod(real, other)
		return null
	
	func _add_r(other): return _add(other)
	func _sub_r(other): return Complex.new(other - real, -imag)
	func _mul_r(other): return _mul(other)
	func _div_r(other):
		if other is Complex:
			return other._truediv(self)
		elif typeof(other) in [TYPE_INT, TYPE_FLOAT]:
			var denom = real*real + imag*imag
			return Complex.new(
				(other * real) / denom,
				(-other * imag) / denom
			)
		return null
	
	func _floordiv_r(other):
		var result = _div(other)
		if result is Complex:
			return Complex.new(floor(result.real), floor(result.imag))
		return null
	
	func _mod_r(other):
		if imag != 0: return null
		if other is Complex and other.imag == 0:
			return fmod(other.real, real)
		elif typeof(other) in [TYPE_INT, TYPE_FLOAT]:
			return fmod(other, real)
		return null
	
	func _eq(other):
		if other is Complex:
			return real == other.real and imag == other.imag
		elif typeof(other) in [TYPE_INT, TYPE_FLOAT]:
			return imag == 0 and real == other
		return null
	
	func _eq_r(other): return _eq(other)
	
	func _ne(other):
		var eq = _eq(other)
		#return null if eq == null else not eq
		if eq == null:
			return null
		return not eq
	
	func _ne_r(other): return _ne(other)
	
	func _lt(other):
		if imag != 0: return null
		if other is Complex and other.imag == 0:
			return real < other.real
		elif typeof(other) in [TYPE_INT, TYPE_FLOAT]:
			return real < other
		return null
	
	func _lt_r(other):
		if imag != 0: return null
		if other is Complex and other.imag == 0:
			return other.real < real
		elif typeof(other) in [TYPE_INT, TYPE_FLOAT]:
			return other < real
		return null
	
	func _gt(other):
		if imag != 0: return null
		if other is Complex and other.imag == 0:
			return real > other.real
		elif typeof(other) in [TYPE_INT, TYPE_FLOAT]:
			return real > other
		return null
	
	func _gt_r(other):
		if imag != 0: return null
		if other is Complex and other.imag == 0:
			return other.real > real
		elif typeof(other) in [TYPE_INT, TYPE_FLOAT]:
			return other > real
		return null
	
	func _le(other):
		if imag != 0: return null
		if other is Complex and other.imag == 0:
			return real <= other.real
		elif typeof(other) in [TYPE_INT, TYPE_FLOAT]:
			return real <= other
		return null
	
	func _le_r(other):
		if imag != 0: return null
		if other is Complex and other.imag == 0:
			return other.real <= real
		elif typeof(other) in [TYPE_INT, TYPE_FLOAT]:
			return other <= real
		return null
	
	func _ge(other):
		if imag != 0: return null
		if other is Complex and other.imag == 0:
			return real >= other.real
		elif typeof(other) in [TYPE_INT, TYPE_FLOAT]:
			return real >= other
		return null
	
	func _ge_r(other):
		if imag != 0: return null
		if other is Complex and other.imag == 0:
			return other.real >= real
		elif typeof(other) in [TYPE_INT, TYPE_FLOAT]:
			return other >= real
		return null
	
	func _pow(exponent):
	# Handle zero to any power (except 0^0)
		if real == 0 and imag == 0:
			if exponent is Complex:
				if exponent.real == 0 and exponent.imag == 0:
					return null # 0^0 is undefined
			elif exponent == 0:
				return null # 0^0 is undefined
			return Complex.new(0, 0) # 0^z = 0 where z ≠ 0
		
		# Get principal logarithm ln(z)
		var log_r = 0.5 * log(real*real + imag*imag)
		var theta = atan2(imag, real)
		
		if exponent is Complex:
			# Complex exponent: z^w = e^(w*ln(z))
			var ln_z = Complex.new(log_r, theta)
			var w_ln_z = exponent._mul(ln_z)
			var e_term = exp(w_ln_z.real)
			return Complex.new(
				e_term * cos(w_ln_z.imag),
				e_term * sin(w_ln_z.imag)
			)
		else:
			# Real exponent: z^r = |z|^r * e^(i*r*θ)
			var new_mag = pow(real*real + imag*imag, exponent * 0.5)
			var new_angle = exponent * theta
			return Complex.new(
				new_mag * cos(new_angle),
				new_mag * sin(new_angle)
			)

	func _root(n):
		# Root is just power of 1/n
		if n is Complex:
			return _pow(Complex.new(1,0)._div(n))
		else:
			return _pow(1.0/n)
		
	func _to_string():
		return str(real) + "+".repeat(int(imag >= 0)) + str(imag) + "i"

func _call(r, i):
	return Complex.new(r, i)
