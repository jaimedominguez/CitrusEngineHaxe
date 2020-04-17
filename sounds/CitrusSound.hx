package citrus.sounds;

import citrus.sounds.CitrusSoundInstance;
import kaleidoEngine.data.dataType.Boolean;
import flash.errors.Error;
import citrus.core.CitrusEngine;
import citrus.events.CitrusEvent;
import citrus.events.CitrusEventDispatcher;
import citrus.events.CitrusSoundEvent;
import flash.events.ErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import openfl.Assets;
import openfl.media.Sound;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import haxe.CallStack;
import openfl.utils.Future;
import starling.events.Event;


class CitrusSound extends CitrusEventDispatcher
{
    public var sound(get, set) : Dynamic;
    public var isPlaying(get, never) : Bool;
    public var isPaused(get, never) : Bool;
    public var group(get, set) : Dynamic;
    public var volume(get, set) : Float;
    public var panning(get, set) : Float;
    public var mute(get, set) : Bool;
    public var loadedRatio(get, never) : Float;
    public var loaded(get, never) : Bool;
    public var ioerror(get, never) : Bool;
    public var name(get, never) : String;
    public var soundTransform(get, never) : SoundTransform;
    public var ready(get, never) : Bool;
    public var instances(get, never) : Array<CitrusSoundInstance>;
    public var canBeRemoved :Bool = true;

    public var hideParamWarnings : Bool = false;
    
    private var _name : String;
    private var _soundTransform : SoundTransform;
    public var _sound : Sound;
    private var _ioerror : Bool = false;
    private var _loadedRatio : Float = 0;
    private var _loaded : Bool = false;
    private var _group : CitrusSoundGroup;
    private var _isPlaying : Bool = false;
    private var _urlReq : URLRequest;
    private var _volume : Float = 1;
    private var _panning : Float = 0;
    private var _mute : Bool = false;
    private var _paused : Bool = false;
 
    private var _ce : CitrusEngine;
    
    /**
		 * times to loop :
		 * if negative, infinite looping will be done and loops won't be tracked in CitrusSoundInstances.
		 * if you want to loop infinitely and still keep track of loops, set loops to int.MAX_VALUE instead, each time a loop completes
		 * the SOUND_LOOP event would be fired and loops will be counted.
		 */
    public var loops : Int = 0;
    
    /**
		 * a list of all CitrusSoundInstances that are active (playing or paused)
		 */
    @:allow(citrus.sounds)
    private var soundInstances : Array<CitrusSoundInstance>;
	private var thisSoundInstance:CitrusSoundInstance;
    
    /**
		 * if permanent is set to true, no new CitrusSoundInstance
		 * will stop a sound instance from this CitrusSound to free up a channel.
		 * it is a good idea to set background music as 'permanent'
		 */
    public var permanent : Bool = false;
    
    /**
		 * When the CitrusSound is constructed, it will load itself.
		 */
    public var autoload : Bool = false;
    
    public function new(name : String, params : Dynamic = null)
    {
		
       super();
        _ce = CitrusEngine.getInstance();
     
        _name = name;
        if (Reflect.field(params, "sound") == null)
        {
            throw new Error(Std.string(Std.string(this) + " sound " + name + " has no sound param defined."));
        }
       
        soundInstances = new Array<CitrusSoundInstance>();
        setParams(params);
        if (autoload)  {
            load();
		}
    }
	
	public function getSoundInstance():CitrusSoundInstance {
		return thisSoundInstance;
	}
	
	public function preLoad() :Void {
		//trace("PRELOAD: "+_urlReq.url);
		load();
		/*var future = new Future (function () {
            Assets.cache.setSound(_urlReq.url, Assets.cache.getSound(_urlReq.url));
		}, true);
	
		future.onComplete(preloadComplete);
		*/
	}
	
	/*private function preloadComplete(value:<T>):Void {
		onLoad();
        return ;
	}*/
	
    
    public function load() : Void {
        unload();
		
		if (_urlReq.url.indexOf("embed")==-1){
			if (_urlReq != null && _loadedRatio == 0 && !_sound.isBuffering)
			{
				_ioerror = false;
				_loaded = false;
				_sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_sound.addEventListener(Event.COMPLETE, onLoad);
				
				//trace("LOAD SOUND FROM EXTERNAL ASSETS:" + _urlReq.url);
				_sound.load(_urlReq);
				
			
			}
		}else {
			if (Assets.cache.hasSound(_urlReq.url)){
                 _sound = Assets.cache.getSound(_urlReq.url);
            }else{
                 _sound = Assets.getSound(_urlReq.url);
            }
			
			//_sound = openfl.Assets..getSound(_urlReq.url);
			onLoad();
			
		}
    }
	
	
    
