extends Node3D

signal cat_arrival
signal sofa_arrival
signal tv_arrival
signal table_arrival


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_cat_texture()
	update_photo_cat_texture()
	$AnimationPlayer.play("camera_idle")


func switch_to_sofa():
	$AnimationPlayer.play("to_sofa")


func sofa_switch_to_cat():
	update_cat_texture()
	$AnimationPlayer.play("sofa_to_cat")

func table_switch_to_cat():
	update_cat_texture()
	$AnimationPlayer.play("table_to_cat")


func tv_switch_to_cat():
	update_cat_texture()
	$AnimationPlayer.play("tv_to_cat")


func switch_to_tv():
	$AnimationPlayer.play("to_tv")


func switch_to_table():
	$AnimationPlayer.play("to_table")


func update_cat_texture():
	var texture_path = "res://assets/3d/materials/" + Global.profile.avatar + ".tres"
	$Cat.set_surface_override_material(0, load(texture_path))


func update_photo_cat_texture():
	var texture_path = "res://assets/3d/materials/" + Global.profile.avatar + ".tres"
	$FotoFrame/PartySubviewport/Party.set_surface_override_material(13, load(texture_path))


func play_idle():
	$AnimationPlayer.play("camera_idle")
