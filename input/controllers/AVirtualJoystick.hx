package citrus.input.controllers;

import flash.errors.Error;
import citrus.input.InputController;
import citrus.math.MathVector;
import flash.geom.Point;
import flash.geom.Rectangle;

class AVirtualJoystick extends InputController
{
    public var radius(get, set) : Int;
    public var knobradius(get, set) : Int;
    public var x(never, set) : Int;
    public var y(never, set) : Int;

    //Common graphic properties
    private var _x : Int;
    private var _y : Int;
    
    private var _realTouchPosition : Point = new Point();
    private var _targetPosition : MathVector = new MathVector();
    
    private var _visible : Bool = true;
    
    //joystick features
    private var _innerradius : Int;
    private var _knobradius : Int = 50;
    private var _radius : Int = 130;
    
    //Axes values [-1;1]
    private var _xAxis : Float = 0;
    private var _yAxis : Float = 0;
    
    //Axes Actions
    private var _xAxisActions : Array<Dynamic>;
    private var _yAxisActions : Array<Dynamic>;
    
    private var _grabbed : Bool = false;
    private var _centered : Bool = true;
    
    /**
		 * wether to restrict the knob's movement in a circle or in a square
		 * hint: square allows for extreme values on both axis when dragged in a corner.
		 */
    public var circularBounds : Bool = true;
    
    /**
		 * alpha to use when the joystick is not active
		 */
    public var inactiveAlpha : Float = 0.3;
    
    /**
		 * alpha to use when the joystick is active (being dragged)
		 */
    public var activeAlpha : Float = 1;
    
    /**
		 * distance from the center at which no action will be fired.
		 */
    public var threshold : Float = 0.1;
    
    public function new(name : String, params : Dynamic = null)
    {
        super(name, params);
    }
    
    /**
		 * Override this for specific drawing
		 */
    private function initGraphics() : Void {
        trace("Warning: " + this + " does not render any graphics!");
    }
    
    /**
		 * Set action ranges.
		 */
    private function initActionRanges() : Void {
        _xAxisActions = new Array<Dynamic>();
        _yAxisActions = new Array<Dynamic>();
        
        //register default actions to value intervals
        
        addAxisAction("x", "left", -1, -0.3);
        addAxisAction("x", "right", 0.3, 1);
        addAxisAction("y", "up", -1, -0.3);
        addAxisAction("y", "down", 0.3, 1);
        
        addAxisAction("y", "duck", 0.8, 1);
        addAxisAction("y", "jump", -1, -0.8);
    }
    
    public function removeAxisAction(axis : String, name : String) : Void {
        var actionlist : Array<Dynamic>;
        if (axis.toLowerCase() == "x")
        {
            actionlist = _xAxisActions;
        }
        else if (axis.toLowerCase() == "y")
        {
            actionlist = _yAxisActions;
        }
        else
        {
            throw (new Error("VirtualJoystick::removeAxisAction() invalid axis parameter (only x and y are accepted)"));
        }
        
        for (i in 0...actionlist.length)
        {
            if (actionlist[i].name == name){
                actionlist.splice(i, 1);
            }
        }
    }
    
    public function addAxisAction(axis : String, name : String, start : Float, end : Float) : Void {
        var actionlist : Array<Dynamic>;
        if (axis.toLowerCase() == "x")
        {
            actionlist = _xAxisActions;
        }
        else if (axis.toLowerCase() == "y")
        {
            actionlist = _yAxisActions;
        }
        else
        {
            throw (new Error("VirtualJoystick::addAxisAction() invalid axis parameter (only x and y are accepted)"));
        }
        
        if ((start < 0 && end > 0) || (start > 0 && end < 0) || start == end)
        {
            throw (new Error("VirtualJoystick::addAxisAction() start and end values must have the same sign and not be equal"));
        }
        
        if (!((start < -1 || start > 1) || (end < -1 || end > 1)))
        {
            actionlist.push({
                        name : name,
                        start : start,
                        end : end
                    });
        }
        else
        {
            throw (new Error("VirtualJoystick::addAxisAction() start and end values must be between -1 and 1"));
        }
    }
    
