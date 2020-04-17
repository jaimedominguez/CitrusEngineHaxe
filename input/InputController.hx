package citrus.input;

import flash.errors.Error;

import citrus.core.CitrusEngine;

/**
	 * InputController is the parent of all the controllers classes. It provides the same helper that CitrusObject class : 
	 * it can be initialized with a params object, which can be created via an object parser/factory. 
	 */
class InputController
{
   public var defaultChannel(get, set) : Int;
    public var enabled(get, set) : Bool;
    public var updateEnabled(get, never) : Bool;

    public static var hideParamWarnings : Bool = false;
    
    public var name : String;
    
    private var _ce : CitrusEngine;
    private var _input : Input;
    private var _initialized : Bool;
    private var _enabled : Bool = true;
    private var _updateEnabled : Bool = false;
    private var _defaultChannel : Int = 0;
    
    private var inputAction : InputAction;
    
    public function new(name : String, params : Dynamic = null)
    {
		this.name = name;
        
        setParams(params);
        
        _ce = CitrusEngine.getInstance();
        _input = _ce.input;
        
        _ce.input.addController(this);
    }
    
   
		 //Override this function if you need your controller to update when CitrusEngine updates the Input instance.
		 
    public function update() : Void {
    }
    
    
		//Will register the inputAction to the Input system as an inputAction with an InputPhase.BEGIN phase.
		// @param	name string that defines the inputAction such as "jump" or "fly"
		 // @param	value optional value for your inputAction.
		// @param	message optional message for your inputAction.
		// @param	channel optional channel for your inputAction. (will be set to the defaultChannel if not set.
	
    private function triggerON(name : String, value : Float = 0, message : String = null, channel : Int = -1) : InputAction
  
    {

		//trace("triggerON:" + name  + " [" + channel + "]");
		
		
        if (_enabled)
        {
            inputAction = InputAction.create(name, this, ((channel < 0)) ? defaultChannel : channel, value, message);
            _input.actionON.dispatch(inputAction);
            return inputAction;
        }
        return null;
    }
    

		 //Will register the inputAction to the Input system as an inputAction with an InputPhase.END phase.
		 // @param	name string that defines the inputAction such as "jump" or "fly"
		 // @param	value optional value for your inputAction.
		 // @param	message optional message for your inputAction.
		 // @param	channel optional channel for your inputAction. (will be set to the defaultChannel if not set.
		
    private function triggerOFF(name : String, value : Float = 0, message : String = null, channel : Int = -1) : InputAction
    {
		//trace("triggerOFF:" + name  + " [" + channel + "]");
		
        if (_enabled)
        {
            inputAction = InputAction.create(name, this, ((channel < 0)) ? defaultChannel : channel, value, message);
            _input.actionOFF.dispatch(inputAction);
            return inputAction;
        }
        return null;
    }
    
 
		 // Will register the inputAction to the Input system as an inputAction with an InputPhase.BEGIN phase if its not yet in the 
		 // inputActions list, otherwise it will update the existing inputAction's value and set its phase back to InputPhase.ON.
		 // @param	name string that defines the inputAction such as "jump" or "fly"
		 // @param	value optional value for your inputAction.
		 // @param	message optional message for your inputAction.
		 // @param	channel optional channel for your inputAction. (will be set to the defaultChannel if not set.
		 
    private function triggerCHANGE(name : String, value : Float = 0, message : String = null, channel : Int = -1) : InputAction
    {
        if (_enabled)
        {
            inputAction = InputAction.create(name, this, ((channel < 0)) ? defaultChannel : channel, value, message);
            _input.actionCHANGE.dispatch(inputAction);
            return inputAction;
        }
        return null;
    }
    

		 // Will register the inputAction to the Input system as an inputAction with an InputPhase.END phase if its not yet in the 
		 // inputActions list as well as a time to 1 (so that it will be considered as already triggered.
		 // @param	name string that defines the inputAction such as "jump" or "fly"
		 // @param	value optional value for your inputAction.
		 // @param	message optional message for your inputAction.
		 // @param	channel optional channel for your inputAction. (will be set to the defaultChannel if not set.
		 
    private function triggerONCE(name : String, value : Float = 0, message : String = null, channel : Int = -1) : InputAction
    {
        if (_enabled)
        {
            inputAction = InputAction.create(name, this, ((channel < 0)) ? defaultChannel : channel, value, message, InputPhase.END);
            _input.actionON.dispatch(inputAction);
            inputAction = InputAction.create(name, this, ((channel < 0)) ? defaultChannel : channel, value, message, InputPhase.END);
            _input.actionOFF.dispatch(inputAction);
            return inputAction;
        }
        return null;
    }
    
   public function get_defaultChannel() : Int
    {
        return _defaultChannel;
    }
    
   public function set_defaultChannel(value : Int) : Int
    {
        if (value == _defaultChannel)
        {
            return value;
        }
        
        _input.stopActionsOf(this);
        _defaultChannel = value;
        return value;
    }
    
   public function get_enabled() : Bool {
        return _enabled;
    }
    
   public function set_enabled(val : Bool) : Bool {
        _enabled = val;
        return val;
    }
    
   public function get_updateEnabled() : Bool {
        return _updateEnabled;
    }
    
    
		 //Removes this controller from Input.
		 
    public function destroy() : Void {
        _input.removeController(this);
    }
    
    public function toString() : String
    {
        return name;
    }
    
    private function setParams(object : Dynamic) : Void {
        for (param in Reflect.fields(object))
        {
            try
            {
                if (Reflect.field(object, param) == "true")
                {
                    Reflect.setField(this, param, true);
                }
                else if (Reflect.field(object, param) == "false")
                {
                    Reflect.setField(this, param, false);
                }
                else
                {
                    Reflect.setField(this, param, Reflect.field(object, param));
                }
            }
            catch (e : Error){
                if (!hideParamWarnings)
                {
                    trace("Warning: The parameter " + param + " does not exist on " + this);
                }
            }
        }
        
        _initialized = true;
    }
}

