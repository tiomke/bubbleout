extends Sprite2D
@onready var sfx_full_energy = $full_energy


func combo_frame(count):
	if count == 0:
		frame = 0
	elif count == 1:
		frame = 3
	elif count == 2:
		frame = 2
	elif count >= 3:
		if count == 3:
			sfx_full_energy.play()
		frame = 1
