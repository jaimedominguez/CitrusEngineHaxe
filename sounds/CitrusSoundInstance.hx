package citrus.sounds;

import citrus.core.CitrusEngine;
import citrus.events.CitrusEvent;
import citrus.events.CitrusEventDispatcher;
import citrus.events.CitrusSoundEvent;
import citrus.utils.SoundChannelUtil;
import kaleidoEngine.debug.InArray;
import haxe.CallStack;
import starling.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

//import citrus.core.citrus_internal;
/**
	 * CitrusSoundInstance
	 * this class represents an existing sound (playing, paused or stopped)
	 * it holds a reference to the CitrusSound it was created from and
	 * a sound channel. through a CitrusSoundInstance you can tweak volumes and panning
	 * individually instead of CitrusSound wide.
	 * 
	 * a paused sound is still considered active, and keeps a soundChannel alive to be able to resume later.
	 */
class CitrusSoundInstance extends CitrusEventDispatcher
{
    public static var maxChannels(get, never) : Int;
    public var volume(get, set) : Float;
    public var panning(get, set) : Float;
    public static var activeSoundInstances(get, never) : Array<CitrusSoundInstance>;
    private var soundChannel(get, set) : SoundChannel;
    public var leftPeak(get, never) : Float;
    public var rightPeak(get, never) : Float;
    public var parentsound(get, never) : CitrusSound;
    public var ID(get, never) : Int;
    public var isPlaying(get, never) : Bool;
    public var isPaused(get, never) : Bool;
    private var isActive(get, never) : Bool;
    public var loopCount(get, never) : Int;
    public var loops(get, never) : Int;
    private var destroyed(get, never) : Bool;

    //use namespace citrus_internal;
    
    public var data : Dynamic = { };
    public var last_position : Float = -1;
	
    private var _ID : Int = 0;
    private static var last_id : Int = 0;
    
    private var _name : String;
    private var _parentsound : CitrusSound;
    private var _soundTransform : SoundTransform;
    
    private var _permanent : Bool = false;
    
    private var _volume : Float = 1;
    private var _panning : Float = 0;
    
    private var _soundChannel : SoundChannel;
    
    private var _isPlaying : Bool = false;
    private var _isPaused : Bool = false;
    private var _isActive : Bool = false;
    private var _loops : Int = 0;
    private var _loopCount : Int = 0;
    
    private var _destroyed : Bool = false;
    
    private var _ce : CitrusEngine;
    
    /**
		 * if autodestroy is true, when the sound ends, destroy will be called instead of just stop().
		 */
    private var _autodestroy : Bool;
    
    /**
		 * list of active sound instances
		 */
    private static var _list : Array<CitrusSoundInstance> = new Array<CitrusSoundInstance>();
    
    /**
		 * list of active non permanent sound instances
		 */
    private static var _nonPermanent : Array<CitrusSoundInstance> = new Array<CitrusSoundInstance>();
    
    /**
		 * What to do when no new sound channel is available?
		 * remove the first played instance, the last, or simply don't play the sound.
		 * @see REMOVE_FIRST_PLAYED
		 * @see REMOVE_LAST_PLAYED
		 * @see DONT_PLAY
		 */
    public static var onNewChannelsUnavailable : String = REMOVE_FIRST_PLAYED;
    
    /**
		 * offset to use on all sounds when playing them via Sound.play(startPosition...).
		 * 
		 * If all of your sounds are encoded using the same encoder (that's important otherwise the silence could be variable),
		 * and you are able to identify the amount of silence in ms that there is at the beginning of them,
		 * set startPositionOffset to that value you found.
		 * 
		 * This will get rid of most if not all the gaps in looping and non looping sounds.
		 * 
		 * Warning: it won't get rid of the gaps caused by loading/streaming or event processing.
		 */
    public static var startPositionOffset : Float = 0;
    
