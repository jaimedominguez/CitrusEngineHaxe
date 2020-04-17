package citrus.physics;

import citrus.core.CitrusObject;
import citrus.view.ICitrusArt;

/**
	 * An abstract template used by every physics engine.
	 */
class APhysicsEngine extends CitrusObject
{
    public var debugView(get, never) : IDebugView;
    public var realDebugView(get, never) : Dynamic;
    public var view(get, set) : Dynamic;
    public var art(get, never) : ICitrusArt;
    public var x(get, never) : Float;
    public var y(get, never) : Float;
    public var z(get, never) : Float;
    public var width(get, never) : Float;
    public var height(get, never) : Float;
    public var depth(get, never) : Float;
    public var velocity(get, never) : Array<Dynamic>;
    public var parallaxX(get, never) : Float;
    public var parallaxY(get, never) : Float;
    public var rotation(get, never) : Float;
    public var group(get, set) : Int;
    public var visible(get, set) : Bool;
    public var touchable(get, set) : Bool;
    public var animation(get, never) : String;
    public var inverted(get, never) : Bool;
    public var offsetX(get, never) : Float;
    public var offsetY(get, never) : Float;
    public var registration(get, never) : String;

    
    private var _visible : Bool = false;
    private var _touchable : Bool = false;
    private var _group : Int = 1;
    private var _view : Dynamic;
    private var _realDebugView : Dynamic;
    
    private var _art : ICitrusArt;
    
    public function new(name : String, params : Dynamic = null)
    {
        super(name, params);
        updateCallEnabled = true;
        
    }
    
    public function getBody() : Dynamic
    {
        return null;
    }
    
    /**
		 * Shortcut to the debugView
		 * use to change the debug drawer's flags with debugView.debugMode()
		 * or access it directly through debugView.debugDrawer.
		 * 
		 * exists only after the physics engine has been added to the state.
		 * 
		 * Example : changing the debug views flags:
		 *
		 * Box2D :
		 * <code>
		 * var b2d:Box2D = new Box2D("b2d");
		 * b2d.gravity = b2Vec2.Make(0,0);
		 * b2d.visible = true;
		 * add(b2d);
		 * 
		 * b2d.debugView.debugMode(b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit);
		 * //or
		 * (b2d.debugView.debugDrawer as b2DebugDraw).SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
		 * </code>
		 * 
		 * Nape:
		 * <code>
		 * nape = new Nape("nape");
		 * nape.visible = true;
		 * add(nape);
		 * 
		 * nape.debugView.debugMode(NapeDebugArt.draw_Bodies | NapeDebugArt.draw_BodyDetail | NapeDebugArt.draw_CollisionArbiters);
		 * //or
		 * var shapedebug:ShapeDebug = nape.debugView.debugDrawer as ShapeDebug;
		 * shapedebug.drawBodies = true;
		 * shapedebug.drawBodyDetail = true;
		 * shapedebug.drawCollisionArbiters = true;
		 * </code>
		 */
   public function get_debugView() : IDebugView
    {
    
		
		var debugArt : Dynamic = _ce.state.view.getArt(this);
        if (debugArt != null && debugArt.content) { 
			return try cast(debugArt.content.debugView, IDebugView) catch(e:Dynamic) null;
        }else{
            return null;
        }
    }
    
   public function get_realDebugView() : Dynamic
    {
        return _realDebugView;
    }
    
   public function get_view() : Dynamic
    {
        return _view;
    }
    
   public function set_view(value : Dynamic) : Dynamic{

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
    
   public function get_x() : Float
    {
        return 0;
    }
    
   public function get_y() : Float
    {
        return 0;
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
    
   public function get_parallaxX() : Float
    {
        return 1;
    }
    
   public function get_parallaxY() : Float
    {
        return 1;
    }
    
   public function get_rotation() : Float
    {
        return 0;
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
    
   public function get_animation() : String
    {
        return "";
    }
    
   public function get_inverted() : Bool {
        return false;
    }
    
   public function get_offsetX() : Float
    {
        return 0;
    }
    
   public function get_offsetY() : Float
    {
        return 0;
    }
    
   public function get_registration() : String
    {
        return "topLeft";
    }
    
    public function handleArtReady(citrusArt : ICitrusArt) : Void {
        _art = citrusArt;
    }
    
    public function handleArtChanged(citrusArt : ICitrusArt) : Void {
    }
}

