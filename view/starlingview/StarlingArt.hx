package citrus.view.starlingview;

import citrus.view.starlingview.AnimationSequence;
import haxe.CallStack;
import kaleidoEngine.debug.InObject;
import flash.errors.Error;
import citrus.core.CitrusEngine;
import citrus.core.CitrusObject;
import citrus.core.IState;
import citrus.core.starling.StarlingCitrusEngine;
import citrus.physics.APhysicsEngine;
import citrus.physics.IDebugView;
import citrus.system.components.ViewComponent;
import citrus.view.ACitrusCamera;
import citrus.view.ACitrusView;
import citrus.view.ICitrusArt;
import citrus.view.ISpriteView;
import openfl.utils.Dictionary;
import openfl.utils.Object;
import starling.extensions.PDParticleSystem;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Quad;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.utils.MathUtil;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
//import flash.utils.Dictionary;

//	import dragonBones.Armature;
//	import dragonBones.animation.WorldClock;
//import starling.extensions.particles.PDParticleSystem;
/**
	 * This is the class that all art objects use for the StarlingView state view. If you are using the StarlingView (as opposed to the blitting view, for instance),
	 * then all your graphics will be an instance of this class. 
	 * <ul>There are 2 ways to manage MovieClip/animations :
	 * <li>specify a "object.swf" in the view property of your object's creation.</li>
	 * <li>add an AnimationSequence to your view property of your object's creation, see the AnimationSequence for more information about it.</li>
	 * The AnimationSequence is more optimized than the .swf (which creates textures "on the fly" thanks to the DynamicAtlas class). You can also use the awesome 
	 * <a href="http://dragonbones.github.com/">DragonBones</a> 2D skeleton animation solution.</ul>
	 * 
	 * <ul>This class does the following things:
	 * 
	 * <li>Creates the appropriate graphic depending on your CitrusObject's view property (loader, sprite, or bitmap), and loads it if it is a non-embedded graphic.</li>
	 * <li>Aligns the graphic with the appropriate registration (topLeft or center).</li>
	 * <li>Calls the MovieClip's appropriate frame label based on the CitrusObject's animation property.</li>
	 * <li>Updates the graphic's properties to be in-synch with the CitrusObject's properties once per frame.</li></ul>
	 * 
	 * <p>These objects will be created by the Citrus Engine's StarlingView, so you should never make them yourself. When you use <code>view.getArt()</code> to gain access to your game's graphics
	 * (for adding click events, for instance), you will get an instance of this object. It extends Sprite, so you can do all the expected stuff with it, 
	 * such as add click listeners, change the alpha, etc.</p>
	 **/
class StarlingArt extends Sprite implements ICitrusArt
{
    public var content(get, never) : starling.display.DisplayObject;
    public static var loopAnimation(get, never) : Dictionary<String,Bool>;
    public var registration(get, set) : String;
    public var view(get, set) : Dynamic;
    public var animation(get, set) : String;
    public var citrusObject(get, never) : ISpriteView;
    public var updateArtEnabled(get, set) : Bool;

    
    // The reference to your art via the view.
    private var _content : starling.display.DisplayObject;
    
    /**
		 * For objects that are loaded at runtime, this is the object that load them. Then, once they are loaded, the content
		 * property is assigned to loader.content.
		 */
    public var loader : Loader;
    private static var _loopAnimation : Dictionary<String,Bool> = new Dictionary<String,Bool>();
    
    private static var _m : Matrix = new Matrix();
    
    private var _ce : StarlingCitrusEngine;
    
    private var _citrusObject : ISpriteView;
    private var _physicsComponent : Dynamic;
    private var _registration : String;
    private var _view : Dynamic;
    private var _animation : String;
    public var group : Int;
    
    private var _texture : Texture;
    
    private var _viewHasChanged : Bool = false;  // when the view changed, the animation wasn't updated if it was the same name. This var fix that.  
    private var _updateArtEnabled : Bool = true;
    
    public function new(object : ISpriteView = null)
    {
        super();
        
        _ce = cast(CitrusEngine.getInstance(), StarlingCitrusEngine);
        
        if (object != null)
        {
            initialize(object);
        }
    }
    
