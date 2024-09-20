extends GutTest

const WIDTH:int = 5
const HEIGHT:int = 5
var farm_model:FarmModel


func before_each():
	farm_model = FarmModel.new(WIDTH, HEIGHT)

func test_is_empty():
	var coord = Vector2i(0,0)
	assert_true(farm_model.is_empty(coord))
	farm_model.add_farm_item(Obstacle.ROCK(), coord)
	assert_false(farm_model.is_empty(coord))


func test_add_farm_item():
	var farm_items = FarmItem.new(0,0)
	farm_model.add_farm_item(farm_items, Vector2i(1,2))
	
	for i in range(WIDTH * HEIGHT):
		if (i == 7 ):
			assert_eq(farm_model.get_data()[i], farm_items)
			continue
		assert_true(farm_model.get_data()[i].is_empty())
			
func test_farm_dimensions():
	assert_eq(farm_model.get_height(), HEIGHT)
	assert_eq(farm_model.get_width(), WIDTH)

func test_is_harvestable():
	var coord = Vector2i(0,0)

	farm_model.add_farm_item(Plant.new(0,0,0), coord)
	
	assert_false(farm_model.is_harvestable(coord))
	
	farm_model.set_harvestable(coord)
	
	assert_true(farm_model.is_harvestable(coord))

func test_is_obstacle():
	var obstacle_coord = Vector2i(0,0)
	var plant_coord = Vector2i(0,1)
	
	farm_model.add_farm_item(Obstacle.new(0,0,0), obstacle_coord)
	assert_true(farm_model.is_obstacle(Vector2i(0,0)))
	
	farm_model.add_farm_item(Plant.new(0,0,0), plant_coord)
	assert_false(farm_model.is_obstacle(plant_coord))

func test_remove():
	var coord = Vector2i(0,0)
	
	farm_model.add_farm_item(Plant.CORN(), coord)
	
	assert_eq(farm_model.is_empty(coord), false)
	
	farm_model.remove(coord)
	
	assert_eq(farm_model.is_empty(coord), true)

