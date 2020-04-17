package citrus.events;

import haxe.Constraints.Function;
import flash.utils.Dictionary;
import openfl.utils.Object;
import starling.events.EventDispatcher;

//import citrus.core.citrus_internal;
/**
	 * experimental event dispatcher (wip)
	 * TODO: 
	 * - check consistency of bubbling/capturing
	 * - propagation stop ?
	 */
class CitrusEventDispatcher extends EventDispatcher
{
    //use namespace citrus_internal;
    
    private var listeners : Dictionary<String,Array<Dynamic>>;
    
    private var dispatchParent : CitrusEventDispatcher;
    private var dispatchChildren : Array<CitrusEventDispatcher>;
    
    public function new()
    {
       super();
		//listeners = new Dictionary<String,Array<Dynamic>>();
    }
    
}

