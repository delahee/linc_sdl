import sdl.Audio;
class TestAudio {
    
	static var audio_chunk : cpp.Pointer<cpp.UInt8>;
    static var audio_len = 0;
    static var audio_pos : cpp.Pointer<cpp.UInt8>;
	
    static function main() {
        //trace("A");
		var wanted : sdl.AudioSpec = SDL_AudioSpec.create(); 

		/* Set the audio format */
		wanted.ptr.freq = 22050;
		wanted.ptr.format = AudioFormat.toNative(AudioFormat.af_s16lsb);
		wanted.ptr.channels = 2;    /* 1 = mono, 2 = stereo */
		wanted.ptr.samples = 1024;  /* Good low-latency value for callback */
		//wanted.ptr.callback = fill_audio;
		wanted.ptr.userdata = cast null;

		/* Open the audio device, forcing the desired format */
		/*
		if ( SDL_OpenAudio(&wanted, NULL) < 0 ) {
			fprintf(stderr, "Couldn't open audio: %s\n", SDL_GetError());
			return(-1);
		}
		*/
		return(0);
    }
}