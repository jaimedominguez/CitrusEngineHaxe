package citrus.sounds;

import citrus.events.CitrusEventDispatcher;
import citrus.events.CitrusSoundEvent;
import citrus.math.MathUtils;
import starling.animation.DelayedCall;
import starling.animation.Tween;
import starling.core.Starling;

/**
	 * CitrusSoundGroup represents a volume group with its groupID and has mute control as well.
	 */
class CitrusSoundGroup extends CitrusEventDispatcher
{
    public var mute(get, set) : Bool;
    public var volume(get, set) : Float;
    public var groupID(get, never) : String;

    
    public static inline var BGM : String = "BGM";
    public static inline var SFX : String = "SFX";
    public static inline var SFX2 : String = "SFX2";
    public static inline var UI : String = "UI";
    
    private var _groupID : String;
    
    @:allow(citrus.sounds)
    private var _volume : Float = 1;
    @:allow(citrus.sounds)
    private var _mute : Bool = false;
    
    private var _sounds : Array<CitrusSound>;
    
    public function new()
    {
        super();
        _sounds = new Array<CitrusSound>();
    }
    
    private function applyChanges() : Void {
        var s : CitrusSound;
        for (s in _sounds)
        {
            s.resetSoundTransform(true);
        }
    }
    
    @:allow(citrus.sounds)
    private function addSound(s : CitrusSound) : Void {
        if (s.group && s.group.isadded(s))
        {
            (try cast(s.group, CitrusSoundGroup) catch(e:Dynamic) null).removeSound(s);
        }
        s.setGroup(this);
        _sounds.push(s);
        s.addEventListener(CitrusSoundEvent.SOUND_LOADED, handleSoundLoaded);
		
		
    }
    
    @:allow(citrus.sounds)
    private function isadded(sound : CitrusSound) : Bool {
        var s : CitrusSound;
        for (s in _sounds)
        {
            if (sound == s){
                return true;
            }
        }
        return false;
    }
    
    public function getAllSounds() : Array<CitrusSound>{
        return _sounds.copy();
    }
    
    public function preloadSounds() : Void{
        var s : CitrusSound;
		var d:DelayedCall ;
		var time:Float;
        for (i in 0..._sounds.length) {
			s = _sounds[i];
            if (!s.loaded) {
				time = 0.005 * i;
				d = new DelayedCall(s.preLoad,time);
				Starling.current.juggler.add(d);
            }
        }
    }
    
    public function stopAllSounds() : Void{
        var s : CitrusSound;
        for (i in 0..._sounds.length) {
			s = _sounds[i];
			s.stop();
        }
    }
    
    @:allow(citrus.sounds)
    private function removeSound(s : CitrusSound) : Void {
      //  var si : String;
        var cs : CitrusSound;
        for (i in 0..._sounds.length)
        {
            if (_sounds[i] == s){
                cs = _sounds[i];
                cs.setGroup(null);
                cs.resetSoundTransform(true);
                cs.removeEventListener(CitrusSoundEvent.SOUND_LOADED, handleSoundLoaded);
                _sounds.splice(i, 1);
                break;
            }
        }
    }
    
    public function getSound(name : String) : CitrusSound
    {
        var s : CitrusSound;
        for (s in _sounds)
        {
            if (s.name == name){
                return s;
            }
        }
        return null;
    }
    
    public function getRandomSound() : CitrusSound
    {
        var index : Int = MathUtils.randomInt(0, _sounds.length - 1);
        return _sounds[index];
    }
    
    private function handleSoundLoaded(e : CitrusSoundEvent) : Void {
        var cs : CitrusSound;
        for (i in 0..._sounds.length)
        {
			cs = _sounds[i];
		     if (!cs.loaded){
                return;
            }
        }
        dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.ALL_SOUNDS_LOADED, e.sound, null));
    }
    
   public function set_mute(val : Bool) : Bool{
        _mute = val;
        applyChanges();
        return val;
    }
    
   public function get_mute() : Bool {
        return _mute;
    }
    
   public function set_volume(val : Float) : Float
    {
        _volume = val;
        applyChanges();
        return val;
    }
    
   public function get_volume() : Float
    {
        return _volume;
    }
    
   public function get_groupID() : String
    {
        return _groupID;
    }
    
    @:allow(citrus.sounds)
    private function destroy() : Void {
        var s : CitrusSound;
        for (s in _sounds)
        {
            removeSound(s);
        }
        as3hx.Compat.setArrayLength(_sounds, 0);
        removeEventListeners();
    }
}