    public function unload() : Void {
		if (_sound!=null){
			if (_sound.isBuffering)
			{
				_sound.close();
			}
			_sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_sound.removeEventListener(Event.COMPLETE, onLoad);
		}
        sound = _urlReq;
    }
    
    public function play() : CitrusSoundInstance
    {
        return thisSoundInstance = new CitrusSoundInstance(this, true, true);
    }
    
    /**
		 * creates a sound instance from this CitrusSound.
		 * you can use this CitrusSoundInstance to play at a specific position and control its volume/panning.
		 * @param	autoplay
		 * @param	autodestroy
		 * @return CitrusSoundInstance
		 */
    public function createInstance(autoplay : Bool = false, autodestroy : Bool = true) : CitrusSoundInstance
    {
    
		return new CitrusSoundInstance(this, autoplay, autodestroy);
    }
    
    public function resume() : Void {
        var soundInstance : CitrusSoundInstance;
        for (soundInstance in soundInstances)
        {
			//trace("RESUME SOUND...");
            if (soundInstance.isPaused) {
                soundInstance.resume();
            }
        }
    }
    
    public function pause() : Void {
        var soundInstance : CitrusSoundInstance;
        for (soundInstance in soundInstances)
        {
            if (soundInstance.isPlaying){
                soundInstance.pause();
            }
        }
    }
    
    public function stop() : Void {
        var soundInstance : CitrusSoundInstance;
        for (soundInstance in soundInstances)
        {
            if (soundInstance.isPlaying || soundInstance.isPaused){
                soundInstance.stop();
            }
        }
    }
    
    private function onIOError(event : ErrorEvent) : Void {
        unload();
        trace("CitrusSound Error Loading: ", this.name + ",>"+event.errorID);
        _ioerror = true;
        dispatchEvent(cast(new CitrusSoundEvent(CitrusSoundEvent.SOUND_ERROR, this, null), Event));
    }
 
