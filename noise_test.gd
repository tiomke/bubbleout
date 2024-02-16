extends Node2D

@onready var bubble = $Bubble

var _noise = FastNoiseLite.new()

var ypos = 0
var speed = 200

func _ready():
	randomize()
	# Configure the FastNoiseLite instance.
	_noise.noise_type = FastNoiseLite.NoiseType.TYPE_PERLIN # 柏林噪声
	_noise.seed = randi() # 添加种子
	_noise.fractal_octaves = 1 # 数字越大，曲线细节越多
	_noise.frequency = 1.0 / 100.0 # 后面的20 是晶格的间距，值越大，晶格间距越大。
	
	# 居中显示
	ypos = get_viewport_rect().size.y/2
	bubble.position.x = 20

# 处理泡泡的移动
func _process(delta):
	bubble.position.x += speed*delta
	bubble.position.y = _noise.get_noise_1d(bubble.position.x/2)*200 + ypos # 这里除以2和乘以200都是曲线的缩放参数

# 绘制曲线
func _draw():
	for i in 1000:
		var height = get_viewport_rect().size.y
		var x = i
		var y = _noise.get_noise_1d(i)*300 + height/2
		draw_rect(Rect2(x*2,y,5,5),Color(1,0,0))
