extends Node2D
const CYAN = Color('#64f5df')
const PINK = Color('#ff638f')
const WHITE = Color('#e6eaff')
const MUTED = Color('#8591b3')
const INK = Color('#193b57')
const BLUE = Color('#327799')
var seal = preload('res://assets/antarctic/manager.png')
var employee_portraits = {
	'neutral': preload('res://assets/employee/neutral_portrait.png'),
	'angry': preload('res://assets/employee/angry_portrait.png'),
	'distressed': preload('res://assets/employee/distressed_portrait.png'),
	'uneasy': preload('res://assets/employee/uneasy_portrait.png'),
	'uneasy_alt': preload('res://assets/employee/uneasy_alt_portrait.png'),
}
var employee_sprites = {
	'neutral': preload('res://assets/employee/neutral_sprite.png'),
	'angry': preload('res://assets/employee/angry_sprite.png'),
	'distressed': preload('res://assets/employee/distressed_sprite.png'),
	'uneasy': preload('res://assets/employee/uneasy_sprite.png'),
	'uneasy_alt': preload('res://assets/employee/uneasy_alt_sprite.png'),
}
var employee_art = preload('res://assets/employee/neutral_sprite.png')
var glacier_art = preload('res://assets/antarctic/glacier.png')
var report_art = preload('res://assets/antarctic/report.png')
var task_art = preload('res://assets/antarctic/task.png')
var reply_art = preload('res://assets/antarctic/reply.png')
var font = preload('res://assets/fonts/zh_pixel.fnt')
var player = Vector2(720,780)
var boss = Vector2(720,180)
var bullets: Array = []
var shots: Array = []
var wave = 1
var score = 0
var hp = 5
const BOSS_MAX_HP = 120
var boss_hp = BOSS_MAX_HP
var game_mode = 1 # 0: five stages, 1: endless
var ally_joined = false
var ally_position = Vector2(720,780)
var player_trail: Array = []
var ally_shots_fired = 0
var state = 'title'
var elapsed = 0.0
var phase_time = 0.0
var fire = 0.0
var emit = 0.0
var invuln = 0.0
var transition = 0.0
var volley = 0
var spell = false
var telemetry = 0.0
const MODE_NAMES = ['EASY', 'NORMAL', 'HARD']
const MODE_LABELS = ['简单', '普通', '困难']
const MODE_SPEEDS = [155.0, 205.0, 250.0]
const MODE_COUNTS = [12, 24, 36]
const MODE_INTERVALS = [0.5, 1.0/3.0, 0.25]
var difficulty = 0
var best_scores = [0, 0, 0]
var spell_kind = 0
var spell_warning = false
var emitted_total = 0
var special_ready = true
var stun_time = 0.0
var shield_time = 0.0
var clear_flash = 0.0
func activate_special():
	if state!='playing' or not special_ready or transition>0 or stun_time>0:
		return
	special_ready=false
	bullets.clear()
	shots.clear()
	stun_time=3.0
	shield_time=3.0
	clear_flash=0.45
	tone(880)
func volley_count() -> int:
	if difficulty==2:
		if spell and spell_kind!=2:return 18
		if not spell and pattern_id()==2:return 24
	return MODE_COUNTS[difficulty]
func spell_interval() -> float:
	return maxf(8,18-wave) if difficulty==0 else maxf(6,12-wave) if difficulty==1 else maxf(9,12-wave)

func mode_rect(i: int) -> Rect2:
	return Rect2(476+i*166,540,156,78)
func pattern_id() -> int:
	return 0 if wave<2 and difficulty==0 else int(phase_time/(6.0-difficulty))%mini(wave+difficulty,4)
func spell_name() -> String:
	return ['每日报告','跨部门协作','双重截止期限'][spell_kind]
func menu():
	if state in ['playing','paused']:
		best_scores[difficulty]=maxi(best_scores[difficulty],score)
	dialogue_voice.stop()
	state='title';bullets.clear();shots.clear();spell=false;spell_warning=false

