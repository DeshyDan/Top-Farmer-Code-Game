extends Sprite2D

enum Direction {
	NORTH,
	SOUTH,
	EAST,
	WEST
}

const move_dist = 50

func move(dir: Direction):
	var vec: Vector2
	match dir:
		Direction.NORTH:
			vec = Vector2.UP
		Direction.SOUTH:
			vec = Vector2.DOWN
		Direction.EAST:
			vec = Vector2.RIGHT
		Direction.WEST:
			vec = Vector2.LEFT
	position += vec * move_dist
