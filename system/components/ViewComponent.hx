package citrus.system.components;

import citrus.system.Component;
import citrus.view.ICitrusArt;
import citrus.view.ISpriteView;
import msignal.Signal;
//import hx.event.Signal;
//import org.osflash.signals.Signal;
import flash.display.MovieClip;

/**
	 * The view component, it manages everything to set the view.
	 * Extend it to handle animation.
	 */
class ViewComponent extends Component implements ISpriteView
{
    public var x(get, set) : Float;
    public var y(get, set) : Float;
    public var z(get, never) : Float;
    public var width(get, never) : Float;
    public var height(get, never) : Float;
    public var depth(get, never) : Float;
    public var velocity(get, never) : Array<Dynamic>;
    public var rotation(get, set) : Float;
    public var parallaxX(get, set) : Float;
    public var parallaxY(get, set) : Float;
    public var group(get, set) : Int;
    public var visible(get, set) : Bool;
    public var touchable(get, set) : Bool;
    public var view(get, set) : Dynamic;
    public var art(get, never) : ICitrusArt;
    public var animation(get, never) : String;
    public var inverted(get, never) : Bool;
    public var offsetX(get, set) : Float;
    public var offsetY(get, set) : Float;
    public var registration(get, set) : String;

    
    public var onAnimationChange : Signal0;
    
    private var _x : Float = 0;
    private var _y : Float = 0;
    private var _rotation : Float = 0;
    private var _inverted : Bool = false;
    private var _parallaxX : Float = 1;
    private var _parallaxY : Float = 1;
    private var _animation : String = "";
    private var _visible : Bool = true;
    private var _touchable : Bool = false;
    private var _view : Dynamic = 0xFF0000;
    private var _art : ICitrusArt;
    
    private var _group : Int = 0;
    private var _offsetX : Float = 0;
    private var _offsetY : Float = 0;
    private var _registration : String = "center";
    
    public function new(name : String, params : Dynamic = null)
    {
        super(name, params);
        
        onAnimationChange = new Signal0();
    }
    
    /**
		 * called when the art is created (and loaded if loading is required)
		 * @param	citrusArt the art
		 */
    public function handleArtReady(citrusArt : ICitrusArt) : Void {
    }
    
    /**
		 * called when the art changes. the argument is the art with its previous content
		 * so that you can remove event listeners from it for example.
		 * @param	citrusArt the art
		 */
    public function handleArtChanged(oldArt : ICitrusArt) : Void {
    }
    
    override public function update(timeDelta : Float) : Void {
        super.update(timeDelta);
    }
    
    override public function destroy() : Void {
        onAnimationChange.removeAll();
        _art = null;
        
        super.destroy();
    }
    
    public function getBody() : Dynamic
    {
        return null;
    }
    
   public function get_x() : Float
    {
        return _x;
    }
    
   public function set_x(value : Float) : Float
    {
        _x = value;
        return value;
    }
    
   public function get_y() : Float
    {
        return _y;
    }
    
   public function set_y(value : Float) : Float
    {
        _y = value;
        return value;
    }
    
   public function get_z() : Float
    {
        return 0;
    }
    
   public function get_width() : Float
    {
        return 0;
    }
    
   public function get_height() : Float
    {
        return 0;
    }
    
   public function get_depth() : Float
    {
        return 0;
    }
    
   public function get_velocity() : Array<Dynamic>
    {
        return null;
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
    
   public function get_parallaxX() : Float
    {
        return _parallaxX;
    }
    
   public function set_parallaxX(value : Float) : Float
    {
        _parallaxX = value;
        return value;
    }
    
   public function get_parallaxY() : Float
    {
        return _parallaxY;
    }
    
   public function set_parallaxY(value : Float) : Float
    {
        _parallaxY = value;
        return value;
    }
    
   public function get_group() : Int
    {
        return _group;
    }
    
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
    
   public function get_view() : Dynamic
    {
        return _view;
    }
    
   public function set_view(value : Dynamic) : Dynamic
    {
        _view = value;
        return value;
    }
    
    /**
		 * @inheritDoc
		 */
   public function get_art() : ICitrusArt
    {
        return _art;
    }
    
   public function get_animation() : String
    {
        return _animation;
    }
    
   public function get_inverted() : Bool {
        return _inverted;
    }
    
   public function get_offsetX() : Float
    {
        return _offsetX;
    }
    
   public function set_offsetX(value : Float) : Float
    {
        _offsetX = value;
        return value;
    }
    
   public function get_offsetY() : Float
    {
        return _offsetY;
    }
    
   public function set_offsetY(value : Float) : Float
    {
        _offsetY = value;
        return value;
    }
    
   public function get_registration() : String
    {
        return _registration;
    }
    
   public function set_registration(value : String) : String
    {
        _registration = value;
        return value;
    }
}

