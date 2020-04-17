package citrus.sounds;

import citrus.sounds.groups.SpecialSFXGroup;
import flash.errors.Error;
import haxe.CallStack;
import haxe.Constraints.Function;
import starling.events.Event;

import citrus.events.CitrusEvent;
import citrus.events.CitrusSoundEvent;
import citrus.events.CitrusEventDispatcher;
import kaleidoEngine.data.utils.object.Objects;
import citrus.sounds.groups.BGMGroup;
import citrus.sounds.groups.SFXGroup;
import citrus.sounds.groups.UIGroup;
import flash.events.EventDispatcher;
import flash.media.SoundMixer;
import flash.media.SoundTransform;
import flash.utils.Dictionary;

class SoundManager extends CitrusEventDispatcher
{
    public var masterVolume(get, set) : Float;
    public var masterMute(get, set) : Bool;

    
    @:allow(citrus.sounds)
    private static var _instance : SoundManager;
    
    public var soundsDic : Dictionary<String,CitrusSound>;
    private var soundGroups : Array<CitrusSoundGroup>;
    
    private var _masterVolume : Float = 1;
    private var _masterMute : Bool = false;
    
    public function new()
    {
        super();
        
        soundsDic = new Dictionary<String,CitrusSound>();
        soundGroups = new Array<CitrusSoundGroup>();
      
        //default groups
        soundGroups.push(new BGMGroup());
        soundGroups.push(new SFXGroup());
        soundGroups.push(new UIGroup());
        soundGroups.push(new SpecialSFXGroup());
        
        addEventListener(CitrusSoundEvent.SOUND_LOADED, handleSoundLoaded);
    }
    
    public static function getInstance() : SoundManager
    {
        if (_instance == null)
        {
            _instance = new SoundManager();
        }
        
        return _instance;
    }
    
    public function destroy() : Void {
        var csg : CitrusSoundGroup;
        for (csg in soundGroups)
        {
            csg.destroy();
        }
        
     
		for (s in soundsDic)    
        {
          soundsDic[s].destroy();
        }
        
        soundsDic = null;
        _instance = null;
        
        removeEventListeners();
    }
    
    /**
		 * Register a new sound an initialize its values with the params objects. Accepted parameters are:
		 * <ul><li>sound : a url, a class or a Sound object.</li>
		 * <li>volume : the initial volume. the real final volume is calculated like so : volume x group volume x master volume.</li>
		 * <li>panning : value between -1 and 1 - unaffected by group or master.</li>
		 * <li>mute : default false, whether to start of muted or not.</li>
		 * <li>loops : default 0 (plays once) . -1 will loop infinitely using Sound.play(0,int.MAX_VALUE) and a positive value will use an event based looping system and events will be triggered from CitrusSoundInstance when sound complete and loops back</li>
		 * <li>permanent : by default set to false. if set to true, this sound cannot be forced to be stopped to leave room for other sounds (if for example flash soundChannels are not available) and cannot be played more than once . By default sounds can be forced to stop, that's good for sound effects. You would want your background music to be set as permanent.</li>
		 * <li>group : the groupID of a group, no groups are set by default. default groups ID's are CitrusSoundGroup.SFX (sound effects) and CitrusSoundGroup.BGM (background music)</li>
		 * </ul>
		 */
    public function addSound(id : String, params : Dynamic = null) : CitrusSound
    {
     	//trace("ADD SOUND:" + id);
		if (!Reflect.hasField(params,"sound"))
        {
		
			  throw new Error("SoundManager addSound() sound:" + id + "can't be added with no sound definition in the params.");
        }
        if (soundsDic[id]!=null)
        {
		
            //trace(this, id, "already exists.");
			return soundsDic[id];
        }
        else
        {
           return soundsDic[id] = new CitrusSound(id, params);

        }
	
    }

	
	public function soundLoopEvent(e:CitrusSoundEvent):Void {
		//trace("TOP DISPATCH SOUND EVENT");
		var event : Event = cast(new CitrusSoundEvent(CitrusSoundEvent.SOUND_LOOP, e.sound, e.soundInstance, e.soundID), Event);
		dispatchEvent(event);
	}
	
