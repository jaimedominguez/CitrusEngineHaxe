package citrus.physics.nape;

import citrus.core.CitrusEngine;
import citrus.datastructures.BitFlag;
import citrus.physics.IDebugView;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Matrix;
import nape.util.ShapeDebug;

/**
	 * This displays Nape's debug graphics. It does so properly through Citrus Engine's view manager. Nape by default
	 * sets visible to false with an alpha of 0.8, so you'll need to set the Nape object's visible property to true in order to see the debug graphics. 
	 */
class NapeDebugArt implements IDebugView
{
    public var debugDrawer(get, never) : Dynamic;
    public var transformMatrix(get, set) : Matrix;
    public var visibility(get, set) : Bool;

    
    private var _nape : Nape;
    private var _debugDrawer : ShapeDebug;
    private var _ce : CitrusEngine;
    
    /**
		 * NapDebugArt flags.
		 * after modifying them, call applyFlags() to set the ShapeDebug's boolean values.
		 */
    public var flags : BitFlag;
    
    public static var draw_Bodies : Int = 1 << 0;
    public static var draw_BodyDetail : Int = 1 << 1;
    public static var draw_CollisionArbiters : Int = 1 << 2;
    public static var draw_Constraints : Int = 1 << 3;
    public static var draw_FluidArbiters : Int = 1 << 4;
    public static var draw_SensorArbiters : Int = 1 << 5;
    public static var draw_ShapeAngleIndicators : Int = 1 << 6;
    public static var draw_ShapeDetail : Int = 1 << 7;
    
    public function new()
    {
        _ce = CitrusEngine.getInstance();
        
        flags = new BitFlag(NapeDebugArt);
        
        _nape = try cast(_ce.state.getFirstObjectByType(Nape), Nape) catch(e:Dynamic) null;
        
        _debugDrawer = new ShapeDebug(_ce.screenWidth, _ce.screenHeight);
        
        _debugDrawer.display.name = "debug view";
        _debugDrawer.display.alpha = 1;
        
        readFlags();
        applyFlags();
        _ce.onStageResize.add(resize);
    }
    
    private function applyFlags():Void{
		/*	_debugDrawer.drawBodies = flags.hasFlag(draw_Bodies);
			_debugDrawer.drawBodyDetail = flags.hasFlag(draw_BodyDetail);
			_debugDrawer.drawCollisionArbiters = flags.hasFlag(draw_BodyDetail);
			_debugDrawer.drawConstraints = flags.hasFlag(draw_Constraints);
			_debugDrawer.drawFluidArbiters = flags.hasFlag(draw_FluidArbiters);
			_debugDrawer.drawSensorArbiters = flags.hasFlag(draw_SensorArbiters);
			_debugDrawer.drawShapeAngleIndicators = flags.hasFlag(draw_ShapeAngleIndicators);
			_debugDrawer.drawShapeDetail = flags.hasFlag(draw_ShapeDetail);*/
			
			_debugDrawer.drawBodies = false;
			_debugDrawer.drawBodyDetail = false;
			_debugDrawer.drawCollisionArbiters = false;
			_debugDrawer.drawConstraints = false;
			_debugDrawer.drawFluidArbiters = false;
			_debugDrawer.drawSensorArbiters =false;
			_debugDrawer.drawShapeAngleIndicators =false;
			_debugDrawer.drawShapeDetail = false;
			
			
			
			
			//trace("NAPE applyFlags()");
			//_debugDrawer.drawBodies = true;
			//_debugDrawer.drawBodyDetail = true;
			//_debugDrawer.drawShapeDetail = true;
			
			
			
		}
		
	private function readFlags():Void
		{
			flags.removeAllFlags();
		/*	if(_debugDrawer.drawBodies) flags.addFlag(draw_Bodies);
			if(_debugDrawer.drawBodyDetail) flags.addFlag(draw_BodyDetail);
			if(_debugDrawer.drawCollisionArbiters) flags.addFlag(draw_BodyDetail);
			if(_debugDrawer.drawConstraints) flags.addFlag(draw_Constraints);
			if(_debugDrawer.drawFluidArbiters) flags.addFlag(draw_FluidArbiters);
			if(_debugDrawer.drawSensorArbiters) flags.addFlag(draw_SensorArbiters);
			if(_debugDrawer.drawShapeAngleIndicators) flags.addFlag(draw_ShapeAngleIndicators);
			if(_debugDrawer.drawShapeDetail) flags.addFlag(draw_ShapeDetail);*/
		}
    
    public function initialize() : Void {
        _ce.stage.addChild(_debugDrawer.display);
    }
    
    public function resize(w : Float, h : Float) : Void {
       
		//trace("NAPE ART on resize()");
		
		if (!_nape.visible)
        {
            return;
        }
        
        readFlags();
        _ce.stage.removeChild(_debugDrawer.display);
        _debugDrawer.flush();
        _debugDrawer = new ShapeDebug(_ce.screenWidth, _ce.screenHeight);
        _debugDrawer.display.name = "debug view";
        _debugDrawer.display.alpha = 1.5;
        applyFlags();
        _ce.stage.addChild(_debugDrawer.display);
    }
    
    public function update() : Void {
        if (_nape.visible)
        {
            _debugDrawer.clear();
            _debugDrawer.draw(_nape.space);
            _debugDrawer.flush();
        }
    }
    
    public function destroy() : Void {
        flags.destroy();
        _ce.onStageResize.remove(resize);
        _ce.stage.removeChild(_debugDrawer.display);
    }
    
    public function debugMode(flags : Int) : Void {
        this.flags.setFlags(flags);
        applyFlags();
    }
    
   public function get_debugDrawer() : Dynamic
    {
        return _debugDrawer;
    }
    
   public function get_transformMatrix() : Matrix
    {
        return _debugDrawer.transform.toMatrix();
    }
    
   public function set_transformMatrix(m : Matrix) : Matrix
    //flash Matrix is Mat23 with b and c swapped
    {
        
        _debugDrawer.transform.setAs(m.a, m.c, m.b, m.d, m.tx, m.ty);
        return m;
    }
    
   public function get_visibility() : Bool {
        return _debugDrawer.display.visible;
    }
    
   public function set_visibility(val : Bool) : Bool {
        _debugDrawer.display.visible = val;
        return val;
    }
}

