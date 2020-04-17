package citrus.input.controllers.gamepad.controls;

import citrus.input.controllers.gamepad.Gamepad;
import citrus.input.InputController;
import citrus.math.MathVector;

class StickController extends InputController implements Icontrol
{
    private var stickActive(never, set) : Bool;
    public var y(get, never) : Float;
    public var x(get, never) : Float;
    public var up(get, never) : Float;
    public var down(get, never) : Float;
    public var left(get, never) : Float;
    public var right(get, never) : Float;
    public var length(get, never) : Float;
    public var angle(get, never) : Float;
    public var hAxis(get, never) : String;
    public var vAxis(get, never) : String;
    public var gamePad(get, never) : Gamepad;

    private var _gamePad : Gamepad;
    
    private var _hAxis : String;
    private var _vAxis : String;
    
    private var _prevRight : Float = 0;
    private var _prevLeft : Float = 0;
    private var _prevUp : Float = 0;
    private var _prevDown : Float = 0;
    
    private var _vec : MathVector;
    
    public var upAction : String;
    public var downAction : String;
    public var leftAction : String;
    public var rightAction : String;
    
    private var _downActive : Bool = false;
    private var _upActive : Bool = false;
    private var _leftActive : Bool = false;
    private var _rightActive : Bool = false;
    private var _stickActive : Bool = false;
    
    public var invertX : Bool;
    public var invertY : Bool;
    public var threshold : Float = 0.1;
    public var precision : Int = 100;
    public var digital : Bool = false;
    
    /**
		 * StickController is an abstraction of the stick controls of a gamepad. This InputController will see its axis values updated
		 * via its corresponding gamepad object and send his own actions to the Input system.
		 * 
		 * It should not be instantiated manually.
		 * 
		 * @param	name
		 * @param	hAxis left to right
		 * @param	vAxis up to down
		 * @param	up action name
		 * @param	right action name
		 * @param	down action name
		 * @param	left action name
		 * @param	invertX
		 * @param	invertY
		 */
    public function new(name : String, parentGamePad : Gamepad, hAxis : String, vAxis : String, up : String = null, right : String = null, down : String = null, left : String = null, invertX : Bool = false, invertY : Bool = false)
    {
        super(name);
        _gamePad = parentGamePad;
        upAction = up;
        downAction = down;
        leftAction = left;
        rightAction = right;
        _hAxis = hAxis;
        _vAxis = vAxis;
        this.invertX = invertX;
        this.invertY = invertY;
        _vec = new MathVector();
    }
    
    public function hasControl(id : String) : Bool {
        return (id == _hAxis || id == _vAxis);
    }
    
    public function updateControl(control : String, value : Float) : Void {
        value = (Std.int(value * precision) >> 0) / precision;
        
        value = ((value <= threshold && value >= -threshold)) ? 0 : value;
        //trace("control:" + control + "=" + value);
        if (control == _vAxis)
        {
            _prevUp = up;
            _prevDown = down;
            
            _vec.y = ((digital) ? Std.int(value) >> 0 : value) * ((invertY) ? -1 : 1);
            
            if (downAction != null && _prevDown != down){
                if (_downActive && (_prevDown > down || down == 0))
                {
                    triggerOFF(downAction, 0, null, _gamePad.defaultChannel);
                    _downActive = false;
                }
                if (down > 0)
                {
                    triggerCHANGE(downAction, down, null, _gamePad.defaultChannel);
                    _downActive = true;
                }
            }
            
            if (upAction != null && _prevUp != up){
                if (_upActive && (_prevUp > up || up == 0))
                {
                    triggerOFF(upAction, 0, null, _gamePad.defaultChannel);
                    _upActive = false;
                }
                if (up > 0)
                {
                    triggerCHANGE(upAction, up, null, _gamePad.defaultChannel);
                    _upActive = true;
                }
            }
        }
        else if (control == _hAxis)
        {
            _prevLeft = left;
            _prevRight = right;
            
            _vec.x = ((digital) ? Std.int(value) >> 0 : value) * ((invertX) ? -1 : 1);
            
            if (leftAction != null && _prevLeft != left){
                if (_leftActive && _prevLeft > left || left == 0)
                {
                    triggerOFF(leftAction, 0, null, _gamePad.defaultChannel);
                    _leftActive = false;
                }
                if (left > 0)
                {
                    triggerCHANGE(leftAction, left, null, _gamePad.defaultChannel);
                    _leftActive = true;
                }
            }
            
            if (rightAction != null && _prevRight != right){
                if (_rightActive && _prevRight > right || right == 0)
                {
                    triggerOFF(rightAction, 0, null, _gamePad.defaultChannel);
                    _rightActive = false;
                }
                if (right > 0)
                {
                    triggerCHANGE(rightAction, right, null, _gamePad.defaultChannel);
                    _rightActive = true;
                }
            }
        }
        
        if (_gamePad.triggerActivity)
        {
            stickActive = (_vec.length == 0) ? false : true;
        }
    }
    
   public function set_stickActive(val : Bool) : Bool {
        if (val == _stickActive)
        {
            return val;
        }
        else
        {
            if (val){
                triggerCHANGE(name, 1, null, Gamepad.activityChannel);
            }
            else
            {
                triggerOFF(name, 0, null, Gamepad.activityChannel);
            }
            
            _stickActive = val;
        }
        return val;
    }
    
   public function get_y() : Float
    {
        return _vec.y;
    }
    
   public function get_x() : Float
    {
        return _vec.x;
    }
    
   public function get_up() : Float
    {
        return -_vec.y;
    }
    
   public function get_down() : Float
    {
        return _vec.y;
    }
    
   public function get_left() : Float
    {
        return -_vec.x;
    }
    
   public function get_right() : Float
    {
        return _vec.x;
    }
    
   public function get_length() : Float
    {
        return _vec.length;
    }
    
   public function get_angle() : Float
    {
        return _vec.angle;
    }
    
   public function get_hAxis() : String
    {
        return _hAxis;
    }
    
   public function get_vAxis() : String
    {
        return _vAxis;
    }
    
   public function get_gamePad() : Gamepad
    {
        return _gamePad;
    }
    
    override public function destroy() : Void {
        _vec = null;
        super.destroy();
    }
}