	public function soundEndEvent(e:CitrusSoundEvent):Void {
		//trace("TOP DISPATCH SOUND EVENT");
		var event : Event = cast(new CitrusSoundEvent(CitrusSoundEvent.SOUND_END, e.sound, e.soundInstance, e.soundID), Event);
		dispatchEvent(event);
	}
    
    /**
		 * add your own custom CitrusSoundGroup here.
		 */
    public function addGroup(group : CitrusSoundGroup) : Void {
        soundGroups.push(group);
    }
    
    /**
		 * removes a group and detaches all its sounds - they will now have their default volume modulated only by masterVolume
		 */
    public function removeGroup(groupID : String) : Void {
        var g : CitrusSoundGroup = getGroup(groupID);
        var i : Int = soundGroups.lastIndexOf(g);
        if (i > -1)
        {
            soundGroups.splice(i, 1);
            g.destroy();
        }
        else
        {
            trace("Sound Manager : group", groupID, "not found for removal.");
        }
    }
    
    /**
		 * moves a sound to a group - if groupID is null, sound is simply removed from any groups
		 * @param	soundName 
		 * @param	groupID ("BGM", "SFX" or custom group id's)
		 */
    public function moveSoundToGroup(soundName : String, groupID : String = null) : Void {
        var s : CitrusSound;
        var g : CitrusSoundGroup;
        if (soundsDic[soundName]!=null)
        {
            s = soundsDic[soundName];
            if (s.group != null){
                s.group.removeSound(s);
            }
            if (groupID != null){
                g = getGroup(groupID);
           
				if (g != null)
				{
					g.addSound(s);
				}
			}
        }
        else
        {
            trace(this, "moveSoundToGroup() : sound", soundName, "doesn't exist.");
        }
    }
    
    /**
		 * return group of id 'name' , defaults would be SFX or BGM
		 * @param	name
		 * @return CitrusSoundGroup
		 */
    public function getGroup(name : String) : CitrusSoundGroup
    {
        var sg : CitrusSoundGroup;
        for (sg in soundGroups)
        {
            if (sg.groupID == name){
                return sg;
            }
        }
        trace(this, "getGroup() : group", name, "doesn't exist.");
        return null;
    }
    
    /**
		 * returns a CitrusSound object. you can use this reference to change volume/panning/mute or play/pause/resume/stop sounds without going through SoundManager's methods.
		 */
    public function getSound(name : String) : CitrusSound
    {
        if (soundsDic[name]!=null)
        {
            return soundsDic[name];
        }
        else
        {
            trace(this, "getSound() : sound", name, "doesn't exist.");
        }
        return null;
    }  
    
	public function getSoundInstance(name : String,instance:Int=0) : CitrusSoundInstance
    {
        if (soundsDic[name]!=null)
        {
            return soundsDic[name].getSoundInstance();
        }
        else
        {
            trace(this, "getSound() : sound", name, "doesn't exist.");
        }
        return null;
    }
    
    public function preloadAllSounds() : Void {
       for (cs in soundsDic){
			soundsDic[cs].load();
       }
    }
    
    /**
		 * pauses all playing sounds
		 */
    public function pauseAll() : Void {
        for (soundID in soundsDic) {
			var s:CitrusSound = soundsDic[soundID];
			 s.pause();
		}	
           
		
		
    }
    
    /**
		 * resumes all paused sounds
		 */
    public function resumeAll() : Void {
		//trace("RESUME ALL SOUNDS(INI)");
		for (soundID in soundsDic) {
			var s:CitrusSound = soundsDic[soundID];
            s.resume();
        }	
		//trace("RESUME ALL SOUNDS(END)");

    }
    
