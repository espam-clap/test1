extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity = 0.002

@export var blackjack_ui: Control
@onready var interaction_prompt = get_node("/root/World3D/InteractionPrompt")

var can_interact = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
    if get_tree().paused:
        return

    if event.is_action_pressed("interact") and can_interact:
        open_blackjack_ui()

    if event is InputEventMouseMotion:
        rotate_y(-event.relative.x * mouse_sensitivity)
        $Head/Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
        $Head/Camera3D.rotation.x = clamp($Head/Camera3D.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
    # Add the gravity.
    if not is_on_floor():
        velocity.y -= gravity * delta

    # Handle Jump.
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = jump_velocity

    # Get the input direction and handle the movement/deceleration.
    var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)

    move_and_slide()

func open_blackjack_ui():
    get_tree().paused = true
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    if blackjack_ui:
        blackjack_ui.show()
        # Also call the start_new_game function on the UI if it exists
        if blackjack_ui.has_method("start_new_game"):
            blackjack_ui.start_new_game()

    interaction_prompt.hide()

func _on_interaction_area_body_entered(body):
    if body == self:
        can_interact = true
        interaction_prompt.show()

func _on_interaction_area_body_exited(body):
    if body == self:
        can_interact = false
        interaction_prompt.hide()

func _on_blackjack_game_exited():
    get_tree().paused = false
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    # The UI hides itself. The prompt should remain hidden as we are no longer in the area.
    can_interact = false
    interaction_prompt.hide()
