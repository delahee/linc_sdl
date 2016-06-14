//uncheck me, compile error ensues
import sdl.SDL;
import sdl.Audio;

class TestAudio {
    
	static var audio_chunk : cpp.Pointer<cpp.UInt8>;
    static var audio_len = 0;
	static var audio_pos : cpp.Pointer<cpp.UInt8>;
	
    static function main() {
        trace("A");
		var wanted : AudioSpec = SDL_AudioSpec.create(); 
		wanted.ptr.freq = 44100;
		wanted.ptr.format = AudioFormat.toNative(AudioFormat.af_s16lsb);
		wanted.ptr.channels = 2;    /* 1 = mono, 2 = stereo */
		wanted.ptr.samples = 4096;  /* Good low-latency value for callback */
		//wanted.ptr.callback = fill_audio;
		wanted.ptr.userdata = cast 0;

		var callable : cpp.Callable <
		cpp.RawPointer<cpp.Void> -> cpp.RawPointer<cpp.UInt8> -> Int -> Void >  = cpp.Callable.fromStaticFunction(fill_audio);
		wanted.ptr.callback = untyped __cpp__("(SDL_AudioCallback)({0})", callable.get_call());
		
		/* Open the audio device, forcing the desired format */
		if ( SDL.openAudio(wanted, cast null) < 0 ) {
			trace("Couldn't open audio: %s\n"+ SDL.getError());
			return(-1);
		}
		
		//var file = var ba : flash.utils.ByteArray;
		//ba = resLoader.fs.get(path).getBytes().getData();
		var path = "data/GUN1.wav";
		var bytes = sys.io.File.read(path, true).readAll();
		var wavReader = new format.wav.Reader( new haxe.io.BytesInput( bytes ));
		var waveData :format.wav.Data.WAVE = wavReader.read();
		if ( waveData == null ){
			trace("wav not found " + path);
			return -1;
		}
		else 
			trace("wav found");
			
		audio_chunk = bytes2u8Star( bytes );
		
		audio_pos = audio_chunk.add(0);
		audio_len = bytes.length;
		
		SDL.pauseAudio(0);
		while ( audio_len > 0 ) 
			SDL.delay(50);        
		SDL.closeAudio();
		trace("finished");
		return(0);
    }
	
	public static function bytes2u8Star<T>( bytes:haxe.io.Bytes): cpp.Pointer<cpp.UInt8> {
		var b : cpp.Pointer<cpp.UInt8> = cast cpp.Pointer.arrayElem( bytes.getData(), 0 );
		//= cpp.Pointer.fromRaw( cast bytes.getData());
		return b;
	}
	
	public static inline function ptrToArray<T>( ptr:cpp.Pointer<T>,length:Int ):Array<T> {
		var a :Array<T>= [];
		untyped __cpp__("{0}->setUnmanagedData({1},{2});",a,ptr.raw,length);
		return a;
	}
	
	@:unreflective
	@:analyzer(no_simplification)
	@:void
	static function fill_audio(
		userdata:cpp.RawPointer<cpp.Void>,
		stream:cpp.RawPointer<cpp.UInt8>,
		olen:Int) : Void  {
		//trace("mixing " + audio_len+" upon "+olen );
        /* Mix as much data as possible */
        var len = ( olen > audio_len ? audio_len : olen );
		if ( len < olen ) {
			var remLen = olen - len;
			var streamArr = ptrToArray( cpp.Pointer.fromRaw(stream).incBy(len), remLen );
			for ( i in 0...remLen)
				streamArr[i] = 0;
		}
		SDL.mixAudio( cpp.Pointer.fromRaw(stream), audio_pos, olen, 127);
			
		//trace("mixed" );
        audio_pos = audio_pos.incBy( len );
        audio_len -= len;
		
		if ( audio_len <= 0) {
			SDL.pauseAudio(1);
		}
	}
}