    public function initialize(object : ISpriteView) : Void {
        _citrusObject = object;
        
        _ce.onPlayingChange.add(_pauseAnimation);
        
        var ceState : IState = _ce.state;
        
        //if (Std.is(_citrusObject, ViewComponent) && cast(ceState.getFirstObjectByType(APhysicsEngine), APhysicsEngine))
        if (Std.is(_citrusObject, ViewComponent) && cast(ceState.getFirstObjectByType(APhysicsEngine), APhysicsEngine)!=null)
        {
            _physicsComponent = cast(_citrusObject, ViewComponent).entity.lookupComponentByName("physics");
			trace("WAS PHYSICS:"+_physicsComponent);
        }
		
        name = cast(_citrusObject, CitrusObject).name;
       
    }
    
    /**
		 * The content property is the actual display object that your game object is using. For graphics that are loaded at runtime
		 * (not embedded), the content property will not be available immediately. You can listen to the COMPLETE event on the loader
		 * (or rather, the loader's contentLoaderInfo) if you need to know exactly when the graphic will be loaded.
		 */
   public function get_content() : starling.display.DisplayObject
    {
        return _content;
    }
    
    public function destroy() : Void {
        if (_viewHasChanged)
        {
			
            removeChild(_content);
        }
        else
        {
            _ce.onPlayingChange.remove(_pauseAnimation);
        }
        
        if (Std.is(_content, starling.display.MovieClip))
        {
            Starling.current.juggler.remove(try cast(_content, starling.display.MovieClip) catch(e:Dynamic) null);
          //  _ce.juggler.remove(try cast(_content, starling.display.MovieClip) catch(e:Dynamic) null);
            _content.dispose();
        }
        else if (Std.is(_content, AnimationSequence))
        {
            cast(_content, AnimationSequence).destroy();
            _content.dispose();
        }
        else if (Std.is(_content, Image))
        {
            if (_texture != null){
                _texture.dispose();
            }
            
            _content.dispose();
        }
        else if (Std.is(_content, PDParticleSystem))
        {
            Starling.current.juggler.remove(try cast(_content, PDParticleSystem) catch(e:Dynamic) null);
           // _ce.juggler.remove(try cast(_content, PDParticleSystem) catch(e:Dynamic) null);
            (try cast(_content, PDParticleSystem) catch(e:Dynamic) null).stop();
            _content.dispose();
        }
        /* else if (_content is StarlingTileSystem) {
				(_content as StarlingTileSystem).destroy();
				_content.dispose();

			} else if (_view is Armature) {
				WorldClock.clock.remove(_view);
				(_view as Armature).dispose();
				_content.dispose();

			}*/
        else if (Std.is(_content, starling.display.DisplayObject))
        {
            _content.dispose();
        }else {
			//trace("DESTROY STARLING ART NOT WORKING-------------------------");	
			//trace(CallStack.callStack().toString());
		}
        
        _viewHasChanged = false;
    }
    
    /**
		 * Add a loop animation to the Dictionnary.
		 * @param tab an array with all the loop animation names.
		 */
    public static function setLoopAnimations(tab : Array<String>) : Void {
        for (animation in tab)
        {
            _loopAnimation[animation] = true;
        }
    }
    
    /**
		 * Determines animations playing in loop. You can add one in your state class: <code>StarlingArt.setLoopAnimations(["walk", "climb"])</code>;
		 */
    private static function get_loopAnimation() : Dictionary<String,Bool>
    {
        return _loopAnimation;
    }
    
    public function moveRegistrationPoint(registrationPoint : String) : Void {
        if (registrationPoint == "topLeft")
        {
            _content.x = 0;
            _content.y = 0;
        }
        else if (registrationPoint == "center")
        {
            _content.x = -_content.width / 2;
            _content.y = -_content.height / 2;
        }
    }
    