const OPENING_DIALOGUE = [
  {
    "speaker": "你",
    "inner": false,
    "expression": "neutral",
    "text": "我去，今天终于熬到下班了。"
  },
  {
    "speaker": "你",
    "inner": false,
    "expression": "neutral",
    "text": "还是赶快溜之大……."
  },
  {
    "speaker": "老板",
    "inner": false,
    "expression": "neutral",
    "text": "等会儿！"
  },
  {
    "speaker": "老板",
    "inner": false,
    "expression": "neutral",
    "text": "一会咱们开个会去！"
  },
  {
    "speaker": "老板",
    "inner": false,
    "expression": "neutral",
    "text": "线上的进会议哈！"
  },
  {
    "speaker": "你",
    "inner": true,
    "expression": "angry",
    "text": "WTF"
  },
  {
    "speaker": "你",
    "inner": true,
    "expression": "angry",
    "text": "这个南极〇畜又在干什么！？"
  },
  {
    "speaker": "你",
    "inner": true,
    "expression": "angry",
    "text": "那只好带薪破坏工作了。"
  }
]
const AFTER_FIRST_DIALOGUE = [
  {
    "speaker": "你",
    "inner": false,
    "expression": "neutral",
    "text": "ok吧也没有很晚这会挤个地铁回去也还行"
  },
  {
    "speaker": "老板",
    "inner": false,
    "expression": "neutral",
    "text": "今天新来的同学可以先走了哈等系统今天先激活一下，"
  },
  {
    "speaker": "老板",
    "inner": false,
    "expression": "neutral",
    "text": "其他人等一下，"
  },
  {
    "speaker": "你",
    "inner": false,
    "expression": "uneasy",
    "text": "？"
  }
]
const AFTER_SECOND_DIALOGUE = [
  {
    "speaker": "你",
    "inner": true,
    "expression": "uneasy",
    "text": "哇靠，这下得结束了吧？"
  },
  {
    "speaker": "你",
    "inner": true,
    "expression": "uneasy",
    "text": "这楼又没班车，"
  },
  {
    "speaker": "老板",
    "inner": false,
    "expression": "neutral",
    "text": "嗷嗷，现在实习的同学可以走了哈，"
  },
  {
    "speaker": "你",
    "inner": false,
    "expression": "uneasy_alt",
    "text": "（哇靠赶快）"
  },
  {
    "speaker": "老板",
    "inner": false,
    "expression": "neutral",
    "text": "本次不提供任何交通补贴哈，"
  },
  {
    "speaker": "你",
    "inner": false,
    "expression": "uneasy_alt",
    "text": "，？"
  },
  {
    "speaker": "老板",
    "inner": false,
    "expression": "neutral",
    "text": "大家可以自己坐渡轮或者从南极游回去，没有泳衣的去33楼领一下。"
  },
  {
    "speaker": "你",
    "inner": false,
    "expression": "distressed",
    "text": "………………….."
  },
  {
    "speaker": "你",
    "inner": false,
    "expression": "distressed",
    "text": "哎一古"
  }
]
const AFTER_FOURTH_DIALOGUE = [
  {
    "speaker": "你",
    "inner": false,
    "expression": "angry",
    "text": "啥意思啊为啥就一直只有我一个人！？！？"
  },
  {
    "speaker": "员工B",
    "inner": false,
    "expression": "neutral",
    "text": "哎，"
  },
  {
    "speaker": "员工B",
    "inner": false,
    "expression": "neutral",
    "text": "原来还有人啊！太好了！"
  },
  {
    "speaker": "你",
    "inner": false,
    "expression": "distressed",
    "text": "特么的所以意思是大家都没走是吗"
  },
  {
    "speaker": "员工B",
    "inner": false,
    "expression": "neutral",
    "text": "嘻嘻"
  },
  {
    "speaker": "员工B",
    "inner": false,
    "expression": "neutral",
    "text": "耍起"
  }
]
const AFTER_FIFTH_DIALOGUE = [
  {
    "speaker": "你",
    "inner": false,
    "expression": "angry",
    "text": "咋还没完啊！！"
  },
  {
    "speaker": "你",
    "inner": false,
    "expression": "angry",
    "text": "我直接把第二天的卡打了算了。"
  },
  {
    "speaker": "员工B",
    "inner": false,
    "expression": "neutral",
    "text": "其实你可以"
  },
  {
    "speaker": "员工B",
    "inner": false,
    "expression": "neutral",
    "text": "直接把企〇微〇的通知直接关掉"
  },
  {
    "speaker": "你",
    "inner": false,
    "expression": "uneasy",
    "text": "。。。"
  },
  {
    "speaker": "你",
    "inner": false,
    "expression": "neutral",
    "text": "你说的对啊"
  },
  {
    "speaker": "你",
    "inner": false,
    "expression": "uneasy",
    "text": "那你咋不走？"
  },
  {
    "speaker": "员工B",
    "inner": false,
    "expression": "neutral",
    "text": "蹭公司网下电影快"
  },
  {
    "speaker": "你",
    "inner": false,
    "expression": "distressed",
    "text": "………………….."
  }
]
const ENDLESS_DIALOGUE = [
  {
    "speaker": "老板",
    "inner": false,
    "expression": "neutral",
    "text": "我感觉有必要告诉你"
  },
  {
    "speaker": "老板",
    "inner": false,
    "expression": "neutral",
    "text": "其实我不是你们的牢板"
  },
  {
    "speaker": "老板",
    "inner": false,
    "expression": "neutral",
    "text": "我是异色伊丽莎白"
  },
  {
    "speaker": "老板",
    "inner": false,
    "expression": "neutral",
    "text": "可以不要打我了吗"
  },
  {
    "speaker": "你",
    "inner": false,
    "expression": "uneasy",
    "text": "，？"
  },
  {
    "speaker": "你",
    "inner": false,
    "expression": "angry",
    "text": "哈哈突然我起了一些沙溢你还是准备受死吧"
  }
]
var dialogue_lines: Array = []
var dialogue_index = 0
var dialogue_visible = 0
var dialogue_clock = 0.0
var dialogue_beep_cooldown = 0.0
var dialogue_beeps = 0
var dialogue_id = ''
var dialogue_voice: AudioStreamPlayer
var voice_you = preload('res://audio/voice_you.wav')
var voice_boss = preload('res://audio/voice_boss.wav')
func sentence_pages(lines: Array) -> Array:
	var pages: Array = []
	for line in lines:
		var text: String = line.text
		var chunk = ''
		for i in range(text.length()):
			var ch = text[i]
			chunk += ch
			var ending = ch in '.!?。！？'
			var next_ending = i+1<text.length() and text[i+1] in '.!?。！？'
			if ch=='\n' or (ending and not next_ending):
				if not chunk.strip_edges().is_empty():
					var page = line.duplicate()
					page.text = chunk.strip_edges()
					pages.append(page)
				chunk = ''
		if not chunk.strip_edges().is_empty():
			var page = line.duplicate()
			page.text = chunk.strip_edges()
			pages.append(page)
	return pages
