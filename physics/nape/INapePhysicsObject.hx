package citrus.physics.nape;

import nape.callbacks.InteractionCallback;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.phys.Body;


/**
	 * An interface used by each Nape object. It helps to enable interaction between entity/component object and "normal" object.
	 */
interface INapePhysicsObject
{
    
    
    var x(get, set) : Float;    
    
    var y(get, set) : Float;    
    var z(get, never) : Float;    
    
    var rotation(get, set) : Float;    
    
    var width(get, set) : Float;    
    
    var height(get, set) : Float;    
    var depth(get, never) : Float;    
    
    var radius(get, set) : Float;    
    var body(get, never) : Body;    
    
    
    var beginContactCallEnabled(get, set) : Bool;    
    
    var endContactCallEnabled(get, set) : Bool;

    
    function handleBeginContact(callback : InteractionCallback) : Void
    ;
    function handleEndContact(callback : InteractionCallback) : Void
    ;
    function handlePreContact(callback : PreCallback) : PreFlag
    ;
    function fixedUpdate() : Void
    ;
    function getBody() : Dynamic
    ;
}

