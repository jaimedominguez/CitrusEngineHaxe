package citrus.view.starlingview;

import flash.errors.Error;
import citrus.core.CitrusEngine;
import citrus.core.starling.StarlingCitrusEngine;
import haxe.CallStack;
import kaleidoEngine.debug.StackTrace;
import starling.core.Starling;
import starling.display.Sprite3D;
import starling.filters.FragmentFilter;
import kaleidoEngine.data.utils.object.Objects;
import msignal.Signal;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.TextureAtlas;
import starling.display.MovieClip;
import flash.utils.Dictionary;

/**
	 * The Animation Sequence class represents all object animations in one sprite sheet. You have to create your texture atlas in your state class.
	 * Example : <code>var hero:Hero = new Hero("Hero", {x:400, width:60, height:130, view:new AnimationSequence(textureAtlas, ["walk", "duck", "idle", "jump"], "idle")});</code>
	 * <b>Important:</b> for managing if an animation should loop, you've to set it up at <code>StarlingArt.setLoopAnimations(["fly", "fallen"])</code>. By default, the walk's 
	 * animation is the only one looping.
	 */
class AnimationSequence extends Sprite3D
{
    public var mcSequences(get, never) : Dictionary<String,MovieClip>;

    
    /**
		 * The signal is dispatched each time an animation is completed, giving the animation name as argument.
		 */
    public var onAnimationComplete : Signal1<String>;
    
    private var _ce : StarlingCitrusEngine;
    private var _textureAtlas : TextureAtlas;
    private var _animations : Array<String>;
    private var _firstAnimation : String;
    private var _animFps : Float;
    private var _firstAnimLoop : Bool;
    private var _smoothing : String;
    
    private var _mcSequences : Dictionary<String,MovieClip>;
    private var _previousAnimation : String;
	public var currentAnimationMC:MovieClip;
    
    /**
		 * @param textureAtlas a TextureAtlas or an AssetManager object with your object's animations you would like to use.
		 * @param animations an array with the object's animations as a String you would like to pick up.
		 * @param firstAnimation a string of your default animation at its creation.
		 * @param animFps a number which determines the animation MC's fps.
		 * @param firstAnimLoop a boolean, set it to true if you want your first animation to loop.
		 * @param smoothing a string indicating the smoothing algorithms used for the AnimationSequence, default is bilinear.
		 */
    public function new(textureAtlas : TextureAtlas, animations : Array<String>, firstAnimation : String, animFps : Float = 30, firstAnimLoop : Bool = false, smoothing : String = "bilinear")
    {
        super();
        
        _ce = cast(CitrusEngine.getInstance(), StarlingCitrusEngine);
        
        onAnimationComplete = new Signal1(String);
        
        _textureAtlas = textureAtlas;
        _animations = animations;
        _firstAnimation = firstAnimation;
        _animFps = animFps;
        _firstAnimLoop = firstAnimLoop;
        _smoothing = smoothing;
        
        _mcSequences = new Dictionary<String,MovieClip>();
        
        addTextureAtlasWithAnimations(_textureAtlas, _animations);
        
        addChild(_mcSequences[_firstAnimation]);
   
        Starling.current.juggler.add(_mcSequences[_firstAnimation]);
        _mcSequences[_firstAnimation].loop = _firstAnimLoop;
        currentAnimationMC = _mcSequences[_firstAnimation];
	    
		__setIs3D(false);
        _previousAnimation = _firstAnimation;
		touchable = false;
		
	//	trace("NEW ANIMATION-ESQUENCE @fps" + _animFps);
    }
	
	public function set3D(state:Bool):Void {
		__setIs3D(state);
	}
    
    /**
		 * It may be useful to add directly a MovieClip instead of a Texture Atlas to enable its manipulation like an animation's reversion for example.
		 * Be careful, if you <code>clone</code> the AnimationSequence it's not taken into consideration.
		 * @param mc a MovieClip you would like to use.
		 * @param animation the object's animation name as a String you would like to pick up.
		 */
    public function addMovieClip(mc : MovieClip, animation : String) : Void {
        if (_mcSequences[animation] != null)
        {
            throw new Error(this + " already have the " + animation + " animation set up in its animations' array");
        }
        var thisSequence:MovieClip = _mcSequences[animation] = mc;
		thisSequence.name = animation;
		thisSequence.addEventListener(Event.COMPLETE, _animationComplete);
        thisSequence.smoothing = _smoothing;
		thisSequence.fps = cast(_animFps, Int);
		//trace("***ADD SEQ-ANIM[" + animation + "] @fps" + _animFps);
    }
    