    /**
		 * align suggestion wip
		 */
    private static var rectBounds : Rectangle = new Rectangle();
    public function align(mulX : Float = .5, mulY : Float = .5, offX : Float = 0, offY : Float = 0) : Void {
        if (_content.parent == this)
        {
            _content.getBounds(this, rectBounds);
        }
        else
        {
            rectBounds.setTo(0, 0, 0, 0);
        }
        
        _content.x = -rectBounds.x - rectBounds.width * mulX + offX;
        _content.y = -rectBounds.y - rectBounds.height * mulY + offY;
    }
    
   public function get_registration() : String
    {
        return _registration;
    }
    
   public function set_registration(value : String) : String
    {
        if (_registration == value || _content == null)
        {
            return value;
        }
        
        _registration = value;
        
        moveRegistrationPoint(_registration);
        return value;
    }
    
   public function get_view() : Dynamic
    {
        return _view;
    }
    
   public function set_view(value : Dynamic) : Dynamic
    {
		
		//trace ("SET VIEW DEBUG?:!"+value);
		
		
		//InObject.extract(value);
		
        if (_view == value)
        {
            return value;
        }
        
        if (_content != null && _content.parent!=null)
        {
            _viewHasChanged = true;
            _citrusObject.handleArtChanged(try cast(this, ICitrusArt) catch(e:Dynamic) null);
            destroy();
            _content = null;
        }
        
        _view = value;
        
        if (_view != null)
        {
            var tmpObj : Dynamic;
            var contentChanged : Bool = true;
            
            if (Std.is(_view, String)){
            // view property is a path to an image?{
                
                var classString : String = _view;
                var suffix : String = classString.substring(classString.length - 4).toLowerCase();
                var url : URLRequest = new URLRequest(classString);
                
                if (suffix == ".swf" || suffix == ".png" || suffix == ".gif" || suffix == ".jpg")
                {
                    loader = new Loader();
                    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleContentLoaded);
                    loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleContentIOError);
                    loader.load(url, new LoaderContext(false, ApplicationDomain.currentDomain, null));
                    return value;
                }
                else if (suffix == ".atf")
                {
                    var urlLoader : URLLoader = new URLLoader();
                    urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
                    urlLoader.addEventListener(Event.COMPLETE, handleBinaryContentLoaded);
                    urlLoader.load(url);
                    return value;
                }
                // view property is a fully qualified class name in string form.
                else
                {
                    var artClass : Class<Dynamic>;
                    try
                    {
                        artClass = Type.getClass(Type.resolveClass(classString));
                    }
                    catch (e : Error)
                    {
                        throw new Error("[StarlingArt] could not find class definition for \"" + classString + "\". \n Make sure that you compile it with the project or that its the right classpath.");
                    }
                    
                    tmpObj = Type.createInstance(artClass,[]);
                    
                   /* if (Std.is(tmpObj, flash.display.MovieClip))
                    {
                        _content = AnimationSequence.fromMovieClip(tmpObj, _animation, 30);
                    }
                    else */
					
					if (Std.is(tmpObj, flash.display.Bitmap))
                    {
                        _content = new Image(_texture = Texture.fromBitmap(tmpObj, false, false, _ce.scaleFactor));
                    }
                    else if (Std.is(tmpObj, BitmapData))
                    {
                        _content = new Image(_texture = Texture.fromBitmapData(tmpObj, false, false, _ce.scaleFactor));
                    }
                    else if (Std.is(tmpObj, starling.display.DisplayObject))
                    {
                        _content = tmpObj;
                    }
                    else
                    {
                        throw new Error("[StarlingArt] class" + classString + " does not define a DisplayObject.");
                    }
                }
            }
            else if (Std.is(_view, Class)){
                tmpObj = Type.createInstance(view,[]);
               /* if (Std.is(tmpObj, flash.display.MovieClip))
                {
                    _content = AnimationSequence.fromMovieClip(tmpObj, _animation, 30);
                }
                else */
				
				if (Std.is(tmpObj, flash.display.Bitmap))
                {
                    _content = new Image(_texture = Texture.fromBitmap(tmpObj, false, false, _ce.scaleFactor));
                }
                else if (Std.is(tmpObj, BitmapData))
                {
                    _content = new Image(_texture = Texture.fromBitmapData(tmpObj, false, false, _ce.scaleFactor));
                }
                else if (Std.is(tmpObj, starling.display.DisplayObject))
                {
                    _content = tmpObj;
                }
            }/*else if (Std.is(_view, flash.display.MovieClip)){
                _content = AnimationSequence.fromMovieClip(_view, _animation, 30);
            }*/
            
