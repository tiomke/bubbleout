extends Node2D

@export var color:Color
var _color:Color
@export var radius:int
@onready var collision_shape_2d:CollisionShape2D = $Area2D/CollisionShape2D

var is_mouse_in_shape:=false
var is_triggered = false

# 布朗运动参数
@export var speed = 1.0 # 移动速度
@export var diffusion_coefficient = 10.0 # 扩散系数，影响随机移动幅度
@export var time_step = 0.3 # 每次更新的时间间隔（伪随机步长）
var random
var velocity = Vector2.ZERO
var safe_dist = Vector2.ZERO

func _init():
	prints("_init",_color.r,_color.g,_color.b,get_path())
	prints("_init color",color.r,color.g,color.b,get_path())
	
# 导出的变量，也要在 ready 后才生效
func _ready():
	random = RandomNumberGenerator.new()
	random.randomize()
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
			
var time_gap = 0
func _process(delta):
	time_gap += delta
	if time_gap > time_step:
		move_brownian()
		time_gap = 0
	var new_pos = position + velocity
	position = new_pos.clamp(safe_dist, get_viewport_rect().size-safe_dist)
	
func move_brownian():
	# 计算随机偏移量
	
	var displacement = diffusion_coefficient * random.randf()
	var angle = random.randf()*2*PI
	var step_vector = Vector2(displacement * cos(angle), displacement * sin(angle))
	# 更新位置并限制在屏幕内
	velocity = step_vector
	

