package citrus.objects;

import citrus.core.CitrusObject;
import citrus.math.MathVector;
import citrus.view.ICitrusArt;
import citrus.view.ISpriteView;
import citrus.view.starlingview.AnimationSequence;
import citrus.view.starlingview.StarlingSpriteDebugArt;
import flash.utils.Dictionary;
import kaleidoEngine.debug.InObject;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.display.Sprite3D;

/**
	 * This is the primary class for creating graphical game objects.
	 * You should override this class to create a visible game object such as a Spaceship, Hero, or Backgrounds. This is the equivalent
	 * of the Flash Sprite. It has common properties that are required for properly displaying and
	 * positioning objects. You can also add your logic to this sprite.
	 * 
	 * <p>With a CitrusSprite, there is only simple collision and velocity logic. If you'd like to take advantage of Box2D or Nape physics,
	 * you should extend the APhysicsObject class instead.</p>
	 */
class CitrusSprite extends CitrusObject implements ISpriteView
{
    public var x(get, set) : Float;
    public var y(get, set) : Float;
    public var z(get, never) : Float;
    public var width(get, set) : Float;
    public var height(get, set) : Float;
    public var depth(get, never) : Int;
    public var velocity(get, set) : Array<Dynamic>;
    public var parallaxX(get, set) : Float;
    public var parallaxY(get, set) : Float;
    public var rotation(get, set) : Float;
    public var group(get, set) : Int;
    public var visible(get, set) : Bool;
    public var touchable(get, set) : Bool;
	
    public var view(get, set) : DisplayObject;
    public var viewAnim: AnimationSequence;
    public var viewImage: Image;
    public var viewSprite: Sprite;
    public var viewSprite3D: Sprite3D;
	
    public var art(get, never) : ICitrusArt;
    public var inverted(get, set) : Bool;
    public var animation(get, set) : String;
    public var offsetX(get, set) : Float;
    public var offsetY(get, set) : Float;
    public var registration(get, set) : String;
    public var citrus_internal_data : Dynamic;
    private var _x : Float = 0;
    private var _y : Float = 0;
    private var _width : Float = 30;
    private var _height : Float = 30;
    private var _velocity : MathVector = new MathVector();
    private var _parallaxX : Float = 1;
    private var _parallaxY : Float = 1;
    private var _rotation : Float = 0;
    private var _group : Int = 0;
    private var _visible : Bool = true;
    private var _touchable : Bool = false;
    private var _view : Dynamic = StarlingSpriteDebugArt;
	private var _viewAnim : AnimationSequence;
    private var _art : ICitrusArt;
    private var _inverted : Bool = false;
    private var _animation : String = "";
    private var _offsetX : Float = 0;
    private var _offsetY : Float = 0;
    private var _registration : String = "topLeft";
    
    public function new(name : String, params : Dynamic = null)
    {
        super(name, params);
		//createHolder();
    }
	
	/*function createHolder():Void {
		viewHolder = new DisplayObjectContainer();
	}*/
    
    /**
		 * @inheritDoc
		 */
    public function handleArtReady(citrusArt : ICitrusArt) : Void {
        _art = citrusArt;
    }
    
    /**
		 * @inheritDoc
		 */
    public function handleArtChanged(oldArt : ICitrusArt) : Void {
    }
    
    override public function destroy() : Void {
		destroyView();
        _art = null;
		
        super.destroy();

    }
    
    /**
		 * No physics here, return <code>null</code>.
		 */
    public function getBody() : Dynamic
    {
        return null;
    }
    @:meta(Inline())

    @:finalpublic function get_x() : Float
    {
        return _x;
    }
    
    @:meta(Inline())

    @:finalpublic function set_x(value : Float) : Float
    {
        _x = value;
        return value;
    }
    
    @:meta(Inline())

    @:finalpublic function get_y() : Float
    {
        return _y;
    }
    
    @:meta(Inline())

    @:finalpublic function set_y(value : Float) : Float
    {
        _y = value;
        return value;
    }
    
    @:meta(Inline())

    @:finalpublic function get_z() : Float
    {
        return 0;
    }
    
    @:meta(Inline())

    @:finalpublic function get_width() : Float
    {
        return _width;
    }
    
    @:meta(Inline())

    @:finalpublic function set_width(value : Float) : Float
    {
        _width = value;
        return value;
    }
    
    @:meta(Inline())

    @:finalpublic function get_height() : Float
    {
        return _height;
    }
    
    @:meta(Inline())

    @:finalpublic function set_height(value : Float) : Float
    {
        _height = value;
        return value;
    }
    