    /**
		 * trace all events dispatched from CitrusSoundInstances
		 */
    public static var eventVerbose : Bool = true;
    
    private static var _maxChannels : Int = 32;
   
   // private static var _maxChannels : Int = SoundChannelUtil.maxAvailableChannels();
    
    
    private static function get_maxChannels() : Int
    {
        return _maxChannels;
    }
    
    public function new(parentsound : CitrusSound, autoplay : Bool = true, autodestroy : Bool = true)
    {
        super();
        _parentsound = parentsound;
        _permanent = _parentsound.permanent;
        _soundTransform = _parentsound.resetSoundTransform();
        _ID = last_id++;
        _ce = CitrusEngine.getInstance();
        
        _name = _parentsound.name;
        _loops = _parentsound.loops;
        _autodestroy = autodestroy;

        if (autoplay)  {
            play();
        }
    }
    
    public function play() : Void {
		
        if (_destroyed) {
            return;
        }
        
        if (!_isPaused || !_isPlaying) {
            playAt(startPositionOffset);
        }
    }
    
    public function playAt(position : Float) : Void {
		
        if (_destroyed) {
            return;
        }
        
        var soundInstance : CitrusSoundInstance;
        
        //check if the same CitrusSound is already playing and is permanent (if so, no need to play a second one)
        if (_permanent) {
            for (soundInstance in _list) {
                if (soundInstance._name == this._name) {
                    dispatcher(CitrusSoundEvent.NO_CHANNEL_AVAILABLE);
					trace("NO CHANNEL AVAILABLE");
                    stop(true);
                    return;
                }
            }
        }
        
        //check if channels are available, if not, free some up (as long as instances are not permanent)
        if (_list.length >= maxChannels) {
            var len : Int;
            var i : Int;
            switch (onNewChannelsUnavailable){
                case REMOVE_FIRST_PLAYED:
                    i = 0;
                    while (i < _nonPermanent.length - 1) {
                        soundInstance = _nonPermanent[i];
                        if (soundInstance != null && !soundInstance.isPaused) {
                            soundInstance.stop(true);
                        }
						
                        if (_list.length + 1 > _maxChannels) {
                            i = 0;
                        }else {
                            break;
                        }
                        i++;
                    }
                case REMOVE_LAST_PLAYED:
                    i = _nonPermanent.length - 1;
                    while (i > -1)
                    {
                        soundInstance = _nonPermanent[i];
                        if (soundInstance != null && !soundInstance.isPaused) {
                            soundInstance.stop(true);
                        }
                        if (_list.length + 1 > _maxChannels) {
                            i = _nonPermanent.length - 1;
                        } else{
                            break;
                        }
                        i--;
                    }
                case DONT_PLAY:
                    dispatcher(CitrusSoundEvent.NO_CHANNEL_AVAILABLE);
                    stop(true);
                    return;
            }
        }

        if (!_parentsound.ready)
        {
            dispatcher(CitrusSoundEvent.SOUND_NOT_READY);
            _parentsound.load();
			_isPlaying = true;
			last_position = position;
			return;
        }
        
        if (_list.length >= _maxChannels)
        {
            dispatcher(CitrusSoundEvent.NO_CHANNEL_AVAILABLE);
            stop(true);
            return;
        }
		
		reallyPlayFrom(position);
     
    }
	
	function reallyPlayFrom(position:Float) {
		
        _isActive = true;
        
        soundChannel = _parentsound._sound.play(position, (_loops < 0) ? 10 : 0);

        _isPlaying = true;
        _isPaused = false;
        
        resetSoundTransform();
        
        _list.unshift(this);
        
        if (!_permanent){
            _nonPermanent.unshift(this);
        }
        
        _parentsound.soundInstances.unshift(this);
        
        if ((position == 0 || position == startPositionOffset) && _loopCount == 0){
            dispatcher(CitrusSoundEvent.SOUND_START);
        }
	}
	
