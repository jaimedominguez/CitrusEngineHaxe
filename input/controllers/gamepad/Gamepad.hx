package citrus.input.controllers.gamepad;
import citrus.input.InputController;
import citrus.input.controllers.gamepad.controls.ButtonController;
import citrus.input.controllers.gamepad.controls.Icontrol;
import citrus.input.controllers.gamepad.controls.StickController;
import citrus.input.controllers.gamepad.maps.GamepadMap;
import kaleidoEngine.data.texts.Strings;
import kaleidoEngine.data.utils.object.Objects;
import flash.errors.Error;
import flash.events.Event;
import flash.ui.GameInputControl;
import openfl.ui.GameInputDevice;
import flash.utils.Dictionary;
import openfl.Vector;

class Gamepad extends InputController
{
   public var triggerActivity(get, set) : Bool;
    public var device(get, never) : GameInputDevice;
    public var deviceID(get, never) : String;
    public var deviceNpadID(get, never) : Int;

    private var _device : GameInputDevice;
    private var _deviceID : String;
    private var _npadID : Int;
	private var _controls : Dictionary<String,GameInputControl>;	
	
		
    private var _buttons : Dictionary<String,ButtonController>;
	
	//stick controller used, indexed by name.
    private var _sticks : Dictionary<String,StickController>;
	
	//controls being used, indexed by GameInputControl.id
	//(quick access for onChange)
    private var _usedControls : Dictionary<String,Array<Icontrol>>;
	
	//will trace information on the gamepad at runtime.
    public var debug : Bool = false;
    public static var activityChannel : Int = 100;


	//if set to true, all 'children controllers' will send an action with their controller name when active (value != 0) 
	//helps figuring out which button someone touches for remapping in game for example.
    public var _triggerActivity : Bool = false;
    
    public var currentMap : GamepadMap;
    
   public function get_triggerActivity() : Bool {
        return _triggerActivity;
    }
    
   public function set_triggerActivity(val : Bool) : Bool {
        if (_triggerActivity == val)
        {
            return val;
        }
        
        _triggerActivity = val;
        return val;
    }
    
    public function new(name : String, device : GameInputDevice, map : GamepadMap = null, params : Dynamic = null)
    {
        super(name, params);
        
        _device = device;
  
        _deviceID = _device.id;
        _npadID = _device.npadID;
        _controls = new Dictionary<String,GameInputControl>();
        
        enabled = true;
        initControlsList();
        
        _buttons = new Dictionary<String,ButtonController>();
        _sticks = new Dictionary<String,StickController>();
        
        _usedControls = new Dictionary<String,Array<Icontrol>>();
		
		
		_updateEnabled = true;
		
		
		//trace(" NEW CONTROLLER: [" + name+"]. using _npadID:" + _npadID);
    }
    
	//list all available controls by their control.id and start caching.
		
    private function initControlsList() : Void {
        var controlNames : Vector<String> = new Vector<String>();
        var control : GameInputControl;
        var i : Int = 0;
        var numcontrols : Int = _device.numControls;
        while (i < numcontrols)
        {
            control = _device.getControlAt(i);
            _controls[control.id] = control;
            controlNames.push(control.id);
            i++;
        }
        
        //trace(">> THIS DEVICE HAS A TOTAL OF " + numcontrols + " CONTROLS.");
        
        _device.startCachingSamples(30, controlNames);
    }
    
	//
		//apply GamepadMap
		//@param	map
		
    public function useMap(map : Class<Dynamic>) : Void {
        if (map != null){
        
            var mapconfig : GamepadMap = Type.createInstance(map, []);
            mapconfig.setup(this);
            
            if (debug){
                trace(name, "using map", map);
            }
        }
        stopAllActions();
        fillUnbindedMap();
    }
    
    private function onChange(e : Event) : Void {
        if (!_enabled)
        {
            return;
        }
        
        var id : String = cast(e.currentTarget, GameInputControl).id;

        if (_usedControls[id]==null)
        {
            log(id+ "seems to not be bound to any controls for"+this);
            return;
        }
        
        var value : Float = cast(e.currentTarget, GameInputControl).value;
        
        var icontrols : Array<Icontrol> = _usedControls[id];
        var icontrol : Icontrol;
        
        for (icontrol in icontrols)
        {
            icontrol.updateControl(id, value);
        }
    }
    
