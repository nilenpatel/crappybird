import bge
import random
import mathutils

def on_player_keypress():
	controller = bge.logic.getCurrentController()
	obj = controller.owner
	sensor = controller.sensors['Keyboard']
	if sensor.positive:
		obj.applyForce(mathutils.Vector((0,0,200)))

	actuator = controller.actuators['Constraint']

	controller.activate(actuator)

def create_obstacle():

	controller = bge.logic.getCurrentController()
	scene = bge.logic.getCurrentScene()

	camera = scene.objects['Camera']
	obstacle = scene.objectsInactive['Obstacle']
	aberture = scene.objectsInactive['Aberture']

	camera_x = camera.worldPosition.x

	obstacle_x = camera_x + 10

	aberture_z = 5 - random.randint(3,7) / 2.0

	top = 5 - (aberture_z + 0.25)
	bottom = aberture_z - 1.25

	top_scale = top / 0.5
	bottom_scale = bottom / 0.5

	top_pos = 5 - top/2
	bottom_pos = bottom/2

	o1 = scene.addObject(obstacle,'Ref')
	o1.scaling = [1,1,top_scale]
	o1.worldPosition = [obstacle_x, 0, top_pos]

	o2 = scene.addObject(obstacle,'Ref')
	o2.scaling = [1,1,bottom_scale]
	o2.worldPosition = [obstacle_x, 0, bottom_pos]
	
	o3 = scene.addObject(aberture,'Ref')
	o3.worldPosition = [obstacle_x, 0, aberture_z]

def follow_player():
	scene = bge.logic.getCurrentScene()
	camera = scene.objects['Camera']
	player = scene.objects['Player']

	camera.worldPosition.x = player.worldPosition.x


def on_aberture_pass():
	
	controller = bge.logic.getCurrentController()
	sensor = controller.sensors['Collision']
	message_actuator = controller.actuators['Message']

	if sensor.positive == True:
		controller.activate(message_actuator)


def get_scene(name):
	scene_list = bge.logic.getSceneList()
	print(scene_list)
	for scene in scene_list:
		if scene.name == name:
			return scene
	return None

def update_indicators():
	obj = bge.logic.getCurrentController().owner
	indicators = get_scene('Indicators')
	score = indicators.objects['Score']
	score.text = str(obj['score'])

def game_over():
	obj = bge.logic.getCurrentController().owner
	controller = bge.logic.getCurrentController()

	game_over = get_scene('GameOver')
	final_score = game_over.objects['FinalScore']
	final_score.text = str(obj['score'])

def debug():
	controller = bge.logic.getCurrentController()
	sensor = controller.sensors['Message']
	if sensor.positive:
		print('1')
