package citrus.input.controllers.gamepad.controls;

import citrus.input.controllers.gamepad.Gamepad;
import citrus.input.InputController;

class ButtonController extends InputController implements Icontrol
{
    private var active(never, set) : Bool;
    public var value(get, never) : Float;
    public var gamePad(get, never) : Gamepad;
    public var controlID(get, never) : String;
    public var action(get, set) : String;

    private var _gamePad : Gamepad;
    private var _controlID : String;
    private var _prevValue : Float = 0;
    private var _value : Float = 0;
    private var _action : String;
    
    private var _active : Bool = false;
    
    public var threshold : Float = 0.1;
    public var inverted : Bool = false;
    public var precision : Float = 100;
    public var digital : Bool = false;
    
    /**
		 * ButtonController is an abstraction of the button controls of a gamepad. This InputController will see its value updated
		 * via its corresponding gamepad object and send his own actions to the Input system.
		 * 
		 * It should not be instantiated manually.
		 */
    public function new(name : String, parentGamePad : Gamepad, controlID : String, action : String = null)
    {
        super(name);
        _gamePad = parentGamePad;
        _controlID = controlID;
        _action = action;
    }
    
    public function updateControl(control : String, value : Float) : Void {
        if (_action != null || _gamePad.triggerActivity)
        {
            value = value * ((inverted) ? -1 : 1);
            _prevValue = _value;
            value = (Std.int(value * precision) >> 0) / precision;
            _value = ((value <= threshold && value >= -threshold)) ? 0 : value;
            _value = (digital) ? Std.int(_value) >> 0 : _value;
        }
        
        if (_action != null)
        {
            if (_prevValue != _value){
                if (_value > 0)
                {
                    triggerCHANGE(_action, _value, null, _gamePad.defaultChannel);
                }
                else
                {
                    triggerOFF(_action, 0, null, _gamePad.defaultChannel);
                }
            }
        }
        
        if (_gamePad.triggerActivity)
        {
            active = _value > 0;
        }
    }
    
   public function set_active(val : Bool) : Bool {
        if (val == _active)
        {
            return val;
        }
        
        if (val)
        {
            triggerCHANGE(name, _value, null, Gamepad.activityChannel);
        }
        else
        {
            triggerOFF(name, 0, null, Gamepad.activityChannel);
        }
        
        _active = val;
        return val;
    }
    
    public function hasControl(id : String) : Bool {
        return _controlID == id;
    }
    
    override public function destroy() : Void {
        _gamePad = null;
        super.destroy();
    }
    
   public function get_value() : Float
    {
        return _value;
    }
    
   public function get_gamePad() : Gamepad
    {
        return _gamePad;
    }
    
   public function get_controlID() : String
    {
        return _controlID;
    }
    
   public function get_action() : String
    {
        return _action;
    }
    
   public function set_action(value : String) : String
    {
        _action = value;
        return value;
    }
}

