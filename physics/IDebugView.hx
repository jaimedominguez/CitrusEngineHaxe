package citrus.physics;

import flash.geom.Matrix;

/**
	 * Interface for all the debug views
	 */
interface IDebugView
{
    
    var transformMatrix(get, set) : Matrix;    
    var visibility(get, set) : Bool;    
    /**
		 * returns the b2DebugDraw for Box2D, ShapeDebug for Nape...
		 */
    var debugDrawer(get, never) : Dynamic;

    
    /**
		 * update the debug view
		 */
    function update() : Void
    ;
    /**
		 * change the debug mode when available, e.g. show only joints, or raycasts...
		 */
    function debugMode(flags : Int) : Void
    ;
    function initialize() : Void
    ;function destroy() : Void
    ;
}