    @:meta(Inline())

    @:finalpublic function get_depth() : Int
    {
        return 0;
    }
    
   public function get_velocity() : Array<Dynamic>
    {
        return [_velocity.x, _velocity.y, 0];
    }
    
   public function set_velocity(value : Array<Dynamic>) : Array<Dynamic>
    {
        _velocity.x = value[0];
        _velocity.y = value[1];
        return value;
    }
    
   public function get_parallaxX() : Float
    {
        return _parallaxX;
    }
    
    @:meta(Inspectable(defaultValue="1"))

   public function set_parallaxX(value : Float) : Float
    {
        _parallaxX = value;
        return value;
    }
    
   public function get_parallaxY() : Float
    {
        return _parallaxY;
    }
    
    @:meta(Inspectable(defaultValue="1"))

   public function set_parallaxY(value : Float) : Float
    {
        _parallaxY = value;
        return value;
    }
    
   public function get_rotation() : Float
    {
        return _rotation;
    }
    
   public function set_rotation(value : Float) : Float
    {
        _rotation = value;
        return value;
    }
    
    /**
		 * The group is similar to a z-index sorting. Default is 0, 1 is over.
		 */
   public function get_group() : Int
    {
        return _group;
    }
    
    @:meta(Inspectable(defaultValue="0"))

   public function set_group(value : Int) : Int
    {
		
        _group = value;
        return value;
    }
    
   public function get_visible() : Bool {
        return _visible;
    }
    
   public function set_visible(value : Bool) : Bool {
        _visible = value;
        return value;
    }
    
   public function get_touchable() : Bool {
        return _touchable;
    }
    
   public function set_touchable(value : Bool) : Bool {
        _touchable = value;
        return value;
    }
    
    /**
		 * The view can be a class, a string to a file, or a display object. It must be supported by the view you target.
		 */
   public function get_view() : Dynamic
    {
        return _view;
    }
	
	
  	public function destroyView():Void {
		
		if (viewAnim != null) viewAnim.destroy();
		else if (view!=null) view.removeFromParent(true);
 		else if (!kill) trace("destroyView>>> :"+name+ " didn't have a view in this moment.");
		viewAnim = null;
		viewImage = null;
		viewSprite = null;
		viewSprite3D = null;
		view = null;
	}
	
  public function set_view(value : Dynamic) : Dynamic
    {
        _view = value;
		
		
		if (Std.is(value, AnimationSequence)) viewAnim = value;
		else if (Std.is(value, Image)) viewImage = value;
		else if (Std.is(value, Sprite)) viewSprite = value;
		else if (Std.is(value, Sprite3D)) viewSprite3D = value;
        return value;
    }
	
	 public function set_viewAnim(value : AnimationSequence) : AnimationSequence
    {
        _viewAnim = value;
        return value;
    } 
	
	public function get_viewAnim() : AnimationSequence
    {
        return _viewAnim;
    }
	
	
    
    
    /**
		 * @inheritDoc
		 */
   public function get_art() : ICitrusArt
    {
        return _art;
    }
    
    /**
		 * Used to invert the view on the y-axis, number of animations friendly!
		 */
   public function get_inverted() : Bool {
        return _inverted;
    }
    
   public function set_inverted(value : Bool) : Bool {
        _inverted = value;
        return value;
    }
    
   public function get_animation() : String
    {
        return _animation;
    }
    
   public function set_animation(value : String) : String
    {
        _animation = value;
        return value;
    }
    
   public function get_offsetX() : Float
    {
        return _offsetX;
    }
    
    @:meta(Inspectable(defaultValue="0"))

   public function set_offsetX(value : Float) : Float
    {
        _offsetX = value;
        return value;
    }
    
   public function get_offsetY() : Float
    {
        return _offsetY;
    }
    
    @:meta(Inspectable(defaultValue="0"))

   public function set_offsetY(value : Float) : Float
    {
        _offsetY = value;
        return value;
    }
    
   public function get_registration() : String
    {
        return _registration;
    }
    
    @:meta(Inspectable(defaultValue="topLeft",enumeration="center,topLeft"))

   public function set_registration(value : String) : String
    {
        _registration = value;
        return value;
    }
  
	/*
	function get_viewHolder():DisplayObjectContainer {
		return viewHolder;
	}*/
	
    override public function update(timeDelta : Float) : Void {
 
		super.update(timeDelta);
        
        x += (_velocity.x * timeDelta);
        y += (_velocity.y * timeDelta);
	
    }
}
