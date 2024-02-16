extends Node2D

# 配置项
@export var color:Color
@export var radius:int
@export var speed:int

var _color:Color

# 引用项
@onready var collision_shape_2d:CollisionShape2D = $Area2D/CollisionShape2D

# 手势相关标记
var is_mouse_in_shape:=false
var is_triggered := false

# 随机移动
var random:RandomNumberGenerator
var safe_dist = Vector2.ZERO
var wave_noise := FastNoiseLite.new()

# 导出的变量，也要在 ready 后才生效
func _ready():
	# 独立的随机数生成器
	random = RandomNumberGenerator.new()
	random.randomize()
	init_wave_move(position)
	
	
	prints("_ready rand",random.randf())
	var shape = CircleShape2D.new()
	shape.radius = radius
	collision_shape_2d.shape = shape
	reset_state()
	safe_dist = Vector2(radius,radius)
	
	prints("_ready color",color.r,color.g,color.b,get_path())
	#print("_ready>>",radius,";",shape.radius,";",get_path(),shape)
	
func _enter_tree():
	BubbleCtrl.add_bubble(self)
	prints(get_path(),"_enter_tree")
func _exit_tree():
	BubbleCtrl.remove_bubble(self)
	prints(get_path(),"_exit_tree")
	
func _draw():
	prints("_draw",_color.r,_color.g,_color.b,get_path())
	draw_circle(Vector2.ZERO, radius, _color)

func clear_chain_info():
	is_triggered = false
	reset_state()
	
func join_chain():
	is_triggered = true
	_color = Color(0,1,0)
	queue_redraw()
	BubbleCtrl.add_chain_bubble(self)
	
func reset_state():
	_color = color
	queue_redraw()
	
func _on_area_2d_mouse_entered():
	var shape:CircleShape2D = collision_shape_2d.shape
	shape.radius = radius
	#prints("change radius",get_path(),radius)
	is_mouse_in_shape = true
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not is_triggered:
		join_chain()
		#print("_on_area_2d_mouse_entered")


func _on_area_2d_mouse_exited():
	is_mouse_in_shape = false


func _on_area_2d_input_event(viewport, event, shape_idx):
	if is_mouse_in_shape and not is_triggered:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			join_chain()
			
func _process(delta):
	position = step_wave_move(delta)
	#position = new_pos.clamp(safe_dist, get_viewport_rect().size-safe_dist)

#region random wave move
var _wave_init_pos:Vector2
var _wave_pos:=Vector2.ZERO
var _wave_x_scale=0.5 #值越大，采样间距越大
var _wave_y_scale=200 #值越大，浮动范围越大

func init_wave_move(init_pos): # x,y 为泡泡的初始位置
	wave_noise.seed = random.randi()
	wave_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	wave_noise.fractal_octaves = 1
	wave_noise.frequency = 1.0 / 100.0 # 后面的20 是晶格的间距，值越大，晶格间距越大
	_wave_init_pos = init_pos
	
func step_wave_move(delta):
	_wave_pos.x += speed*delta
	_wave_pos.y = wave_noise.get_noise_1d(_wave_x_scale*_wave_pos.x)*_wave_y_scale
	return _wave_init_pos + _wave_pos
#endregion 

