extends Node2D
# class contains the logic for spawning the pickup animation of a Plant at
# a specified position

@onready var pickup_scene = preload("res://scenes/inventory_system/pickups/pickup.tscn")
var pickup_tween: Tween 

func animate_pickup( init_pos:Vector2i, harvested_plant:Plant):
	var plant = instantiate_pickup( init_pos, harvested_plant)
	
	setup_pickup_tween(plant)
	pickup_tween.play()

func setup_pickup_tween(plant):
	pickup_tween = get_tree().create_tween()
	pickup_tween.set_parallel(true)
	pickup_tween.set_trans(Tween.TRANS_SINE)  
	pickup_tween.set_ease(Tween.EASE_OUT)  
	
	var init_pos = plant.position
	var end_pos = init_pos + Vector2(0, -50) 

	pickup_tween.tween_property(plant, "position", end_pos, 0.4).set_delay(0.3)

	pickup_tween.tween_property(plant, "scale", Vector2(1.2, 1.2), 0.2)
	pickup_tween.tween_property(plant, "scale", Vector2(1, 1), 0.3).set_delay(0.2)

	var random_rotation = randf_range(-0.2, 0.2)
	pickup_tween.tween_property(plant, "rotation", random_rotation, 0.3)
	pickup_tween.tween_property(plant, "rotation", 0, 0.4).set_delay(0.3)

	pickup_tween.tween_property(plant, "modulate:a", 0.0, 0.4).set_delay(0.3)
	pickup_tween.finished.connect(plant.queue_free)
	
func instantiate_pickup(init_pos, harvested_plant:Plant) -> Node:
	var pickup:Node = pickup_scene.instantiate()
	pickup.load_texture(harvested_plant.get_id())
	pickup.position = Vector2(init_pos)*16
	add_child(pickup)
	return pickup
