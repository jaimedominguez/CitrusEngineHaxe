package citrus.input.controllers;

import citrus.input.InputController;

class AVirtualButton extends InputController
{
    public var visible(get, set) : Bool;
    public var buttonradius(get, set) : Int;
    public var margin(get, set) : Int;
    public var x(never, set) : Int;
    public var y(never, set) : Int;

    //Common graphic properties
    private var _x : Int;
    private var _y : Int;
    
    private var _margin : Int = 130;
    
    private var _visible : Bool = true;
    
    private var _buttonradius : Int = 50;
    
    public var buttonAction : String = "button";
    public var buttonChannel : Int = -1;
    
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
    
   public function set_visible(value : Bool) : Bool {
        _visible = value;
        return value;
    }
    
   public function set_buttonradius(value : Int) : Int
    {
        if (!_initialized)
        {
            _buttonradius = value;
        }
        else
        {
            trace("Warning: You cannot set " + this + " buttonradius after it has been created. Please set it in the constructor.");
        }
        return value;
    }
    
   public function set_margin(value : Int) : Int
    {
        if (!_initialized)
        {
            _margin = value;
        }
        else
        {
            trace("Warning: You cannot set " + this + " margin after it has been created. Please set it in the constructor.");
        }
        return value;
    }
    
   public function get_margin() : Int
    {
        return _margin;
    }
    
   public function set_x(value : Int) : Int
    {
        if (!_initialized)
        {
            _x = value;
        }
        else
        {
            trace("Warning: you can only set " + this + " x through graphic.x after instanciation.");
        }
        return value;
    }
    
   public function set_y(value : Int) : Int
    {
        if (!_initialized)
        {
            _y = value;
        }
        else
        {
            trace("Warning: you can only set " + this + " y through graphic.y after instanciation.");
        }
        return value;
    }
    
   public function get_visible() : Bool {
        return _visible;
    }
    
   public function get_buttonradius() : Int
    {
        return _buttonradius;
    }
}