func begin_dialogue(lines: Array, scene_id: String):
	dialogue_lines=sentence_pages(lines)
	dialogue_index=0
	dialogue_id=scene_id
	state='dialogue'
	shots.clear()
	reset_dialogue_line()
func reset_dialogue_line():
	dialogue_visible=0
	dialogue_clock=0.0
	dialogue_beep_cooldown=0.0
	dialogue_voice.stop()
func advance_dialogue():
	var full: String=dialogue_lines[dialogue_index].text
	if dialogue_visible<full.length():
		dialogue_visible=full.length()
		dialogue_clock=full.length()*.035
		dialogue_voice.stop()
		return
	dialogue_index+=1
	if dialogue_index>=dialogue_lines.size():
		dialogue_voice.stop()
		if dialogue_id=='after_fourth':
			ally_joined=true
			ally_position=player
			player_trail.clear()
		if dialogue_id=='after_fifth' and game_mode==0:
			state='victory'
			wave=5
			best_scores[difficulty]=maxi(best_scores[difficulty],score)
		else:
			state='playing'
		return
	reset_dialogue_line()
func tick_dialogue(dt: float):
	dialogue_clock+=dt
	dialogue_beep_cooldown=maxf(0,dialogue_beep_cooldown-dt)
	var full: String=dialogue_lines[dialogue_index].text
	var target=mini(full.length(),int(dialogue_clock/.035))
	if target>dialogue_visible:
		var fresh=full.substr(dialogue_visible,target-dialogue_visible)
		dialogue_visible=target
		var speak=false
		for ch in fresh:
			if not ch in ' ，。！？；、,.!?;*\n':speak=true
		if speak and dialogue_beep_cooldown<=0:
			dialogue_voice.stream=voice_boss if dialogue_lines[dialogue_index].speaker=='老板' else voice_you
			dialogue_voice.play()
			dialogue_beeps+=1
			dialogue_beep_cooldown=.075
