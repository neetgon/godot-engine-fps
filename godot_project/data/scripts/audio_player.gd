extends Node

var master : float = 0.1;
var sfx_volume : float = 0.6;
var voice_volume : float = 0.3;
var mute : bool = false;

func play(_audio_stream : AudioStream, _position : Vector3, _volume : float, _2d : bool, random : bool, pitch : float = 1.0, follow_node : Node3D = null):
	if not mute:
		if not _2d:
			var audio = AudioStreamPlayer3D.new();
			audio.stream = _audio_stream;
			if random:
				audio.pitch_scale = randf_range(0.8, 1.2);
			
			audio.pitch_scale *= pitch;
			audio.position = _position;
			audio.volume_linear = _volume * master;
			add_child(audio);
			audio.play();
			audio.connect("finished", func(): audio.queue_free());
		else:
			var audio = AudioStreamPlayer.new();
			audio.stream = _audio_stream;
			
			if random:
				audio.pitch_scale = randf_range(0.8, 1.2);
			
			audio.pitch_scale *= pitch;
			audio.volume_linear = _volume * master;
			
			if is_instance_valid(follow_node):
				follow_node.add_child(audio);
			else:
				add_child(audio);
			
			audio.play();
			audio.connect("finished", func(): audio.queue_free());