	private function soundPlayed(e:Event):Void {
		SoundManager.getInstance().dispatchEventWith(CitrusSoundEvent.SOUND_END);
		dispatcher(CitrusSoundEvent.SOUND_END);
		
	}
	
	public function resumeAfterLoad():Void {
		reallyPlayFrom (last_position);
	}
    
    public function pause() : Void {
        if (!_isActive)
        {
            return;
        }
        
        if (_soundChannel != null)
        {
            last_position = _soundChannel.position;
            _soundChannel.stop();
        }
        soundChannel = _parentsound.sound.play(0, as3hx.Compat.INT_MAX);
        
        _isPlaying = false;
        _isPaused = true;
        
        resetSoundTransform();
        
        dispatcher(CitrusSoundEvent.SOUND_PAUSE);
    }
    
    public function resume() : Void
	{
	
        if (!_isActive || _soundChannel==null){
            return;
        }
        _soundChannel.stop();
        soundChannel = _parentsound.sound.play(last_position, 0);
        
        _isPlaying = true;
        _isPaused = false;
     
        resetSoundTransform();
        
        dispatcher(CitrusSoundEvent.SOUND_RESUME);
		
    }
    
    public function stop(forced : Bool = false) : Void {
		//trace("[STOP] CITRUS SOUND INSTANCE");
        if (_destroyed)
        {
            return;
        }
        
        if (_soundChannel != null)
        {
            _soundChannel.stop();
        }
        soundChannel = null;
        
        _isPlaying = false;
        _isPaused = false;
        _isActive = false;
        
        _loopCount = 0;
        
        removeSelfFromVector(_list);
        removeSelfFromVector(_nonPermanent);
        removeSelfFromVector(_parentsound.soundInstances);
        
        if (forced)
        {
            dispatcher(CitrusSoundEvent.FORCE_STOP);
        }
       
        dispatcher(CitrusSoundEvent.SOUND_END);
        
        if (_autodestroy) {
			destroy();
        }
    }
    
    public function destroy(forced : Bool = false) : Void {
    //   _parentsound.removeDispatchChild(this);
        
        _parentsound = null;
        _soundTransform = null;
        data = null;
        soundChannel = null;
        
        removeEventListeners();
        
        _destroyed = true;
    }
    
    
    private function onComplete(e : flash.events.Event) : Void {
        
		
		
		if (_isPaused)
        {
            soundChannel = _parentsound.sound.play(0, as3hx.Compat.INT_MAX);
            return;
        }
        
        _loopCount++;
        
        if (_loops < 0)
        {
            _soundChannel.stop();
            soundChannel = cast(_parentsound.sound,Sound).play(startPositionOffset, as3hx.Compat.INT_MAX);
            resetSoundTransform();
        }
        else if (_loopCount > _loops)
        {
            stop();
        }
        else
        {
            _soundChannel.stop();
            soundChannel = cast(_parentsound.sound,Sound).play(startPositionOffset, 0);
            resetSoundTransform();
            dispatcher(CitrusSoundEvent.SOUND_LOOP);
        }
    }
    
   public function set_volume(value : Float) : Float
    {
        _volume = value;
        resetSoundTransform();
        return value;
    }
    
   public function get_volume() : Float
    {
        return _volume;
    }
    
   public function set_panning(value : Float) : Float
    {
        _panning = value;
        resetSoundTransform();
        return value;
    }
    
   public function get_panning() : Float
    {
        return _panning;
    }
    
    public function setVolumePanning(volume : Float = 1, panning : Float = 0) : CitrusSoundInstance
    {
        _volume = volume;
        _panning = panning;
        resetSoundTransform();
        return this;
    }
    
    /**
		 * removes self from given vector.
		 * @param	list Vector.&lt;CitrusSoundInstance&gt;
		 */
    public function removeSelfFromVector(list : Array<CitrusSoundInstance>) : Void {
       
        for (i in 0...list.length)
        {
            if (list[i] == this){
				list[i] = null;
                list.splice(i, 1);
                return;
            }
        }
    }
    
