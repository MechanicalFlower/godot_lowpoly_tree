tool

extends MeshInstance

var _height := 2
var _polygons: Array = []
var _verticies: PoolVector3Array = []
var _surface_tool: SurfaceTool = null
var _noise: OpenSimplexNoise = null


class Polygon:
	var indices: PoolIntArray = []

	func _init(a: int, b: int, c: int):
		indices.push_back(a)
		indices.push_back(b)
		indices.push_back(c)


func _init(height: int) -> void:
	_height = height

	generate_icosphere()
	subdivide_icosphere(2)
	generate_mesh()


func generate_icosphere() -> void:
	var t := (1.0 + sqrt(5.0)) / 2

	_verticies.push_back(Vector3(-1, t, 0).normalized())
	_verticies.push_back(Vector3(1, t, 0).normalized())
	_verticies.push_back(Vector3(-1, -t, 0).normalized())
	_verticies.push_back(Vector3(1, -t, 0).normalized())
	_verticies.push_back(Vector3(0, -1, t).normalized())
	_verticies.push_back(Vector3(0, 1, t).normalized())
	_verticies.push_back(Vector3(0, -1, -t).normalized())
	_verticies.push_back(Vector3(0, 1, -t).normalized())
	_verticies.push_back(Vector3(t, 0, -1).normalized())
	_verticies.push_back(Vector3(t, 0, 1).normalized())
	_verticies.push_back(Vector3(-t, 0, -1).normalized())
	_verticies.push_back(Vector3(-t, 0, 1).normalized())

	_polygons.push_back(Polygon.new(0, 11, 5))
	_polygons.push_back(Polygon.new(0, 5, 1))
	_polygons.push_back(Polygon.new(0, 1, 7))
	_polygons.push_back(Polygon.new(0, 7, 10))
	_polygons.push_back(Polygon.new(0, 10, 11))
	_polygons.push_back(Polygon.new(1, 5, 9))
	_polygons.push_back(Polygon.new(5, 11, 4))
	_polygons.push_back(Polygon.new(11, 10, 2))
	_polygons.push_back(Polygon.new(10, 7, 6))
	_polygons.push_back(Polygon.new(7, 1, 8))
	_polygons.push_back(Polygon.new(3, 9, 4))
	_polygons.push_back(Polygon.new(3, 4, 2))
	_polygons.push_back(Polygon.new(3, 2, 6))
	_polygons.push_back(Polygon.new(3, 6, 8))
	_polygons.push_back(Polygon.new(3, 8, 9))
	_polygons.push_back(Polygon.new(4, 9, 5))
	_polygons.push_back(Polygon.new(2, 4, 11))
	_polygons.push_back(Polygon.new(6, 2, 10))
	_polygons.push_back(Polygon.new(8, 6, 7))
	_polygons.push_back(Polygon.new(9, 8, 1))


func get_mid(cache: Dictionary, index_a: int, index_b: int) -> int:
	var smaller := min(index_a, index_b) as int
	var greater := max(index_a, index_b) as int
	var key := (smaller << 16) + greater

	if cache.has(key):
		return cache.get(key)

	var p1 := _verticies[index_a]
	var p2 := _verticies[index_b]
	var middle := lerp(p1, p2, 0.5).normalized() as Vector3

	var ret := _verticies.size()
	_verticies.push_back(middle)

	cache[key] = ret
	return ret


func subdivide_icosphere(subdivisions: int) -> void:
	var mid_point_cache: Dictionary = {}

	for i in subdivisions:
		var new_poly: Array = []

		for poly in _polygons:
			var a := poly.indices[2] as int
			var b := poly.indices[1] as int
			var c := poly.indices[0] as int

			var ab := get_mid(mid_point_cache, a, b)
			var bc := get_mid(mid_point_cache, b, c)
			var ca := get_mid(mid_point_cache, c, a)

			new_poly.push_back(Polygon.new(a, ab, ca))
			new_poly.push_back(Polygon.new(b, bc, ab))
			new_poly.push_back(Polygon.new(c, ca, bc))
			new_poly.push_back(Polygon.new(ab, bc, ca))

		_polygons = new_poly


func generate_mesh() -> void:
	_noise = OpenSimplexNoise.new()
	_noise.seed = randi()

	_surface_tool = SurfaceTool.new()
	_surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in _polygons.size():
		var poly = _polygons[i]

		for index in poly.indices.size():
			var vertex := _verticies[poly.indices[(poly.indices.size() - 1) - index]] as Vector3

			var normal := vertex.normalized()
			var u := normal.x * _noise.period
			var v := normal.y * _noise.period
			var noise_value := _noise.get_noise_2d(u, v)
			vertex = vertex + ((normal * noise_value) * 0.4)

			_surface_tool.add_vertex(vertex)

	_surface_tool.index()
	_surface_tool.generate_normals()

	self.mesh = _surface_tool.commit()
	self.material_override = generate_random_material()

	self.scale = Vector3(rand_range(0.5, 1.5), rand_range(0.5, 1.5), rand_range(0.5, 1.5))
	self.scale *= rand_range(1, 1.5)
	self.translation += Vector3(0, _height * 0.5, 0)


# genereates a new material with a random color
func generate_random_material() -> SpatialMaterial:
	var material := SpatialMaterial.new()
	material.albedo_color = Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1))
	return material