    /**
		 * Give handleGrab the relative position of touch or mouse to knob.
		 * It will handle knob movement restriction, action triggering and set _knobX and _knobY for knob positioning.
		 */
    private function handleGrab(relativeX : Int, relativeY : Int) : Void {
        if (circularBounds)
        {
            var dist : Float = relativeX * relativeX + relativeY * relativeY;
            if (dist <= _innerradius * _innerradius){
                _targetPosition.setTo(relativeX, relativeY);
            }
            else
            {
                _targetPosition.setTo(relativeX, relativeY);
                _targetPosition.length = _innerradius;
            }
        }
        else
        {
            if (relativeX < _innerradius && relativeX > -_innerradius){
                _targetPosition.x = relativeX;
            }
            else if (relativeX > _innerradius){
                _targetPosition.x = _innerradius;
            }
            else if (relativeX < -_innerradius){
                _targetPosition.x = -_innerradius;
            }
            
            if (relativeY < _innerradius && relativeY > -_innerradius){
                _targetPosition.y = relativeY;
            }
            else if (relativeY > _innerradius){
                _targetPosition.y = _innerradius;
            }
            else if (relativeY < -_innerradius){
                _targetPosition.y = -_innerradius;
            }
        }
        
        //normalize x and y axes value.
        
        _xAxis = _targetPosition.x / _innerradius;
        _yAxis = _targetPosition.y / _innerradius;
        
        // Check registered actions on both axes
        
        if (_targetPosition.length <= threshold)
        {
            _input.stopActionsOf(this);
        }
        else
        {
            var a : Dynamic;  //action  
            var ratio : Float;
            var val : Float;
            
            if (_xAxisActions.length > 0){
                for (a in _xAxisActions)
                {
                    ratio = 1 / (a.end - a.start);
                    val = (_xAxis < 0) ? 1 - Math.abs((_xAxis - a.start) * ratio) : Math.abs((_xAxis - a.start) * ratio);
                    if ((_xAxis >= a.start) && (_xAxis <= a.end))
                    {
                        triggerCHANGE(a.name, val);
                    }
                    else
                    {
                        triggerOFF(a.name, 0);
                    }
                }
            }
            
            if (_yAxisActions.length > 0){
                for (a in _yAxisActions)
                {
                    ratio = 1 / (a.start - a.end);
                    val = (_yAxis < 0) ? Math.abs((_yAxis - a.end) * ratio) : 1 - Math.abs((_yAxis - a.end) * ratio);
                    if ((_yAxis >= a.start) && (_yAxis <= a.end))
                    {
                        triggerCHANGE(a.name, val);
                    }
                    else
                    {
                        triggerOFF(a.name, 0);
                    }
                }
            }
        }
    }
    
    private function reset() : Void {
        _targetPosition.setTo();
        _xAxis = 0;
        _yAxis = 0;
        _input.stopActionsOf(this);
    }
    
   public function set_radius(value : Int) : Int
    {
        if (!_initialized)
        {
            _radius = value;
            _innerradius = _radius - _knobradius;
        }
        else
        {
            trace("Warning: You cannot set " + this + " radius after it has been created. Please set it in the constructor.");
        }
        return value;
    }
    
   public function set_knobradius(value : Int) : Int
    {
        if (!_initialized)
        {
            _knobradius = value;
            _innerradius = _radius - _knobradius;
        }
        else
        {
            trace("Warning: You cannot set " + this + " knobradius after it has been created. Please set it in the constructor.");
        }
        return value;
    }
    
   public function set_x(value : Int) : Int
    {
        if (value == _x)
        {
            return value;
        }
        
        _x = value;
        reset();
        return value;
    }
    
   public function set_y(value : Int) : Int
    {
        if (value == _y)
        {
            return value;
        }
        
        _y = value;
        reset();
        return value;
    }
    
   public function get_radius() : Int
    {
        return _radius;
    }
    
   public function get_knobradius() : Int
    {
        return _knobradius;
    }
}

