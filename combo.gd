extends Sprite2D


func combo_frame(count):
	if count == 0:
		frame = 0
	elif count == 1:
		frame = 3
	elif count == 2:
		frame = 2
	elif count >= 3:
		frame = 1