func draw_dialogue():
	draw_rect(Rect2(356,112,728,806),Color(.85,.94,.98,.18))
	panel(Rect2(376,553,688,317))
	draw_rect(Rect2(378,555,684,26),BLUE)
	txt(Vector2(394,574),'下班前的小插曲' if dialogue_id=='opening' else {'after_first':'第一班结束后','after_second':'第二班结束后','after_fourth':'第四班结束后','after_fifth':'第五班结束后'}.get(dialogue_id,'班次结束后'),16,Color('#f4fbff'))
	var line: Dictionary=dialogue_lines[dialogue_index]
	var is_boss: bool=line.speaker=='老板'
	draw_texture_rect(seal if is_boss else employee_portraits.get(line.get('expression','neutral'),employee_portraits.neutral),Rect2(400,586,60,80),false)
	txt(Vector2(474,610),('某鸟纲南极鸟类企鹅科生物' if is_boss else line.speaker)+('（内心os）' if line.inner else ''),16,INK)
	txt(Vector2(474,641),'主管' if is_boss else '同事' if line.speaker=='员工B' else '员工',16,BLUE)
	draw_line(Vector2(398,669),Vector2(1040,669),Color('#b9d8e7'),2)
	var visible_text: String=line.text.substr(0,dialogue_visible)
	var pen=Vector2(402,696)
	for ch in visible_text:
		if ch=='\n':
			pen.x=402;pen.y+=27
			continue
		var width=font.get_string_size(ch,HORIZONTAL_ALIGNMENT_LEFT,-1,16).x
		if pen.x+width>1038:pen.x=402;pen.y+=27
		draw_string(font,pen,ch,HORIZONTAL_ALIGNMENT_LEFT,-1,16,INK)
		draw_string(font,pen+Vector2(1,0),ch,HORIZONTAL_ALIGNMENT_LEFT,-1,16,INK)
		pen.x+=width
	txt(Vector2(402,844),'回车 / 空格 / 点击：'+('继续' if dialogue_visible>=line.text.length() else '显示整句'),16,BLUE)
	txt(Vector2(990,844),'%d/%d' % [dialogue_index+1,dialogue_lines.size()],16,BLUE)

var music_player: AudioStreamPlayer
var music_track = preload('res://audio/antarctic_shift.wav')
var audio_player: AudioStreamPlayer
func _ready():
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	dialogue_voice=AudioStreamPlayer.new()
	dialogue_voice.volume_db=-7
	add_child(dialogue_voice)
	music_player=AudioStreamPlayer.new()
	music_track.loop_mode=AudioStreamWAV.LOOP_FORWARD
	music_track.loop_begin=0
	music_track.loop_end=int(round(music_track.get_length()*music_track.mix_rate))
	music_player.stream=music_track
	music_player.volume_db=-26
	add_child(music_player)
func tone(freq: float):
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	var data = PackedByteArray()
	for i in range(1400):
		var v = int(sin(float(i)*freq*TAU/22050.0)*2300*(1.0-float(i)/1400.0))
		data.append(v & 255)
		data.append((v >> 8) & 255)
	wav.data = data
	audio_player.stream = wav
	audio_player.play()
func start():
	if not music_player.playing:music_player.play()
	special_ready=true;stun_time=0;shield_time=0;clear_flash=0
	spell=false;spell_warning=false;spell_kind=0;emitted_total=0
	wave=1;score=0;hp=5;boss_hp=BOSS_MAX_HP;elapsed=0;phase_time=0;fire=0;emit=0;volley=0;invuln=2;transition=0
	bullets.clear();shots.clear();player=Vector2(720,780);boss=Vector2(720,180);state='playing'
	ally_joined=false;ally_position=player;player_trail.clear();ally_shots_fired=0
	dialogue_beeps=0
	begin_dialogue(OPENING_DIALOGUE,'opening')
func _input(event):
	if state=='dialogue':
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode in [KEY_ENTER,KEY_SPACE]:advance_dialogue()
			elif event.keycode==KEY_ESCAPE:menu()
		elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
			advance_dialogue()
		return
	if event is InputEventMouseMotion and state=='playing':
		player=event.position.clamp(Vector2(374,300),Vector2(1066,884))
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_ESCAPE:
			menu()
		elif state in ['title','over','victory']:
			if event.keycode==KEY_M:game_mode=1-game_mode
			elif event.keycode in [KEY_1,KEY_2,KEY_3]: difficulty=event.keycode-KEY_1
			elif event.keycode==KEY_LEFT:difficulty=posmod(difficulty-1,3)
			elif event.keycode==KEY_RIGHT:difficulty=(difficulty+1)%3
			elif event.keycode==KEY_ENTER:start()
		if event.keycode==KEY_X:activate_special()
		if event.keycode==KEY_P:
			if state=='playing':state='paused'
			elif state=='paused':state='playing'
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_RIGHT and event.pressed:activate_special()
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed and state in ['title','over','victory']:
		for i in range(2):
			if Rect2(476+i*250,457,238,32).has_point(event.position):
				game_mode=i
				return
		for i in range(3):
			if mode_rect(i).has_point(event.position):
				difficulty=i
				return
		if Rect2(476,675,488,60).has_point(event.position):start()
