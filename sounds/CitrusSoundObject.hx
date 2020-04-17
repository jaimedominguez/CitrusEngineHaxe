package citrus.sounds;

import flash.errors.Error;
import haxe.Constraints.Function;
import citrus.core.CitrusEngine;
import citrus.events.CitrusSoundEvent;
import citrus.math.MathUtils;
import citrus.math.MathVector;
import citrus.view.ISpriteView;
import flash.geom.Rectangle;

/**
	 * sound object in a CitrusSoundSpace
	 */
class CitrusSoundObject
{
    public var citrusObject(get, never) : ISpriteView;
    public var totalVolume(get, never) : Float;
    public var rect(get, never) : Rectangle;
    public var camVec(get, never) : MathVector;
    public var volume(get, set) : Float;
    public var activeSoundInstances(get, never) : Array<CitrusSoundInstance>;

    private var _ce : CitrusEngine;
    private var _space : CitrusSoundSpace;
    private var _citrusObject : ISpriteView;
    private var _sounds : Array<CitrusSoundInstance> = new Array<CitrusSoundInstance>();
    private var _enabled : Bool = true;
    
    public static var panAdjust : Function = MathUtils.easeInCubic;
    public static var volAdjust : Function = MathUtils.easeOutQuad;
    
    private var _camVec : MathVector = new MathVector();
    private var _rect : Rectangle = new Rectangle();
    
    private var _volume : Float = 1;
    
    /**
		 * radius or this sound object. this determines at what distance will the sound start to get heard.
		 */
    public var radius : Float = 600;
    
    public function new(citrusObject : ISpriteView)
    {
        _ce = CitrusEngine.getInstance();
        _space = try cast(_ce.state.getFirstObjectByType(CitrusSoundSpace), CitrusSoundSpace) catch(e:Dynamic) null;
        if (_space == null)
        {
            throw new Error("[CitrusSoundObject] for " + Reflect.field(citrusObject, "name") + " couldn't find a CitrusSoundSpace.");
        }
        
        _citrusObject = citrusObject;
        _space.add(this);
    }
    
    public function initialize() : Void {
    }
    
    /**
		 * play a sound through this sound object
		 * @param	sound sound id (String) or CitrusSound
		 * @return
		 */
    public function play(sound : Dynamic) : CitrusSoundInstance
    {
        var citrusSound : CitrusSound;
        var soundInstance : CitrusSoundInstance;
        
        if (Std.is(sound, String))
        {
            citrusSound = _space.soundManager.getSound(sound);
        }
        else if (Std.is(sound, CitrusSound))
        {
            citrusSound = sound;
        }
        
        if (citrusSound != null)
        {
            soundInstance = citrusSound.createInstance(false, true);
            if (soundInstance != null){
                soundInstance.addEventListener(CitrusSoundEvent.SOUND_START, onSoundStart);
                soundInstance.addEventListener(CitrusSoundEvent.SOUND_END, onSoundEnd);
                soundInstance.play();
                updateSoundInstance(soundInstance, _camVec.length);
            }
        }
        
        return soundInstance;
    }
    
    /**
		 * pause a sound through this sound object
		 * @param	sound sound id (String) or CitrusSound
		 * @return
		 */
    public function pause(sound : Dynamic) : Void {
        var citrusSound : CitrusSound;
        var soundInstance : CitrusSoundInstance;
        
        if (Std.is(sound, String))
        {
            citrusSound = _space.soundManager.getSound(sound);
        }
        else if (Std.is(sound, CitrusSound))
        {
            citrusSound = sound;
        }
        
        if (citrusSound != null)
        {
            citrusSound.pause();
        }
    }
    
    /**
		 * resume a sound through this sound object
		 * @param	sound sound id (String) or CitrusSound
		 * @return
		 */
    public function resume(sound : Dynamic) : Void {
        var citrusSound : CitrusSound;
        var soundInstance : CitrusSoundInstance;
        
        if (Std.is(sound, String))
        {
            citrusSound = _space.soundManager.getSound(sound);
        }
        else if (Std.is(sound, CitrusSound))
        {
            citrusSound = sound;
        }
        
        if (citrusSound != null)
        {
            citrusSound.resume();
            updateSoundInstance(soundInstance, _camVec.length);
        }
    }
    
    
    /**
		 * stop a sound through this sound object
		 * @param	sound sound id (String) or CitrusSound
		 * @return
		 */
    public function stop(sound : Dynamic) : Void {
        var citrusSound : CitrusSound;
        var soundInstance : CitrusSoundInstance;
        
        if (Std.is(sound, String))
        {
            citrusSound = _space.soundManager.getSound(sound);
        }
        else if (Std.is(sound, CitrusSound))
        {
            citrusSound = sound;
        }
        
        if (citrusSound != null)
        {
            citrusSound.stop();
        }
    }
    