    public function playSound(id : String) : CitrusSoundInstance
    {
		//trace("playSound:" + id);
        if (soundsDic[id]!=null)
        {
			return soundsDic[id].play();
			
        }
        else
        {
            trace(this, "playSound() : sound [", id, "] doesn't exist.");
        }
        return null;
    }
    
    public function pauseSound(id : String) : Void {
        if (soundsDic[id]!=null){
            soundsDic[id].pause();
        }else{
            trace(this, "pauseSound() : sound [" + id + "] doesn't exist.");
			trace("SOUND NOT THERE. CALL:"+CallStack.toString(CallStack.callStack()));
        }
    }
    
    public function resumeSound(id : String) : Void {
        if (soundsDic[id]!=null)
        {
            soundsDic[id].resume();
        }
        else
        {
            trace(this, "resumeSound() : sound ["+ id+ "] doesn't exist.");
        }
    }
    
    public function stopSound(id : String) : CitrusSound
    {
        if (soundsDic[id]!=null)
        {
           soundsDic[id].stop();
		   return soundsDic[id];
        }
        else
        {
            trace(this, "stopSound() : sound ["+ id+ "] doesn't exist.");
        }
		return null;
    }
    
    public function removeSound(id : String) : CitrusSound
    {
        var cs:CitrusSound = stopSound(id);
        if (soundsDic[id]!=null)
        {
			if (cs.canBeRemoved){
				soundsDic[id].destroy();
				Objects.removeKey(soundsDic, id);
				//trace("SONG REMOVED:" + id);	
			}else {
				//trace("NOPE CAN'T BE REMOVED:" + id);	
			}
        }
        else
        {
            trace(this, "removeSound() : sound [" + id + "] doesn't exist.");
			trace("STACK:" + CallStack.callStack().toString());
        }
		
		return cs;
    }
    
    public function soundIsPlaying(sound : String) : Bool {
        if (soundsDic[sound]!=null)
        {
           return soundsDic[sound].isPlaying;
        }
        else
        {
            trace(this, "soundIsPlaying() : sound [", sound, "] doesn't exist.");
        }
        return false;
    }
    
    public function soundIsPaused(sound : String) : Bool {
        if (soundsDic[sound]!=null){
            return soundsDic[sound].isPaused;
        } else{
            trace(this, "soundIsPaused() : sound [", sound, "] doesn't exist.");
			trace("SOUND NOT THERE. CALL:"+CallStack.toString(CallStack.callStack()));
        }
        return false;
    }
    
    public function removeAllSounds(except : Array<String> = null) : Void {
		var killSound:Bool = false;
        for (cs in soundsDic){
			var cs_name:String = soundsDic[cs].name;
            killSound = true;
            
            for (soundToPreserve in except){
                if (soundToPreserve == cs_name)
                {
                    killSound = false;
                    break;
                }
            }
            if (killSound){
                removeSound(cs_name);
            }
        }
    }
    
   public function get_masterVolume() : Float
    {
        return _masterVolume;
    }
    
   public function get_masterMute() : Bool {
        return _masterMute;
    }
    
    /**
		 * sets the master volume : resets all sound transforms to masterVolume*groupVolume*soundVolume
		 */
   public function set_masterVolume(val : Float) : Float
    {
        var tm : Float = _masterVolume;
        if (val >= 0 && val <= 1)
        {
            _masterVolume = val;
        }
        else
        {
            _masterVolume = 1;
        }
        
        if (tm != _masterVolume)
        {
            var s : String;
            for (s in soundsDic){
               soundsDic[s].resetSoundTransform(true);
            }
        }
        return val;
    }
    
    /**
		 * sets the master mute : resets all sound transforms to volume 0 if true, or 
		 * returns to normal volue if false : normal volume is masterVolume*groupVolume*soundVolume
		 */
   public function set_masterMute(val : Bool) : Bool {
        if (val != _masterMute)
        {
            _masterMute = val;
            var s : String;
            for (s in soundsDic){
               soundsDic[s].resetSoundTransform(true);
            }
        }
        return val;
    }
    
