package citrus.events;

import haxe.Constraints.Function;

class CitrusEvent
{
    public var type(get, never) : String;
    public var phase(get, never) : Int;
    public var bubbles(get, never) : Bool;
    public var cancelable(get, never) : Bool;
    public var target(get, never) : CitrusEventDispatcher;
    public var currentTarget(get, never) : CitrusEventDispatcher;
    public var currentListener(get, never) : Function;

    @:allow(citrus.events)
    private var _type : String;
    @:allow(citrus.events)
    private var _phase : Int = CAPTURE_PHASE;
    @:allow(citrus.events)
    private var _bubbles : Bool = true;
    @:allow(citrus.events)
    private var _cancelable : Bool = false;
    @:allow(citrus.events)
    private var _target : CitrusEventDispatcher;
    @:allow(citrus.events)
    private var _currentTarget : CitrusEventDispatcher;
    @:allow(citrus.events)
    private var _currentListener : Function;
    
    public function new(type : String, bubbles : Bool = true, cancelable : Bool = false)
    {
        _type = type;
        _bubbles = bubbles;
        _cancelable = cancelable;
    }
    
    private function setTarget(object : Dynamic) : Void {
        _target = object;
    }
    
    public function clone() : CitrusEvent
    {
        var e : CitrusEvent = new CitrusEvent(_type, _bubbles, _cancelable);
        e._target = e._currentTarget = _currentTarget;
        return e;
    }
    
   public function get_type() : String
    {
        return _type;
    }
   public function get_phase() : Int
    {
        return _phase;
    }
   public function get_bubbles() : Bool {
        return _bubbles;
    }
   public function get_cancelable() : Bool {
        return _cancelable;
    }
   public function get_target() : CitrusEventDispatcher
    {
        return _target;
    }
   public function get_currentTarget() : CitrusEventDispatcher
    {
        return _currentTarget;
    }
   public function get_currentListener() : Function
    {
        return _currentListener;
    }
    
    public function toString() : String
    {
        return "[CitrusEvent type:" + _type + " target:" + _target + " currentTarget:" + _currentTarget + " phase:" + _phase + " bubbles:" + _bubbles + " cancelable:" + _cancelable + " ]";
    }
    
    public static var CAPTURE_PHASE : Int = 0;
    public static var AT_TARGET : Int = 1;
    public static var BUBBLE_PHASE : Int = 2;
}