    private function bindControl(controlid : String, controller : Icontrol) : Void {
        if (_controls[controlid]==null)
        {
           
            log("trying to bind "+ controlid+ ". but "+ controlid+ " is not in listed controls for device"+ _device.name);
            return;
        }
        
        var control : GameInputControl = cast(_controls[controlid], GameInputControl) ;
        
        if (!control.hasEventListener(Event.CHANGE))
        {
            control.addEventListener(Event.CHANGE, onChange);
        }
        
        if (_usedControls[controlid]==null)
        {
           _usedControls[controlid] = new Array<Icontrol>();
        }
        
       
         log("Binding "+ control.id+ " to: "+ controller);
       
        
		_usedControls[controlid].push(controller);
    }
    
    private function unbindControl(controlid : String, controller : Icontrol) : Void {
        if (_usedControls[controlid]!=null)
        {
            if (Std.is(_usedControls[controlid],  Array)){
                var controls : Array<Icontrol> = _usedControls[controlid];
                var icontrol : Icontrol;
                var i : String = "";
                
                for (i in 0...controls.length){
					icontrol = controls[i];
                 
                    if (icontrol == controller)
                    {
                        controls.splice(i, 1);
                        break;
                    }
                }
                
                if (controls.length == 0){
                    Objects.removeKey(_usedControls, controlid);
					
                    if (_controls[controlid].hasEventListener(Event.CHANGE))
                    {
                        _controls[controlid].removeEventListener(Event.CHANGE, onChange);
                    }
                }
            }
        }
    }
    
    public function unregisterStick(name : String) : Void {
       
        var stick : StickController = _sticks[name];
        if (stick != null)
        {
            unbindControl(stick.hAxis, stick);
            unbindControl(stick.vAxis, stick);
           
			Objects.removeKey(_sticks, name);
            stick.destroy();
        }
    }
    
    public function unregisterButton(name : String) : Void {
        var button : ButtonController = _buttons[name];
        if (button != null)
        {
            unbindControl(button.controlID, button);
            Objects.removeKey(_buttons, name);
            button.destroy();
        }
    }
    
   //
		//Register a new stick controller to the gamepad.
		//leave all or any of up/right/down/left actions to null for these directions to trigger nothing.
		//invertX and invertY inverts the axis values.
		//@param	name
		//@param	hAxis the GameInputControl id for the horizontal axis (left to right).
		//@param	vAxis the GameInputControl id for the vertical axis (up to donw).
		//@param	up
		//@param	right
		//@param	down
		//@param	left
		//@param	invertX
		//@param	invertY
		//@return
		
    public function registerStick(name : String, hAxis : String, vAxis : String, up : String = null, right : String = null, down : String = null, left : String = null, invertX : Bool = false, invertY : Bool = false) : StickController
    {
        if (_sticks[name]!=null)
        {
            if (debug){
                trace(this + " joystick control " + name + " already exists");
            }
            return _sticks[name];
        }
        
        var joy : StickController = new StickController(name, this, hAxis, vAxis, up, right, down, left, invertX, invertY);
        bindControl(hAxis, joy);
        bindControl(vAxis, joy);
        return _sticks[name] = joy;
    }
    
   //
		//Register a new button controller to the gamepad.
		//if action is null, this button will trigger no action.
		//@param	name
		//@param	control_id the GameInputControl id.
		//@param	action
		//@return
		
    public function registerButton(name : String, control_id : String, action : String = null, unregisterFirst : Bool = false) : ButtonController
    {
        if (unregisterFirst)
        {
            unregisterButton(name);
        }
        
		
        if (_buttons[name]!=null)
        {
            if (debug){
                trace(this + " button control " + name + " already exists");
            }
            return _buttons[name];
        }
        var button : ButtonController = new ButtonController(name, this, control_id, action);
        bindControl(control_id, button);
        return _buttons[name] = button;
    }
    
    
   //
		//Set a registered stick's actions, leave null to keep unchanged.
		//@param	name
		//@param	up
		//@param	right
		//@param	down
		//@param	left
		
    public function setStickActions(name : String, up : String, right : String, down : String, left : String) : Void {
        if (_sticks[name]==null)
        {
            throw new Error(this + "cannot set joystick control, " + name + " is not registered.");
            return;
        }
        
        var joy : StickController = _sticks[name];
        
        if (up != null)
        {
            joy.upAction = up;
        }
        if (right != null)
        {
            joy.rightAction = right;
        }
        if (down != null)
        {
            joy.downAction = down;
        }
        if (left != null)
        {
            joy.leftAction = left;
        }
		
		
    }
    
    
    public function getButtonFromAction(actionName : String) : ButtonController
    {
        for (button in _buttons) {
			var thisButton : ButtonController = _buttons[button];
            if (thisButton.action == actionName) {
                return thisButton;
            }
        }
        return null;
    }
    
    
   //
		//Set a registered button controller action.
		//@param	name 
		//@param	action
		
