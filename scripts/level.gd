const Action = preload("action.gd")
const Constants = preload("constants.gd")
const Utils = preload("utils/utils.gd")

signal add_score(addition)

var name = "关卡"
var actions = []
var score = 0
var time = 0
var bgm_stream = null
var bgm_offset = 10.0

var combo = 0
var combo_score = 10
# 最大得分
var _max_score  = 0

func start():
	score = 0
	time = 0
	global.play_background_music(bgm_stream, bgm_offset)

func restart():
	for a in actions:
		a.init_var()
	score = 0
	time = 0
	global.play_background_music(bgm_stream, bgm_offset)

# 游戏进度
func get_progress():
	return float(score) / (float(_max_score) * 0.7)+ 0.1

# 处理心跳
func process(delta, last_btn):
	time = global.get_background_music_position()
	var s = 0
	for a in actions:
		s = a.process(time, last_btn)
		if s > 0:
			score = score + s + combo_score*combo
			combo += 1
			emit_signal("add_score", s)
			break
	if last_btn != 0 and s == 0:
		combo = 0

func load(dict):
	self.name = dict['name']
	self.bgm_stream = load(str("res://assets/bgm/", dict['bgm']['file']))
	if self.bgm_stream != null:
		bgm_stream.loop = false
	self.bgm_offset = Utils.parse_time_expression(dict['bgm']['offset'])
	for ad in dict['actions']:
		var time_key_pair = ad.split(" ")
		if not ad.empty() and time_key_pair.size() == 2:
			var a = Action.new()
			a.time = Utils.parse_time_expression(time_key_pair[0])
			var key_part = time_key_pair[1]
			a.header = key_part.find("H") != -1
			if key_part.find("L") != -1:
				a.key = Constants.btLeft
			elif key_part.find("R") != -1:
				a.key = Constants.btRight
			else:
				printt("关卡按键配置错误：", ad)
				continue
			self._max_score += a.SCORE
			self.actions.append(a)
		else:
			printt("关卡配置错误：", ad)