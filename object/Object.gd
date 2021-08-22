extends Spatial

var c_mesh

func set_mesh(pmesh):
	c_mesh = $Mesh
	c_mesh.mesh = pmesh