func _process(dt):
	music_player.volume_db=move_toward(music_player.volume_db,-18.0 if state=='playing' else -26.0,dt*24)
	if state=='dialogue':tick_dialogue(dt)
	if state=='playing':
		elapsed+=dt
		if ally_joined:
			player_trail.append({'t':elapsed,'p':player})
			while not player_trail.is_empty() and player_trail[0].t<=elapsed-.5:
				ally_position=player_trail.pop_front().p
		invuln=maxf(0,invuln-dt)
		var stunned=stun_time>0
		stun_time=maxf(0,stun_time-dt)
		shield_time=maxf(0,shield_time-dt)
		clear_flash=maxf(0,clear_flash-dt)
		if not stunned:
			phase_time+=dt
		if not stunned:
			boss=Vector2(720,180)
			if wave>=3:boss.x+=sin(phase_time*.7)*220
			if wave>=5:boss.y+=sin(phase_time*1.1)*65
		var interval=spell_interval()
		var duration=4.0
		var eligible=wave>=[4,2,1][difficulty]
		var cycle=fmod(phase_time,interval)
		spell=eligible and cycle>interval-duration and transition<=0
		spell_warning=eligible and cycle>interval-duration-1 and not spell and transition<=0
		spell_kind=0 if difficulty==0 else int(phase_time/interval)%2 if difficulty==1 else (int(phase_time/interval)+wave)%3
		if transition>0:
			transition-=dt
		else:
			fire-=dt
			if not stunned:emit-=dt
			if fire<=0:
				fire+=.1;shots.append(player+Vector2(0,-18))
				if ally_joined:
					shots.append(ally_position+Vector2(0,-18));ally_shots_fired+=1
			if emit<=0 and not stunned:
				emit+=MODE_INTERVALS[difficulty];volley+=1
				var pattern=pattern_id()
				var count: int=volley_count()
				for i in range(count):
					var fraction=float(i)/count
					var a=fraction*TAU+volley*.16
					if pattern==1:a=fraction*TAU+sin(volley*.3)*.8
					if pattern==2:a=PI*.12+float(i)*PI*.76/(count-1)+sin(volley*.4)*.22
					if pattern==3:a=fraction*TAU-volley*.21
					var origin=boss
					if spell:
						origin=Vector2(386+float(i)*660/(count-1),90 if difficulty==0 else 110)
						a=PI/2+sin(volley*.5+i*.6)*.35
						if spell_kind==1:
							# Alternating curtains cross below the boss; speed is unchanged.
							a=PI/2+sin(volley*.24)*.55*(1 if i%2==0 else -1)
							origin.y=125+sin(fraction*TAU+volley*.15)*25
						if spell_kind==2:
							var side=1 if i%2==0 else -1
							origin=boss+Vector2(side*(100+sin(phase_time)*35),25)
							a=float(i/2)*TAU/(count/2)+side*volley*.19
					bullets.append({'p':origin,'v':Vector2.from_angle(a)*MODE_SPEEDS[difficulty],'c':CYAN if spell or pattern==1 else PINK})
					emitted_total+=1
		for i in range(shots.size()-1,-1,-1):
			shots[i].y-=720*dt
			if shots[i].distance_to(boss)<42 and transition<=0:
				shots.remove_at(i);boss_hp-=1;score+=10
				if boss_hp<=0:
					var cleared=wave
					score+=1000;wave+=1;special_ready=true;boss_hp=BOSS_MAX_HP;hp=mini(hp+1,5);transition=2;phase_time=0;bullets.clear();shots.clear();tone(660)
					match cleared:
						1:begin_dialogue(AFTER_FIRST_DIALOGUE,'after_first')
						2:begin_dialogue(AFTER_SECOND_DIALOGUE,'after_second')
						4:begin_dialogue(AFTER_FOURTH_DIALOGUE,'after_fourth')
						5:
							begin_dialogue(AFTER_FIFTH_DIALOGUE+ENDLESS_DIALOGUE if game_mode==1 else AFTER_FIFTH_DIALOGUE,'after_fifth')
							if game_mode==0:wave=5
					break
			elif shots[i].y<65:shots.remove_at(i)
		for i in range(bullets.size()-1,-1,-1):
			bullets[i].p+=bullets[i].v*dt
			var pos: Vector2=bullets[i].p
			if pos.x<350 or pos.x>1090 or pos.y<50 or pos.y>920:bullets.remove_at(i)
			elif invuln<=0 and shield_time<=0 and pos.distance_to(player)<10:
				bullets.remove_at(i);hp-=1;invuln=1.6;tone(140)
				if hp<=0:state='over';best_scores[difficulty]=maxi(best_scores[difficulty],score);break
	telemetry+=dt
	if OS.has_feature('web') and telemetry>.2:
		telemetry=0
		JavaScriptBridge.eval('window.gameState='+JSON.stringify({'state':state,'game_mode':game_mode,'ally_joined':ally_joined,'ally_x':ally_position.x,'ally_y':ally_position.y,'ally_shots_fired':ally_shots_fired,'boss_max_hp':BOSS_MAX_HP,'wave':wave,'score':score,'hp':hp,'boss_hp':boss_hp,'bullets':bullets.size(),'player_x':player.x,'player_y':player.y,'spell':spell,'difficulty':MODE_NAMES[difficulty],'speed':MODE_SPEEDS[difficulty],'rate':volley_count()/MODE_INTERVALS[difficulty],'volley_count':volley_count(),'special_ready':special_ready,'stun_time':stun_time,'shield_time':shield_time,'shots':shots.size(),'phase_time':phase_time,'spell_interval':spell_interval(),'emitted_total':emitted_total,'spell_name':spell_name(),'boss_x':boss.x,'boss_y':boss.y,'dialogue_id':dialogue_id,'dialogue_index':dialogue_index,'dialogue_visible':dialogue_visible,'dialogue_beeps':dialogue_beeps,'dialogue_text':dialogue_lines[dialogue_index].text if state=='dialogue' else ''})+';',true)
	queue_redraw()
