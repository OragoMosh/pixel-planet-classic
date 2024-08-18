class_name Parser extends Node

static func parseCustom (dict: Dictionary):
	var value = dict.get('_type')
	
	if value == 'vector2':
		return Vector2(dict.x, dict.y)
		
	elif value == 'vector2i':
		return Vector2i(dict.x, dict.y)

static func parsedArray (existing: Array):
	var arr = []
	
	for i in existing:
		arr.append(
			Parser.parse(i)
		)
		
	return arr

static func parse (i: Variant):
	if i is Array:
		return parsedArray(i)
		
	elif i is Dictionary:
		if i.has('_type'):
			return parseCustom(i)
			
	return i


static func modArray (existing: Array):
	var arr = []
	
	for i in existing:
		if i is Array: 
			arr.append(
				modArray(i)
			)
		elif i is Dictionary:
			arr.append(
				modDict(i)
			)
		else:
			arr.append(i)
		
	return arr

static func modDict (dict: Dictionary):
	for key in dict:
		var value = dict[key]
		
		if value is Array:
			dict[key] = modArray(value)
			
		elif value is Dictionary:
			if value.has('_type'):
				dict[key] = parseCustom(value)
			
		elif value is Dictionary:
			modDict(dict[key])
			
	return dict