    public function pauseAll() : Void {
        var soundInstance : CitrusSoundInstance;
        for (soundInstance in _sounds)
        {
            soundInstance.pause();
        }
    }
    
    public function resumeAll() : Void {
        var soundInstance : CitrusSoundInstance;
        for (soundInstance in _sounds)
        {
            soundInstance.resume();
        }
    }
    
    public function stopAll() : Void {
        var s : CitrusSoundInstance;
        for (s in _sounds)
        {
            s.stop();
        }
    }
    
    private function onSoundStart(e : CitrusSoundEvent) : Void {
		trace(">>>PLAYING SOUND:" + e.soundID);
        _sounds.push(e.soundInstance);
    }
    
    private function onSoundEnd(e : CitrusSoundEvent) : Void {
		trace(">>>STOPPING SOUND:" + e.soundID);
        e.soundInstance.removeEventListener(CitrusSoundEvent.SOUND_START, onSoundStart);
        e.soundInstance.removeEventListener(CitrusSoundEvent.SOUND_END, onSoundEnd);
        e.soundInstance.removeSelfFromVector(_sounds);
    }
    
    public function update() : Void {
        if (_enabled)
        {
            updateSounds();
        }
    }
    
    private function updateSounds() : Void {
        var distance : Float = _camVec.length;
        var soundInstance : CitrusSoundInstance;
        
        for (soundInstance in _sounds)
        {
            if (!soundInstance.isPlaying){
                return;
            }
            updateSoundInstance(soundInstance, distance);
        }
    }
    
    private function updateSoundInstance(soundInstance : CitrusSoundInstance, distance : Float = 0) : Void {
        var volume : Float = (distance > radius) ? 0 : 1 - distance / radius;
        soundInstance.volume = adjustVolume(volume) * _volume;
        
        var panning : Float = (Math.cos(_camVec.angle) * distance) /
        ((_rect.width / _rect.height) * 0.5);
        soundInstance.panning = adjustPanning(panning);
    }
    
    public function adjustPanning(value : Float) : Float
    {
        if (value <= -1)
        {
            return -1;
        }
        else if (value >= 1)
        {
            return 1;
        }
        
        if (value < 0)
        {
            return -panAdjust(-value, 0, 1, 1);
        }
        else if (value > 0)
        {
            return panAdjust(value, 0, 1, 1);
        }
        return value;
    }
    
    public function adjustVolume(value : Float) : Float
    {
        if (value <= 0)
        {
            return 0;
        }
        else if (value >= 1)
        {
            return 1;
        }
        
        return volAdjust(value, 0, 1, 1);
    }
    
    public function destroy() : Void {
        _space.remove(this);
        
        var soundInstance : CitrusSoundInstance;
        for (soundInstance in _sounds)
        {
            soundInstance.stop(true);
        }
        
        as3hx.Compat.setArrayLength(_sounds, 0);
        _ce = null;
        _camVec = null;
        _citrusObject = null;
        _space = null;
    }
    
   public function get_citrusObject() : ISpriteView
    {
        return _citrusObject;
    }
    
   public function get_totalVolume() : Float
    {
        var soundInstance : CitrusSoundInstance;
        var total : Float = 0;
        for (soundInstance in _sounds)
        {
            total += soundInstance.leftPeak + soundInstance.rightPeak;
        }
        if (_sounds.length > 0)
        {
            total /= _sounds.length * 2;
        }
        return total;
    }
    
   public function get_rect() : Rectangle
    {
        return _rect;
    }
    
   public function get_camVec() : MathVector
    {
        return _camVec;
    }
    
    /**
		 * volume multiplier for this CitrusSoundObject
		 */
   public function get_volume() : Float
    {
        return _volume;
    }
    
   public function set_volume(value : Float) : Float
    {
        _volume = value;
        return value;
    }
    
   public function get_activeSoundInstances() : Array<CitrusSoundInstance>
    {
        return _sounds.copy();
    }
}