func txt(p: Vector2, value: String, size: int, color=INK):
	var px=48 if size>=48 else 32 if size>=28 else 16
	draw_string(font,p,value,HORIZONTAL_ALIGNMENT_LEFT,-1,px,color)
	draw_string(font,p+Vector2(maxi(1,px/16),0),value,HORIZONTAL_ALIGNMENT_LEFT,-1,px,color)
func panel(r: Rect2):
	raised(box(Color('#f4fbff'),INK),r)
func raised(style: StyleBoxFlat, r: Rect2):
	draw_style_box(style,r)
	draw_line(r.position+Vector2(3,3),r.position+Vector2(r.size.x-4,3),Color(1,1,1,.85),2)
	draw_line(r.position+Vector2(3,4),r.position+Vector2(3,r.size.y-4),Color(1,1,1,.6),2)
	draw_line(r.position+Vector2(4,r.size.y-4),r.end-Vector2(4,4),Color(.1,.23,.34,.3),2)
func box(bg: Color, border: Color):
	var s=StyleBoxFlat.new();s.bg_color=bg;s.border_color=INK;s.set_border_width_all(3)
	s.shadow_color=Color('#8cb4cc');s.shadow_size=3;s.shadow_offset=Vector2(4,5)
	return s
func _draw():
	draw_rect(Rect2(0,0,1440,960),Color('#dceff6'))
	for y in range(20,960,24):
		for x in range(18,1440,24):draw_rect(Rect2(x,y,2,2),Color('#c8e1ec'))
	draw_rect(Rect2(0,0,1440,22),INK)
	draw_rect(Rect2(3,3,1434,16),Color('#285c80'))
	for x in [10,34,58]:
		draw_rect(Rect2(x,7,13,11),Color('#f4fbff'))
	draw_rect(Rect2(1,1,1438,958),INK,false,3)
	txt(Vector2(42,62),'极地办公室 / 07',14,BLUE)
	txt(Vector2(42,122),'夜幕',31)
	txt(Vector2(44,155),'南极分部',16,BLUE)
	draw_line(Vector2(44,185),Vector2(312,185),BLUE,2)
	txt(Vector2(44,222),'无尽加班。',16)
	txt(Vector2(44,247),'冰点之下，限期之前。',16,BLUE)
	draw_texture_rect(employee_art,Rect2(50,278,48,64),false)
	txt(Vector2(114,300),'你：员工',13)
	txt(Vector2(114,325),'工号：001',12,BLUE)
	txt(Vector2(44,386),'01 / 移动',16,BLUE)
	txt(Vector2(44,415),'移动鼠标，控制员工。',12)
	txt(Vector2(44,456),'02 / 回复',16,BLUE)
	txt(Vector2(44,485),'回复便笺自动向上发射。',12)
	txt(Vector2(44,526),'03 / 躲避',16,BLUE)
	txt(Vector2(44,555),'躲开报告与任务单。',12)
	txt(Vector2(44,579),'胸前工牌就是判定点。',12)
	panel(Rect2(40,621,270,134))
	txt(Vector2(54,650),'破夜',19)
	txt(Vector2(54,678),'X键 / 鼠标右键',13,BLUE)
	txt(Vector2(54,706),'清屏、眩晕、无敌。',12)
	txt(Vector2(54,733),'每位主管可使用一次。',12,BLUE)
	txt(Vector2(44,822),'P键 / 暂停',14,BLUE)
	txt(Vector2(44,853),'退出键 / 难度选择',12,BLUE)
	txt(Vector2(44,909),'员工手册 / 第01版',11,BLUE)
	panel(Rect2(354,40,732,880))
	draw_texture_rect(glacier_art,Rect2(356,42,728,876),false)
	draw_rect(Rect2(356,42,728,68),Color('#effaff'))
	txt(Vector2(377,73),'第%02d班 / %s · 主管生命' % [wave,boss_name()],15)
	draw_rect(Rect2(378,89,684,10),Color('#b9d8e7'))
	draw_rect(Rect2(378,89,684*float(boss_hp)/BOSS_MAX_HP,10),BLUE)
	for s in shots:
		draw_texture_rect(reply_art,Rect2(s-Vector2(3,0),Vector2(6,18)),false)
	for b in bullets:
		draw_texture_rect(task_art if b.c==CYAN else report_art,Rect2(b.p-Vector2(6,7.5),Vector2(12,15)),false)
	draw_rect(Rect2(boss+Vector2(-32,51),Vector2(64,5)),Color('#9fc9da'))
	draw_texture_rect(seal,Rect2(boss-Vector2(48,60),Vector2(96,120)),false)
	if ally_joined:
		draw_texture_rect(employee_sprites.neutral,Rect2(ally_position-Vector2(18,24),Vector2(36,48)),false)
		txt(ally_position+Vector2(-24,45),'员工B',16,BLUE)
	if invuln<=0 or int(elapsed*12)%2==0:
		draw_rect(Rect2(player+Vector2(-14,24),Vector2(28,4)),Color('#9fc9da'))
		draw_texture_rect(employee_sprites['angry' if shield_time>0 else 'distressed' if hp<=2 else 'uneasy_alt' if hp==3 else 'uneasy' if hp==4 else 'neutral'],Rect2(player-Vector2(18,24),Vector2(36,48)),false)
		draw_rect(Rect2(player-Vector2(5,5),Vector2(10,10)),INK)
		draw_rect(Rect2(player-Vector2(3,3),Vector2(6,6)),Color('#f7fdff'))
	panel(Rect2(1110,40,286,158))
	txt(Vector2(1132,75),'当前班次',13,BLUE)
	txt(Vector2(1130,142),'%02d' % wave,48)
	txt(Vector2(1246,142),'/ 五关模式' if game_mode==0 else '/ 无尽模式',12,BLUE)
	panel(Rect2(1110,220,286,118))
	txt(Vector2(1132,253),'工作得分',13,BLUE)
	txt(Vector2(1132,305),'%07d' % score,28)
	panel(Rect2(1110,360,286,135))
	txt(Vector2(1132,397),'员工生命',13,BLUE)
	for i in range(5):draw_rect(Rect2(1134+i*47,420,37,16),BLUE if i<hp else Color('#c9e1ec'))
	txt(Vector2(1132,472),'击败主管后恢复1点生命',11,BLUE)
	panel(Rect2(1110,518,286,160))
	txt(Vector2(1130,549),'待办工作',13,BLUE)
	txt(Vector2(1130,580),spell_name() if spell else ['报告轮转','任务循环','批量审核','回复全员'][pattern_id()],16)
	txt(Vector2(1130,623),'难度 / '+MODE_LABELS[difficulty],12,BLUE)
	txt(Vector2(1130,652),['入职新人','繁忙工位','业务高峰'][difficulty],12,BLUE)
	panel(Rect2(1110,700,286,130))
	txt(Vector2(1130,730),'破夜 / X键',15,BLUE)
	txt(Vector2(1130,765),('生效中 %.1f秒' % shield_time) if shield_time>0 else '可使用' if special_ready else '本班次已用',16)
	txt(Vector2(1130,804),'下一位主管时恢复次数',11,BLUE)
	txt(Vector2(1128,875),'最高分 %07d' % best_scores[difficulty],14,BLUE)
	if stun_time>0:
		draw_rect(Rect2(boss-Vector2(54,65),Vector2(108,136)),Color('#3587b0'),false,3)
		txt(boss+Vector2(-68,90),'眩晕中 %.1f秒' % stun_time,13,INK)
	if shield_time>0:
		draw_rect(Rect2(player-Vector2(27,32),Vector2(54,64)),BLUE,false,3)
		draw_rect(Rect2(player-Vector2(30,35),Vector2(60,70)),Color('#f5fdff'),false,2)
	if clear_flash>0:
		draw_rect(Rect2(356,110,728,808),Color(.85,.97,1,clear_flash*.6))
		var radius=(0.45-clear_flash)*1700
		draw_rect(Rect2(player-Vector2(radius,radius),Vector2(radius*2,radius*2)),BLUE,false,4)
	if spell or spell_warning:
		draw_rect(Rect2(465,116,510,27),Color('#edfaff'))
		txt(Vector2(480,135),('限时任务 / ' if spell else '任务预告 / ')+spell_name(),13,BLUE)
	if transition>0:
		draw_rect(Rect2(445,405,550,70),Color('#f4fbff'))
		txt(Vector2(463,434),'本班完成 / 生命恢复1点',18)
		txt(Vector2(494,458),'下一位主管，还有新的文书。',12,BLUE)
	if state=='dialogue':
		draw_dialogue()
	elif state!='playing':
		draw_rect(Rect2(356,112,728,806),Color(.85,.94,.98,.14))
		panel(Rect2(433,227,570,590))
		draw_rect(Rect2(435,229,566,29),BLUE)
		txt(Vector2(451,250),'极地办公室 / 员工终端',12,Color('#f4fbff'))
		draw_texture_rect(employee_art,Rect2(650,280,48,64),false)
		draw_texture_rect(seal,Rect2(737,273,64,80),false)
		txt(Vector2(704,321),'对决',12,BLUE)
		var title='打卡上班'
		var sub='最冷的工位，最长的班次。'
		if state=='over':title='本班结束';sub='得分 %07d / 第%02d班' % [score,wave]
		if state=='victory':title='下班成功';sub='五关完成 / 总得分 %07d' % score
		if state=='paused':title='茶歇时间';sub='文书先放一放，稍作休息。'
		txt(Vector2(480,404),title,29)
		txt(Vector2(480,443),sub,12,BLUE)
		if state!='paused':
			for i in range(2):
				raised(box(Color('#c7e6f2') if game_mode==i else Color('#edf7fc'),BLUE),Rect2(476+i*250,457,238,32))
				txt(Vector2(490+i*250,479),['五关模式','无尽模式'][i]+' / M键',16)
			txt(Vector2(476,505),'选择难度 / 1 - 2 - 3',14,BLUE)
			for i in range(3):
				var selected=i==difficulty
				raised(box(Color('#c7e6f2') if selected else Color('#edf7fc'),BLUE if selected else Color('#9bbfd1')),mode_rect(i))
				txt(Vector2(490+i*166,570),MODE_LABELS[i],18)
				txt(Vector2(490+i*166,598),['新手入门','进阶挑战','高手试炼'][i],11,BLUE)
			txt(Vector2(476,650),['轻松的入职第一天。','收件箱已经满了。','收件箱即将爆满。'][difficulty],14,BLUE)
			raised(box(BLUE,INK),Rect2(476,675,488,60))
			txt(Vector2(495,711),'回车键 / '+('重新开始' if state in ['over','victory'] else '打卡上班')+' / '+MODE_LABELS[difficulty],15,Color('#f4fbff'))
		else:
			txt(Vector2(500,567),'按P键继续',18,BLUE)
			txt(Vector2(500,618),'退出键 / 难度选择',13,BLUE)
		txt(Vector2(476,772),'鼠标移动 / 自动向上回复',12,BLUE)
func boss_name():
	return ['小组组长','部门主管','区域经理','总监'][mini(wave-1,3)]