    /**
		 * a vector of all currently playing CitrusSoundIntance objects
		 */
    private static function get_activeSoundInstances() : Array<CitrusSoundInstance>
    {
        return _list.copy();
    }
    
    /**
		 * use this setter when creating a new soundChannel
		 * it will automaticaly add/remove event listeners from the protected _soundChannel
		 */
    @:allow(citrus.sounds)
   public function set_soundChannel(channel : SoundChannel) : SoundChannel
    {

		if (_soundChannel != null) {
            _soundChannel.removeEventListener(CitrusSoundEvent.SOUND_COMPLETE, onComplete, true);
        }
        if (channel != null){
            channel.addEventListener(flash.events.Event.SOUND_COMPLETE, onComplete);
        }
        
        _soundChannel = channel;
        return channel;
    }
    
    public function getSoundChannel() : SoundChannel
    {
        return _soundChannel;
    }
    
    @:allow(citrus.sounds)
   public function get_soundChannel() : SoundChannel
    {
        return _soundChannel;
    }
    
   public function get_leftPeak() : Float
    {
        if (_soundChannel != null)
        {
            return _soundChannel.leftPeak;
        }
        return 0;
    }
    
   public function get_rightPeak() : Float
    {
        if (_soundChannel != null)
        {
            return _soundChannel.rightPeak;
        }
        return 0;
    }
    
   public function get_parentsound() : CitrusSound
    {
        return _parentsound;
    }
    
   public function get_ID() : Int
    {
        return _ID;
    }
    
   public function get_isPlaying() : Bool {
        return _isPlaying;
    }
    
   public function get_isPaused() : Bool {
        return _isPaused;
    }
    
    @:allow(citrus.sounds)
   public function get_isActive() : Bool {
        return _isActive;
    }
    
   public function get_loopCount() : Int
    {
        return _loopCount;
    }
    
   public function get_loops() : Int
    {
        return _loops;
    }
    
    /**
		 * dispatches CitrusSoundInstance
		 */
    @:allow(citrus.sounds)
    private function dispatcher(type : String) : Void {

		
		var event : Event = cast(new CitrusSoundEvent(type, _parentsound, this, ID), Event);
		
		//parent sound is often CitrusSound.
		if (_parentsound!=null){
			_parentsound.dispatchEvent(event);
		}else {
			dispatchEvent(event);
		}
       
        if (eventVerbose)
        {
		//	trace("dispatcher() :" + _parentsound.name + ">" +event.type);
          //  trace("EVENT DATA:"+event);
        }
    }
    
    @:allow(citrus.sounds)
   public function get_destroyed() : Bool {
        return _destroyed;
    }
    
    @:allow(citrus.sounds)
    private function resetSoundTransform(parentSoundTransformReset : Bool = true) : SoundTransform
    {
        _soundTransform = (parentSoundTransformReset) ? _parentsound.resetSoundTransform() : _parentsound.soundTransform;
        _soundTransform.volume *= _volume;
        _soundTransform.pan = _panning;
        
        if (_soundChannel != null)
        {
            if (_isPaused){
                return _soundChannel.soundTransform = SoundChannelUtil.silentST;
            }
            else
            {
                return _soundChannel.soundTransform = _soundTransform;
            }
        }
        else
        {
            return _soundTransform;
        }
    }
    
    public function toString() : String
    {
        return "CitrusSoundInstance name:" + _name + " id:" + _ID + " playing:" + _isPlaying + " paused:" + _isPaused + "\n";
    }
    
    public static inline var REMOVE_LAST_PLAYED : String = "REMOVE_LAST_PLAYED";
    public static inline var REMOVE_FIRST_PLAYED : String = "REMOVE_FIRST_PLAYED";
    public static inline var DONT_PLAY : String = "DONT_PLAY";
}

