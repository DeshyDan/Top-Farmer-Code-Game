extends GutTest

const WIDTH:int = 5
const HEIGHT:int = 5
var farm_model:FarmModel


func before_each():
	farm_model = FarmModel.new(WIDTH, HEIGHT)

func test_empty_when_no_farm_item():
	assert_eq(farm_model.is_empty(Vector2i(0,0)), true)

func test_empty_when_there_is_farm_item():
	farm_model.add_farm_item(FarmItem.new(0,0), Vector2i(0,0))
	assert_eq(farm_model.is_empty(Vector2i(0,0)), false)

func test_add_farm_tem():
	farm_model.add_farm_item(FarmItem.new(0,0), Vector2i(0,0))
func test_height():
	assert_eq(farm_model.get_height(), HEIGHT)

func test_get_width():
	assert_eq(farm_model.get_width(), WIDTH)