    /**
		 * If you need more than one TextureAtlas for your character's animations, use this function. 
		 * Be careful, if you <code>clone</code> the AnimationSequence it's not taken into consideration.
		 * @param textureAtlas a TextureAtlas object with your object's animations you would like to use.
		 * @param animations an array with the object's animations as a String you would like to pick up.
		 */
    public function addTextureAtlasWithAnimations(textureAtlas : TextureAtlas, animations : Array<String>) : Void {
        for (animation in animations)
        {
            if (textureAtlas.getTextures(animation).length == 0){
                throw new Error(textureAtlas + " doesn't have the " + animation + " animation in its TextureAtlas");
            }
           
            var thisSequence:MovieClip = _mcSequences[animation] = new MovieClip(textureAtlas.getTextures(animation), _animFps );

            thisSequence.name = animation;
            thisSequence.addEventListener(Event.COMPLETE, _animationComplete);
            thisSequence.smoothing = _smoothing;
			
			
        }
    }
	
    
    /**
		 * You may want to remove animations from the AnimationSequence, use this function.
		 * Be careful, if you <code>clone</code> the AnimationSequence it's not taken into consideration.
		 * @param animations an array with the object's animations as a String you would like to remove.
		 */
    public function removeAnimations(animations : Array<String>) : Void {
        for (animation in animations)
        {
            if (_mcSequences[animation] == null){
                throw new Error(this.parent.name + " doesn't have the " + animation + " animation set up in its animations' array");
            }
            _mcSequences[animation].removeEventListener(Event.COMPLETE, _animationComplete);
            _mcSequences[animation].removeFromParent(true);
			//dispose();
            Objects.removeKey(_mcSequences, animation);
        }
    }
    
    public function removeAllAnimations() : Void {
        removeAnimations(_animations);
    }
    
    /**z
		 * Called by StarlingArt, managed the MC's animations. If your object is a CitrusObject you should 
		 * manage its animation via object's <code>animation</code> variable.
		 * @param animation the MC's animation
		 * @param animLoop true if the MC is a loop
		 */
    public function changeAnimation(animation : String, animLoop : Bool) : Void {
		if (_mcSequences == null) {
			trace("TRIED TO PLAY " + animation + " animation. But there aren't any animations AT ALL.");
			StackTrace.traceCallCrop();
			return;
		}
		
		if (_mcSequences[animation] == null)
        {
            throw new Error(this.parent.name + " doesn't have the " + animation + " animation set up in its animations' array");
        }
       
        removeChild(_mcSequences[_previousAnimation]);
        Starling.current.juggler.remove(_mcSequences[_previousAnimation]);
        
        addChild(_mcSequences[animation]);
        Starling.current.juggler.add(_mcSequences[animation]);
        _mcSequences[animation].loop = animLoop;
        _mcSequences[animation].currentFrame = 0;
        _previousAnimation = animation;
		
		currentAnimationMC =  _mcSequences[animation];
		
		//trace("*CHANGE ANIM[" + animation + "] @fps" +  _mcSequences[animation].fps);
    }
    
    /**
		 * Called by StarlingArt, remove or add to the Juggler if the Citrus Engine is playing or not.
		 */
    public function pauseAnimation(value : Bool) : Void {
        (value) ?  Starling.current.juggler.add(_mcSequences[_previousAnimation]) :  Starling.current.juggler.remove(_mcSequences[_previousAnimation]);
    }
    
    public function destroy() : Void {
        onAnimationComplete.removeAll();
        if (_mcSequences != null) {
            removeChild(_mcSequences[_previousAnimation]);
            Starling.current.juggler.remove(_mcSequences[_previousAnimation]);
        
            removeAllAnimations();
            _mcSequences = null;
        }
		
		this.removeFromParent(true);
    }
    
    /**
		 * A dictionary containing all animations registered thanks to their string name.
		 */
   public function get_mcSequences() : Dictionary<String,MovieClip>
    {
        return _mcSequences;
    }
   
    /**
		 * returns a vector of all animation names in this AnimationSequence.
		 */
    public function getAnimationNames() : Array<String>
    {
        var names : Array<String> = new Array<String>();
        var name : String = "";
        for (name in _mcSequences)
        {
            names.push(name);
        }
        return names;
    }
    
    /**
		 * Return a clone of the current AnimationSequence. Animations added via <code>addMovieClip</code> or <code>addTextureAtlasWithAnimations</code> aren't included.
		 */
    public function clone() : AnimationSequence
    {
        return new AnimationSequence(_textureAtlas, _animations, _firstAnimation, _animFps, _firstAnimLoop, _smoothing);
    }
    
    private function _animationComplete(evt : Event) : Void {
		onAnimationComplete.dispatch(cast(evt.target, MovieClip).name);
    }
}