    /**
		 * tells if the sound is added in the list.
		 * @param	id
		 * @return
		 */
    public function soundIsAdded(id : String) : Bool {
        return (soundsDic[id]!=null);
    }
    
    /**
		 * Cut the SoundMixer. No sound will be heard.
		 */
    public function muteFlashSound(mute : Bool = true) : Void {
        var s : SoundTransform = SoundMixer.soundTransform;
        s.volume = (mute) ? 0 : 1;
        SoundMixer.soundTransform = s;
    }
    
    /**
		 * set volume of an individual sound (its group volume and the master volume will be multiplied to it to get the final volume)
		 */
    public function setVolume(id : String, volume : Float) : Void {
        if (soundsDic[id]!=null)
        {
            soundsDic[id].volume = volume;
        }
        else
        {
            trace(this, "setVolume() : sound", id, "doesn't exist.");
        }
    }
    
    /**
		 * set pan of an individual sound (not affected by group or master
		 */
    public function setPanning(id : String, panning : Float) : Void {
        if (soundsDic[id]!=null)
        {
            soundsDic[id].panning = panning;
        }
        else
        {
            trace(this, "setPanning() : sound", id, "doesn't exist.");
        }
    }
    
    /**
		 * set mute of a sound : if set to mute, neither the group nor the master volume will affect this sound of course.
		 */
    public function setMute(id : String, mute : Bool) : Void {
        if (soundsDic[id]!=null)
        {
           soundsDic[id].mute = mute;
        }
        else
        {
            trace(this, "setMute() : sound", id, "doesn't exist.");
        }
    }
    
    /**
		 * Stop playing all the current sounds.
		 * @param except an array of soundIDs you want to preserve.
		 */
    public function stopAllPlayingSounds(except : Array<String> = null) : Void {
        //var killSound : Bool;

      	for (cs in soundsDic){
			var cs_name:String = cs;
			 stopSound(cs_name);
			//except not implemented
        }
    }
    //ORIGINAL
    /*public function stopAllPlayingSounds(...except):void {
			
			var killSound:Boolean;
			var cs:CitrusSound;
			loop1:for each(cs in soundsDic) {
					
				for each (var soundToPreserve:String in except)
					if (soundToPreserve == cs.name)
						break loop1;
				
					stopSound(cs.name);
			}
		}*/
    
    /**
		 * tween the volume of a CitrusSound. If callback is defined, its optional argument will be the CitrusSound.
		 * @param	id
		 * @param	volume
		 * @param	tweenDuration
		 * @param	callback
		 */
    public function tweenVolume(id : String, volume : Float = 0, tweenDuration : Float = 2, callback : Function = null) : Void {  /*if (soundIsPlaying(id)) {
				
				var citrusSound:CitrusSound = CitrusSound(soundsDic[id]);
				var tweenvolObject:Object = {volume:citrusSound.volume};
				
				eaze(tweenvolObject).to(tweenDuration, {volume:volume})
					.onUpdate(function():void {
					citrusSound.volume = tweenvolObject.volume;
				}).onComplete(function():void
				{
					
					if (callback != null)
						if (callback.length == 0)
							callback();
						else
							callback(citrusSound);
				});
			} else 
				trace("the sound " + id + " is not playing");*/  
        
    }
    
    public function crossFade(fadeOutId : String, fadeInId : String, tweenDuration : Float = 2) : Void {
        tweenVolume(fadeOutId, 0, tweenDuration);
        tweenVolume(fadeInId, 1, tweenDuration);
    }
	
	
    private function handleSoundLoaded(e : CitrusSoundEvent) : Void {
		
		 for (soundID in soundsDic) {
			var s:CitrusSound = soundsDic[soundID];
			if (!s.loaded) return ;
        }	

        dispatchEvent(new CitrusSoundEvent(CitrusSoundEvent.ALL_SOUNDS_LOADED, e.sound, null));
    }
}

