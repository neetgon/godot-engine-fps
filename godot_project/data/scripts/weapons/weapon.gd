extends Node3D
class_name Weapon;

@export var weapon_id : String;
@export var weapon_animation_player : AnimationPlayer;
@export var arms_animation_player : AnimationPlayer;

@export var animation_out_speed : float = 1.0;
@export var animation_in_speed : float = 1.0;

@export var muzzle_point : Node3D;

@export var max_ammo : int = 32;
var current_ammo : int;
@export var weapon_recoil : float = 0.05;

@export_group("Audios")
@export var draw_audio : AudioStreamOggVorbis;
@export var hide_audio : AudioStreamOggVorbis;
@export var reload_audio : AudioStreamOggVorbis;
@export var fire_audio : AudioStreamOggVorbis;
@export var fire_empty_audio : AudioStreamOggVorbis;

var bullet_hole : PackedScene = preload(
	"res://data/scenes/bullet_hole.tscn"
);

enum WEAPON_STATES {
	DISABLED,
	HIDE,
	DRAW,
	IDLE,
	FIRE,
	FIRE_EMPTY,
	RELOAD,
}

var current_weapon_state : WEAPON_STATES = WEAPON_STATES.DISABLED;

func _ready() -> void:
	visible = false;
	current_ammo = max_ammo;

func _process(_delta: float) -> void:
	if current_weapon_state == WEAPON_STATES.IDLE:
		pass

func fire_weapon() -> void:
	if current_weapon_state == WEAPON_STATES.IDLE:
		if current_ammo <= 0:
			current_weapon_state = WEAPON_STATES.FIRE;
			play_audio(fire_empty_audio);
			
			await play_animation(weapon_id + "_fire_empty");
		else:
			current_weapon_state = WEAPON_STATES.FIRE_EMPTY;
			current_ammo -= 1;
			
			var target : Vector3 = Global.player_camera.global_position;
			target -= Global.player_camera.global_basis.z * 5.0;
			
			Global.effects.draw_bullet_tracer(
				muzzle_point.global_position,
				target,
				Color.ORANGE
			);
			
			Global.effects.draw_bullet_hole(bullet_hole);
			
			play_audio(fire_audio);
			
			Global.player_camera.apply_rotation_offset(
				Vector3(weapon_recoil, 0, 0)
			);
			
			await play_animation(weapon_id + "_fire");
		
		current_weapon_state = WEAPON_STATES.IDLE;

func reload_weapon() -> void:
	if current_weapon_state == WEAPON_STATES.IDLE:
		current_weapon_state = WEAPON_STATES.RELOAD;
		play_audio(reload_audio);
		await play_animation(weapon_id + "_reload");
		current_ammo = max_ammo;
		current_weapon_state = WEAPON_STATES.IDLE;

func draw_weapon() -> void:
	current_weapon_state = WEAPON_STATES.DRAW;
	
	play_audio(draw_audio);
	visible = true;
	await play_animation(weapon_id + "_in", animation_in_speed);
	
	current_weapon_state = WEAPON_STATES.IDLE;

func hide_weapon() -> void:
	current_weapon_state = WEAPON_STATES.HIDE;
	
	await play_animation(weapon_id + "_out", animation_out_speed);
	visible = false;
	
	current_weapon_state = WEAPON_STATES.DISABLED;

func play_audio(audio : AudioStreamOggVorbis, volume : float = 1.0) -> void:
	if not is_instance_valid(audio): return;
	
	AudioPlayer.play(
		audio,
		global_position,
		volume,
		false,
		true
	);

func animation_is_playing() -> bool:
	if not is_instance_valid(weapon_animation_player): return false;
	if not is_instance_valid(arms_animation_player): return false;
	
	return (
		weapon_animation_player.is_playing()
		and 
		arms_animation_player.is_playing()
	);

func play_animation(anim : String, speed : float = 1.0) -> void:
	if not is_instance_valid(weapon_animation_player): return;
	if not is_instance_valid(arms_animation_player): return;
	
	if not weapon_animation_player.has_animation(anim) : return;
	if not arms_animation_player.has_animation(anim) : return;
	
	weapon_animation_player.play(
		anim, 0, speed
	);
	
	arms_animation_player.play(
		anim, 0, speed
	);
	
	await weapon_animation_player.animation_finished;
	await arms_animation_player.animation_finished;
