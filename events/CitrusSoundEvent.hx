package citrus.events;

import citrus.events.CitrusEvent;
import citrus.sounds.CitrusSound;
import citrus.sounds.CitrusSoundInstance;
import starling.events.Event;

class CitrusSoundEvent extends Event
{
    
    /**
		 * CitrusSound related events
		 */
    
    public static inline var SOUND_ERROR : String = "SOUND_ERROR";
    public static inline var SOUND_LOADED : String = "SOUND_LOADED";
    public static inline var ALL_SOUNDS_LOADED : String = "ALL_SOUNDS_LOADED";
    
    /**
		 * CitrusSoundInstance related events
		 */
    
    /**
		 * dispatched when a sound instance starts playing
		 */
    public static inline var SOUND_START : String = "SOUND_START";
    /**
		 * dispatched when a sound instance pauses
		 */
    public static inline var SOUND_PAUSE : String = "SOUND_PAUSE";
    /**
		 * dispatched when a sound instance resumes
		 */
    public static inline var SOUND_RESUME : String = "SOUND_RESUME";
    /**
		 * dispatched when a sound instance loops (not when it loops indifinately)
		 */
    public static inline var SOUND_LOOP : String = "SOUND_LOOP";
    /**
		 * dispatched when a sound instance ends
		 */
    public static inline var SOUND_END : String = "SOUND_END";
    static public inline var SOUND_COMPLETE:String = "SOUND_COMPLETE";
    /**
		 * dispatched when no sound channels are available for a sound instance to start
		 */
    public static inline var NO_CHANNEL_AVAILABLE : String = "NO_CHANNEL_AVAILABLE";
    /**
		 * dispatched when a non permanent sound instance is forced to stop
		 * to leave room for a new one.
		 */
    public static inline var FORCE_STOP : String = "FORCE_STOP";
    /**
		 * dispatched when a sound instance tries to play but CitrusSound is not ready
		 */
    public static inline var SOUND_NOT_READY : String = "SOUND_NOT_READY";
    
    /**
		 * dispatched on any CitrusSoundEvent
		 */
    public static inline var EVENT : String = "EVENT";
    
    public var soundName : String;
    public var soundID : Int;
    public var sound : CitrusSound;
    public var soundInstance : CitrusSoundInstance;
    public var loops : Int = 0;
    public var loopCount : Int = 0;
    public var loadedRatio : Float;
    public var loaded : Bool;
    public var error : Bool;

    public function new(type : String, sound : CitrusSound, soundinstance : CitrusSoundInstance, soundID : Int = -1, bubbles : Bool = true)
    {
        //super(type, bubbles,canceable);
        super(type, bubbles);
        
        if (sound != null)
        {
            this.sound = sound;
            soundName = sound.name;
            loadedRatio = sound.loadedRatio;
            loaded = sound.loaded;
            error = sound.ioerror;
        }
        
        if (soundinstance != null)
        {
            this.soundInstance = soundinstance;
            loops = soundinstance.loops;
            loopCount = soundinstance.loopCount;
        }
        
        this.soundID = soundID;
        
        if (type == SOUND_ERROR || type == SOUND_LOADED || type == ALL_SOUNDS_LOADED)
        {
            setTarget(sound);
        }
        else
        {
            setTarget(soundinstance);
        }
    }
    
    public function clone() : CitrusEvent
    {
        //return try cast(new CitrusSoundEvent(type, sound, soundInstance, soundID, bubbles, cancelable), CitrusEvent) catch (e:Dynamic) null;
		 return cast(new CitrusSoundEvent(type, sound, soundInstance, soundID, bubbles), CitrusEvent);
    }
    
    override public function toString() : String
    {
        return "[CitrusSoundEvent type: " + type + " sound: \"" + soundName + "\" ID: " + soundID + " loopCount: " + loopCount + " loops: " + loops + " ]";
    }
}

