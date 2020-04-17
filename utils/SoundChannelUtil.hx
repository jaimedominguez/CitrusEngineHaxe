package citrus.utils;

import citrus.events.CitrusSoundEvent;
import citrus.sounds.CitrusSound;
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.utils.ByteArray;

class SoundChannelUtil
{
    public static var silentST(get, never) : SoundTransform;
    public static var soundCheck(get, never) : Sound;
    public static var silentSound(get, never) : Sound;

    private static var _soundCheck : Sound;
    private static var soundChannel : SoundChannel;
    
    private static var _silentSound : Sound;
    private static var silentChannel : SoundChannel;
    
    private static var _silentSoundTransform : SoundTransform = new SoundTransform(0, 0);
    
    public static function hasAvailableChannel() : Bool {
        soundChannel = soundCheck.play(0, 0, silentST);
        
        if (soundChannel != null)
        {
            soundChannel.stop();
            soundChannel = null;
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public static function maxAvailableChannels() : Int
    {
        var channels : Array<SoundChannel> = new Array<SoundChannel>();
        var len : Int = 0;
        
        while ((soundChannel = soundCheck.play(0, 0, silentST)) != null)
        {
            channels.push(soundChannel);
        }
        
        len = channels.length;
        
        while ((soundChannel = channels.pop()) != null)
        {
            soundChannel.stop();
        }
        
        as3hx.Compat.setArrayLength(channels, 0);
        
        //we remove two to avoid some problems.
        len -= 2;
        
        return len;
    }
    
    private static function get_silentST() : SoundTransform
    {
        return _silentSoundTransform;
    }
    
    private static function get_soundCheck() : Sound
    {
        if (_soundCheck == null)
        {
            _soundCheck = generateSound();
        }
        return _soundCheck;
    }
    
    private static function get_silentSound() : Sound
    {
        if (_silentSound == null)
        {
            _silentSound = generateSound(2048, 0);
        }
        return _silentSound;
    }
    
    public static function playSilentSound() : Bool {
        if (silentChannel != null)
        {
            return false;
        }
        silentChannel = silentSound.play(0, as3hx.Compat.INT_MAX, silentST);
        if (silentChannel != null)
        {
            silentChannel.addEventListener(CitrusSoundEvent.SOUND_COMPLETE, silentComplete);
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public static function stopSilentSound() : Void {
        if (silentChannel != null)
        {
            silentChannel.stop();
            silentChannel.removeEventListener(CitrusSoundEvent.SOUND_COMPLETE, silentComplete);
            silentChannel = null;
        }
    }
    
    private static function generateSound(length : Int = 1, val : Float = 1.0) : Sound
    {
        var sound : Sound = new Sound();
        var soundBA : ByteArray = new ByteArray();
        var i : Int = 0;
        while (i < length)
        {
            soundBA.writeFloat(val);
            i++;
        }
        soundBA.position = 0;
        sound.loadPCMFromByteArray(soundBA, 1, "float", false, 44100);
        return sound;
    }
    
    private static function silentComplete(e : Event) : Void {
        silentChannel = silentSound.play(0, as3hx.Compat.INT_MAX, silentST);
    }

    public function new()
    {
    }
}