	private function onLoad(event:Event=null):Void {
		
		//trace("LOAD onComplete EVENT");
		
		_loaded = true;
		_loadedRatio = 1;
		dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.SOUND_LOADED, this, null));

		if (thisSoundInstance!=null && thisSoundInstance.isPlaying && thisSoundInstance.last_position>-1) {
			thisSoundInstance.resumeAfterLoad();
		}
	}
	
	
	private function soundPlayed(e:flash.events.Event):Void {
		//trace("****sound Played");
		dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.SOUND_END, this, null));
	}
	
    
    @:allow(citrus.sounds)
    private function resetSoundTransform(applyToInstances : Bool = false) : SoundTransform
    {
        if (_soundTransform == null)
        {
            _soundTransform = new SoundTransform();
        }
        
        if (_group != null)
        {
            _soundTransform.volume = ((_mute || _group._mute || _ce.soundMng.masterMute)) ? 0 : _volume * _group._volume * _ce.soundMng.masterVolume;
            _soundTransform.pan = _panning;
        }
        else
        {
            _soundTransform.volume = ((_mute || _ce.soundMng.masterMute)) ? 0 : _volume * _ce.soundMng.masterVolume;
            _soundTransform.pan = _panning;
        }
        
        if (applyToInstances)
        {
            var soundInstance : CitrusSoundInstance;
            for (soundInstance in soundInstances){
                soundInstance.resetSoundTransform(false);
            }
        }
        
        return _soundTransform;
    }
    
   public function set_sound(val : Dynamic) : Dynamic{
		
    
	 
        if (_sound != null)
        {
            _sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
     
			_sound.removeEventListener(Event.COMPLETE, onLoad);
        }
        
        if (Std.is(val, String)){
		
            _urlReq = new URLRequest(val);
		
            _sound = new Sound();
       }else if (Std.is(val, Class)){
			_sound = Type.createEmptyInstance(val);
			_ioerror = false;
			_loadedRatio = 1;
			_loaded = true;
        }else if (Std.is(val, Sound))
        {
		
            _sound = cast(val, Sound);
            _loadedRatio = 1;
            _loaded = true;
        }else if (Std.is(val, URLRequest))
        {
            _urlReq = cast(val,URLRequest);
            _sound = new Sound();
        }
        else
        {
            throw new Error("CitrusSound, " + val + "is not a valid sound paramater");
        }
        return val;
    }
    
   public function get_sound() : Sound // Dynamic
    {
        return _sound;
    }
    
   public function get_isPlaying() : Bool {
        var soundInstance : CitrusSoundInstance;
        for (soundInstance in soundInstances)
        {
            if (soundInstance.isPlaying){
                return true;
            }
        }
        return false;
    }
    
   public function get_isPaused() : Bool {
        var soundInstance : CitrusSoundInstance;
        for (soundInstance in soundInstances)
        {
            if (soundInstance.isPaused){
                return true;
            }
        }
        return false;
    }
    
   public function get_group() : Dynamic
    {
        return _group;
    }
    
   public function set_volume(val : Float) : Float
    {
        if (_volume != val)
        {
            _volume = val;
            resetSoundTransform(true);
        }
        return val;
    }
    
   public function set_panning(val : Float) : Float
    {
        if (_panning != val)
        {
            _panning = val;
            resetSoundTransform(true);
        }
        return val;
    }
    
   public function set_mute(val : Bool) : Bool {
        if (_mute != val)
        {
            _mute = val;
            resetSoundTransform(true);
        }
        return val;
    }
    
   public function set_group(val : Dynamic) : Dynamic
    {
		_group = CitrusEngine.getInstance().soundMng.getGroup(val);
        if (_group != null)
        {
            _group.addSound(this);
        }
        return val;
    }
    
    public function setGroup(val : CitrusSoundGroup) : Void {
        _group = val;
    }
    
    @:allow(citrus.sounds)
    private function destroy() : Void {
        if (_sound != null){
            _sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
            _sound.removeEventListener(Event.COMPLETE, onLoad);
        }
        if (_group != null){
            _group.removeSound(this);
        }
        _soundTransform = null;
        _sound = null;
        
       
        for (soundInstance in soundInstances){
            soundInstance.stop();
        }
        
        removeEventListeners();
		
    }
    
   public function get_loadedRatio() : Float
    {
        return _loadedRatio;
    }
    
   public function get_loaded() : Bool {
        return _loaded;
    }
    
   public function get_ioerror() : Bool {
        return _ioerror;
    }
    
   public function get_volume() : Float
    {
        return _volume;
    }
    
   public function get_panning() : Float
    {
        return _panning;
    }
    
   public function get_mute() : Bool {
        return _mute;
    }
    
   public function get_name() : String
    {
        return _name;
    }
    
   public function get_soundTransform() : SoundTransform
    {
        return _soundTransform;
    }
    
   public function get_ready() : Bool {
        if (_sound != null){
           if (_sound.isBuffering || _loadedRatio > 0){
                return true;
            }
        }
        return false;
    }
    
   public function get_instances() : Array<CitrusSoundInstance>
    {
        return soundInstances.copy();
    }
    
    public function getInstance(index : Int) : CitrusSoundInstance
    {
        if (soundInstances.length > index + 1)
        {
            return soundInstances[index];
        }
        return null;
    }
    
    private function setParams(params : Dynamic) : Void {
		
        for (paramKey in Reflect.fields(params))
        {
          var paramValue:Dynamic = Reflect.field(params, paramKey);
		  
			if ( paramValue == "true" || paramValue=="false")
			{
				Reflect.setProperty(this, paramKey, Boolean.isTrue(paramValue));
			}else
			{
				Reflect.setProperty(this, paramKey, Reflect.field(params,paramKey));
			}
        }
    }
	
	  /* 
    private function onProgress(event : ProgressEvent) : Void {
		//NOT WORKING IN HXCPP (IT JUST DOESNT GET CALLED)
        _loadedRatio = _sound.bytesLoaded / _sound.bytesTotal;
		trace("onProgress:" + _loadedRatio + "=" + _sound.bytesLoaded + "/"+_sound.bytesTotal);
		
        if (_loadedRatio == 1)
        {
            _loaded = true;
			onComplete();
			trace("SOUND LOADED:" + _urlReq.url);
            //dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.SOUND_LOADED, this, null));
        }
    }
	*/
	
	
}