    public function setButtonAction(name : String, action : String) : Void {
        if (_buttons[name]==null){
            //trace ("ERROR:" + this + " cannot set button control, " + name + " is not registered.");
			return;
        }
        
       _buttons[name].action = action;
    }
    
    public function swapButtonActions(button1Name : String, button2Name : String) : Void {
        var b1 : ButtonController = getButton(button1Name);
        var b2 : ButtonController = getButton(button2Name);
        if (b1 == null || b2 == null)
        {
            return;
        }
        var action1 : String = b1.action;
        b1.action = b2.action;
        b2.action = action1;
    }
    
    public function removeActionFromControllers(actionName : String) : Void {
        removeActionFromButtons(actionName);
        removeActionFromSticks(actionName);
    }
    
    public function removeActionFromButtons(actionName : String) : Void {
        for (button in _buttons)
        {
			var thisButton : ButtonController  = _buttons[button];
            if (thisButton.action == actionName){
                _buttons[button].action = null;
            }
        }
    }
    
    public function removeActionFromSticks(actionName : String) : Void {
        for (stick in _sticks)
        {
			var thisStick : StickController  = _sticks[stick];
            if (thisStick.upAction == actionName){
                thisStick.upAction = null;
                continue;
            }
            
            if (thisStick.rightAction == actionName){
                thisStick.rightAction = null;
                continue;
            }
            
            if (thisStick.downAction == actionName){
                thisStick.downAction = null;
                continue;
            }
            
            if (thisStick.leftAction == actionName){
                thisStick.leftAction = null;
                continue;
            }
        }
    }
    
   //
		//get registered stick as a StickController to get access to the angle of the joystick for example.
		//@param	name
		//@return
		
    public function getStick(name : String) : StickController
    {
        if (_sticks[name]!=null)
        {
            return _sticks[name];
        }
        return null;
    }
    
   //
		//get added button as a ButtonController
		//@param	name
		//@return
		
    public function getButton(name : String) : ButtonController
    {
        if (_buttons[name]!=null)
        {
            return _buttons[name];
        }
        return null;
    }
    
   public function get_device() : GameInputDevice
    {
        return _device;
    }
    
   public function get_deviceID() : String
    {
        return _deviceID;
    }
    
    public function stopAllActions() : Void {
        var icontrols : Array<Icontrol>;
        var icontrol : Icontrol;
        
        for (controlID in _usedControls)
        {
			icontrols = _usedControls[controlID];
            for (icontrol in icontrols){
                _ce.input.stopActionsOf(cast(icontrol, InputController));
            }
        }
    }
    
    override public function set_enabled(val : Bool) : Bool {
        _device.enabled = _enabled = val;
        return val;
    }
    
    override public function destroy() : Void {
        var control : Icontrol;
        for (control in _buttons)
        {
            unregisterButton(_buttons[control].name);
        }
        for (control in _sticks)
        {
            unregisterStick(_sticks[control].name);
        }
        
		
        _usedControls = null;
        _controls = null;
       
        enabled = false;
     
        _input.stopActionsOf(this);
      
        _buttons = null;
        _sticks = null;
       
        super.destroy();
    }
    
    public function fillUnbindedMap() : Void {
     //  log("fillUnbindedMap()");
        var controlID : String = "";
        for (control in _controls)
        {
            controlID = _controls[control].id;
            if (debug){
            //    log("UNBINDED:" + controlID);
            }
            if (controlID.indexOf("BUTTON") > -1){
                var buttonName : String = Strings.strReplace("BUTTON", "UNMAPPED", controlID);
				//	log("[]CHECKING CONTROL:" + controlID);
                
                if (_usedControls[controlID]==null){
					//log("[]REGISTERING BUTTON("+buttonName+","+ controlID+")");
                    registerButton(buttonName, controlID);
                }
            }
        }
    }
	
	override public function update() : Void {

	//	trace(getButtonsDebugData());
    }
	
	public function getButtonsDebugData() : String
    {
		var debugText:String = "";
		for (controlID in _controls) {
			var thisControl:GameInputControl = _controls[controlID];
			if (thisControl.value != 0){
				debugText = "\n" + "thisControl:" + thisControl.id + "="+thisControl.value;
			}
		}
		return debugText;
    }
	
	
	
	
	function get_deviceNpadID():Int {
		return _npadID;
	}
	
	 private function log(text : String) : Void {
      //trace("[CONTROLLERS]" + text);

    }
	
	
}
