package citrus.view.starlingview;

import citrus.core.CitrusEngine;
import citrus.physics.APhysicsEngine;
import citrus.physics.IDebugView;
import flash.display.Sprite;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.Event;

/**
	 * A wrapper for Starling to display the debug view of the different physics engine.
	 */
class StarlingPhysicsDebugView extends starling.display.Sprite
{
    public var debugView(get, never) : IDebugView;

    
    private var _physicsEngine : APhysicsEngine;
    private var _debugView : IDebugView;
    
    public function new()
    {
        super();
        
        _physicsEngine = try cast(CitrusEngine.getInstance().state.getFirstObjectByType(APhysicsEngine), APhysicsEngine) catch(e:Dynamic) null;
        _debugView = Type.createInstance(_physicsEngine.realDebugView, []);
        addEventListener(Event.ADDED_TO_STAGE, _addedToStage);
    }
    
    private function _addedToStage(event : Event) : Void {
        removeEventListener(Event.ADDED_TO_STAGE, _addedToStage);
        _debugView.initialize();
    }
    
    public function update() : Void {
        _debugView.update();
    }
    
    public function debugMode(flags : Int) : Void {
        _debugView.debugMode(flags);
    }
    
   public function get_debugView() : IDebugView
    {
        return _debugView;
    }
    
    override public function dispose() : Void {
		//trace("DISPOSE StarlingPhysicsDebugView()");
		if (debugView!=null) _debugView.destroy();
		//trace("DISPOSE2");
        _physicsEngine = null;
		//trace("DISPOSE3");
        _debugView = null;
		//trace("DISPOSE4");
        super.dispose();
		//trace("DISPOSE5");
    }
}