			else if (Std.is(_view, starling.display.DisplayObject)){
                _content = _view;
                
               /* if (Std.is(_view, starling.display.MovieClip))
                {
                    _ce.juggler.add(_content, starling.display.MovieClip );
                }
                else */
				if (Std.is(_view, PDParticleSystem))
                {
                    Starling.current.juggler.add(cast(_content, PDParticleSystem));
                  //  _ce.juggler.add(cast(_content, PDParticleSystem));
                }
            }
            else if (Std.is(_view, Texture)){
                _content = new Image(_view);
            }
            else if (Std.is(_view, Bitmap)){
            
            // TODO : cut bitmap if size > 2048 * 2048, use StarlingTileSystem?{
                
                _content = new Image(_texture = Texture.fromBitmap(_view, false, false, _ce.scaleFactor));
            } else if (Std.is(_view, Int)){
            
            // TODO : manage radius -> circle{
                
                _content = new Quad(_citrusObject.width, _citrusObject.height, _view);
            }
            else
            {
                contentChanged = false;
            }
            
            if (_content == null || contentChanged == false){
                throw new Error("StarlingArt doesn't know how to create a graphic object from the provided CitrusObject " + citrusObject);
            }
            else
            {
                moveRegistrationPoint(_citrusObject.registration);
               
             // trace("INITIALIZE CONTENT THINGY , CHECK AND NOT ERASE");
                if (Reflect.hasField(_content,"initialize"))
                {
					 trace("INITIALIZE CONTENT THINGY[b] , CHECK AND NOT ERASE");
                    Reflect.field(_content, "initialize")(_citrusObject);
                }
                addChild(_content);
                
                _citrusObject.handleArtReady(try cast(this, ICitrusArt) catch(e:Dynamic) null);
            }
        }
        return value;
    }
    
   public function get_animation() : String
    {
        return _animation;
    }
    
   public function set_animation(value : String) : String
    {
        if (_animation == value && !_viewHasChanged)
        {
            return value;
        }
        
        _animation = value;
        
        if (_animation != null && _animation != "")
        {
            var animLoop : Bool = _loopAnimation[_animation];
            
            if (Std.is(_content, AnimationSequence)){
                cast(_content, AnimationSequence).changeAnimation(_animation, animLoop);
            }
        }
        
        _viewHasChanged = false;
        return value;
    }
    
   public function get_citrusObject() : ISpriteView
    {
        return _citrusObject;
    }
    
    public function update(stateView : ACitrusView) : Void {
		
        if (_citrusObject.inverted)
        {
            if (scaleX > 0){
                scaleX = -scaleX;
            }
        }
        else if (scaleX < 0)
        {
            scaleX = -scaleX;
        }
        
        if (Std.is(_content, StarlingPhysicsDebugView))
        {
            var physicsDebugArt : IDebugView = try cast((try cast(_content, StarlingPhysicsDebugView) catch(e:Dynamic) null).debugView, IDebugView) catch(e:Dynamic) null;
            /**
				 * INFO :
				 * can be replaced with (stateView as StarlingView).viewRoot as Sprite).getTransformationMatrix(Starling.current.stage)
				 * or using transform.concatenatedMatrix in SpriteArt . This would solve any issues with moved root sprite, state sprite,
				 * or any further parents added by the user that we don't know of.
				 */
            _m.copyFrom(stateView.camera.transformMatrix);
            _m.concat(_ce.transformMatrix);
            physicsDebugArt.transformMatrix = _m;
            physicsDebugArt.visibility = _citrusObject.visible;
            
            (try cast(_content, StarlingPhysicsDebugView) catch(e:Dynamic) null).update();
        }
        else if (_physicsComponent != null)
        {
            x = _physicsComponent.x + ((stateView.camera.camProxy.x - _physicsComponent.x) * (1 - _citrusObject.parallaxX)) + _citrusObject.offsetX * scaleX;
            y = _physicsComponent.y + ((stateView.camera.camProxy.y - _physicsComponent.y) * (1 - _citrusObject.parallaxY)) + _citrusObject.offsetY;
            rotation = MathUtil.deg2rad(_physicsComponent.rotation);
        }
        else
        {
            if (stateView.camera.parallaxMode == ACitrusCamera.PARALLAX_MODE_DEPTH){
                x = _citrusObject.x + ((stateView.camera.camProxy.x - _citrusObject.x) * (1 - _citrusObject.parallaxX)) + _citrusObject.offsetX * scaleX;
                y = _citrusObject.y + ((stateView.camera.camProxy.y - _citrusObject.y) * (1 - _citrusObject.parallaxY)) + _citrusObject.offsetY;
            }
            else
            {
                x = _citrusObject.x + ((stateView.camera.camProxy.x + stateView.camera.camProxy.offset.x) * (1 - _citrusObject.parallaxX)) + _citrusObject.offsetX * scaleX;
                y = _citrusObject.y + ((stateView.camera.camProxy.y + stateView.camera.camProxy.offset.y) * (1 - _citrusObject.parallaxY)) + _citrusObject.offsetY;
            }
            rotation = MathUtil.deg2rad(_citrusObject.rotation);
        }
        
        visible = _citrusObject.visible;
        touchable = _citrusObject.touchable;
        registration = _citrusObject.registration;
        view = _citrusObject.view;
        animation = _citrusObject.animation;
        group = _citrusObject.group;
    }
    
    /**
		 * play/pause animation when "playing" changes. The citrus juggler is pausable so no need to add/remove anything to it here.
		 */
    private function _pauseAnimation(value : Bool) : Void {  /*if (_view is Armature)
				value ? (_view as Armature).animation.play() : (_view as Armature).animation.stop();*/  
        
    }
    
    private function handleContentLoaded(evt : Event) : Void {
        loader = null;

		var eventTarget:Dynamic = evt.target;
		//var eventTarget:Dynamic = cast(evt.target, Dynamic);
		
		var targetLoader:Loader = cast(eventTarget.loader, Loader);
		var loaderContent:flash.display.DisplayObject = targetLoader.content;
	
		targetLoader.removeEventListener(Event.COMPLETE, handleContentLoaded);
        targetLoader.removeEventListener(IOErrorEvent.IO_ERROR, handleContentIOError);
        
        if (_content != null && _content.parent!=null)
        {
            _viewHasChanged = true;
            destroy();
        }
		
		if (Std.is(loaderContent, Bitmap))
        {
            _content = new Image(_texture = Texture.fromBitmap(cast(loaderContent,Bitmap), false, false, _ce.scaleFactor));
        }
        
        moveRegistrationPoint(_citrusObject.registration);
        addChild(_content);
        _citrusObject.handleArtReady(cast(this, ICitrusArt));
    }
    
    /**
		 * Handles loading of the atf assets.
		 */
    private function handleBinaryContentLoaded(evt : Event) : Void {
        loader = null;
        var eventTarget:Dynamic = evt.target;
        eventTarget.removeEventListener(Event.COMPLETE, handleBinaryContentLoaded);
        
        _texture = Texture.fromAtfData(cast(eventTarget.data, ByteArray), _ce.scaleFactor, false);
        _content = new Image(_texture);
        
        moveRegistrationPoint(_citrusObject.registration);
        addChild(_content);
        _citrusObject.handleArtReady(try cast(this, ICitrusArt) catch(e:Dynamic) null);
    }
    
    private function handleContentIOError(evt : IOErrorEvent) : Void {
        loader = null;
        throw new Error(evt.text);
    }
    
    /**
		 * Set it to false if you want to prevent the art to be updated. Be careful its properties (x, y, ...) won't be able to change!
		 */
   public function get_updateArtEnabled() : Bool {
        return _updateArtEnabled;
    }
    
    /**
		 * Set it to false also made the Sprite flattened!
		 */
   public function set_updateArtEnabled(value : Bool) : Bool {
        _updateArtEnabled = value;
        (_updateArtEnabled) ? unflatten() : flatten();
        return value;
    }
}

