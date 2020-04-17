package citrus.input;

import citrus.core.CitrusEngine;
import citrus.input.controllers.Keyboard;
import msignal.Signal;
//import hx.event.Signal;
//import org.osflash.signals.Signal;

/**
	 * A class managing input of any controllers that is an InputController.
	 * Actions are inspired by Midi signals, but they carry an InputAction object.
	 * "action signals" are either ON, OFF, or CHANGE.
	 * to track action status, and check whether action was just triggered or is still on,
	 * actions have phases (see InputAction).
	 **/
class Input
{
    public var enabled(get, set) : Bool;

    private var _ce : CitrusEngine;
    private var _timeActive : Int = 0;
    private var _enabled : Bool = true;
    private var _initialized : Bool;
    
    private var _controllers : Array<InputController>;
    private var _actions : Array<InputAction>;
    
    /**
		 * time interval to clear the InputAction's disposed list automatically.
		 */
    public var clearDisposedActionsInterval : Int = 480;
    
    /**
		 * Lets InputControllers trigger actions.
		 */
    public var triggersEnabled : Bool = true;
    
    private var _routeActions : Bool = false;
    private var _routeChannel : Int;
    
    @:allow(citrus.input)
    private var actionON : Signal1<InputAction>;
    @:allow(citrus.input)
    private var actionOFF : Signal1<InputAction>;
    @:allow(citrus.input)
    private var actionCHANGE : Signal1<InputAction>;
    
    //easy access to the default keyboard
    public var keyboard : Keyboard;
    
    public function new()
    {
        _controllers = new Array<InputController>();
        _actions = new Array<InputAction>();
        
        actionON = new Signal1(InputAction);
        actionOFF = new Signal1(InputAction);
        actionCHANGE = new Signal1(InputAction);
        
        actionON.add(doActionON);
        actionOFF.add(doActionOFF);
        actionCHANGE.add(doActionCHANGE);
        
        _ce = CitrusEngine.getInstance();
    }
    
    public function initialize() : Void {
        if (_initialized)
        {
            return;
        }
        
        //default keyboard
        keyboard = new Keyboard("keyboard");
        
        _initialized = true;
    }
    
    public function addController(controller : InputController) : Void {
        if (_controllers.lastIndexOf(controller) < 0)
        {
            _controllers.push(controller);
        }
    }
    
    public function addAction(action : InputAction) : Void {
        if (_actions.lastIndexOf(action) < 0)
        {
            _actions[_actions.length] = action;
        }
    }
    
    public function controllerExists(name : String) : Bool {
        for (c in _controllers)
        {
            if (name == c.name){
                return true;
            }
        }
        return false;
    }
    
    public function getControllerByName(name : String) : InputController
    {
        var c : InputController;
        for (c in _controllers)
        {
            if (name == c.name){
                return c;
            }
        }
        return null;
    }
    
    /**
		 * Returns the corresponding InputAction object if it has been triggered OFF in this frame or in the previous frame,
		 * or null.
		 */
    public function hasDone(actionName : String, channel : Int = -1) : InputAction
    {
        var a : InputAction;
        for (a in _actions)
        {
            if (a.name == actionName && (channel > -(1) ? ((_routeActions) ? (_routeChannel == channel) : a.channel == channel) : true) && a.phase == InputPhase.END){
               
				return a;
				//return true;
            }
        }
        return null;
    }
    
    /**
		 * Returns the corresponding InputAction object if it has been triggered on the previous frame or is still going,
		 * or null.
		 */
    public function isDoing(actionName : String, channel : Int = -1) : InputAction
    {
        var a : InputAction;
        for (a in _actions)
        {
            if (a.name == actionName && (channel > -(1) ? ((_routeActions) ? (_routeChannel == channel) : a.channel == channel) : true) && a.time > 1 && a.phase < InputPhase.END){
                return a;
               // return true;
            }
        }
        return null;
    }
	
		public function isDoingAny(channel : Int = -1) : Bool{
        var a : InputAction;
        for (a in _actions){
            if ((channel > -(1) ? ((_routeActions) ? (_routeChannel == channel) : a.channel == channel) : true) && a.time > 1 && a.phase < InputPhase.END){
                return true;
            }
        }
       
        return false;
    }
    
    /**
		 * Returns the corresponding InputAction object if it has been triggered on the previous frame.
		 */
    public function justDid(actionName : String, channel : Int = -1) : InputAction
    {
        var a : InputAction;
        for (a in _actions)
        {
            if (a.name == actionName && (channel > -(1) ? ((_routeActions) ? (_routeChannel == channel) : a.channel == channel) : true) && a.time == 1){
               return a;
               // return true;
            }
        }
        return null;
    }
	
	public function justDidAny(channel : Int = -1) : Bool
    {
         var a : InputAction;
        for (a in _actions) {
            if ((channel > -(1) ? ((_routeActions) ? (_routeChannel == channel) : a.channel == channel) : true) && a.time == 1){
            return true;
            }
        }
      
        return false;
    }
    
    /**
		 * get an action by name from the current 'active' actions , optionnally filtered by channel, controller or phase.
		 * returns null if no actions are found.
		 * 
		 * example :
		 * <code>
		 * var action:InputAction = _ce.input.getAction("jump",-1,null,InputPhase.ON);
		 * if(action &amp;&amp; action.time > 120)
		 *    trace("the jump action lasted for more than 120 frames. its value is",action.value);
		 * </code>
		 * 
		 * keep doing the jump action for about 2 seconds (if running at 60 fps) and you'll see the trace.
		 * @param	name
		 * @param	channel -1 to include all channels.
		 * @param	controller null to include all controllers.
		 * @param	phase -1 to include all phases.
		 * @return	InputAction
		 */
    public function getAction(name : String, channel : Int = -1, controller : InputController = null, phase : Int = -1) : InputAction
    {
        var a : InputAction;
        for (a in _actions)
        {
            if (name == a.name && (channel == -(1) ? true : ((_routeActions) ? (_routeChannel == channel) : a.channel == channel)) && ((controller != null) ? a.controller == controller : true) && (phase == -(1) ? true : a.phase == phase)){
                return a;
            }
        }
        return null;
    }
    
    /**
		 * Returns a list of active actions, optionnally filtered by channel, controller or phase.
		 * return an empty Vector.&lt;InputAction&gt; if no actions are found.
		 * 
		 * @param	channel -1 to include all channels.
		 * @param	controller null to include all controllers.
		 * @param	phase -1 to include all phases.
		 * @return
		 */
    public function getActions(channel : Int = -1, controller : InputController = null, phase : Int = -1) : Array<InputAction>
    {
        var actions : Array<InputAction> = new Array<InputAction>();
        var a : InputAction;
        for (a in _actions)
        {
            if ((channel == -(1) ? true : ((_routeActions) ? (_routeChannel == channel) : a.channel == channel)) && ((controller != null) ? a.controller == controller : true) && (phase == -(1) ? true : a.phase == phase)){
                actions.push(a);
            }
        }
        return actions;
    }
    
    /**
		 * Adds a new action of phase 0 if it does not exist.
		 */
    @:allow(citrus.input)
    private function doActionON(action : InputAction) : Void {
        if (!triggersEnabled)
        {
            action.dispose();
            return;
        }
        var a : InputAction;
        
        for (a in _actions)
        {
            if (a.eq(action)){
                a._phase = InputPhase.BEGIN;
                action.dispose();
                return;
            }
        }
        action._phase = InputPhase.BEGIN;
        _actions[_actions.length] = action;
    }
    
    /**
		 * Sets action to phase 3. will be advanced to phase 4 in next update, and finally will be removed
		 * on the update after that.
		 */
    @:allow(citrus.input)
    private function doActionOFF(action : InputAction) : Void {
        if (!triggersEnabled)
        {
            action.dispose();
            return;
        }
        var a : InputAction;
        for (a in _actions)
        {
            if (a.eq(action)){
                a._phase = InputPhase.END;
                a._value = action._value;
                a._message = action._message;
                action.dispose();
                return;
            }
        }
    }
    
    /**
		 * Changes the value property of an action, or adds action to list if it doesn't exist.
		 * a continuous controller, can simply trigger ActionCHANGE and never have to trigger ActionON.
		 * this will take care adding the new action to the list, setting its phase to 0 so it will respond
		 * to justDid, and then only the value will be changed. - however your continous controller DOES have
		 * to end the action by triggering ActionOFF.
		 */
    @:allow(citrus.input)
    private function doActionCHANGE(action : InputAction) : Void {
        if (!triggersEnabled)
        {
            action.dispose();
            return;
        }
        var a : InputAction;
        for (a in _actions)
        {
            if (a.eq(action)){
                a._phase = InputPhase.ON;
                a._value = action._value;
                a._message = action._message;
                action.dispose();
                return;
            }
        }
        action._phase = InputPhase.BEGIN;
        _actions[_actions.length] = action;
    }
    
    /**
		 * Input.update is called in the end of your state update.
		 * keep this in mind while you create new controllers - it acts only after everything else.
		 * update first updates all registered controllers then finally
		 * advances actions phases by one if not phase 2 (phase two can only be voluntarily advanced by
		 * doActionOFF.) and removes actions of phase 4 (this happens one frame after doActionOFF was called.)
		 */
    public function update() : Void {
        if (InputAction.disposed.length > 0 && _timeActive % clearDisposedActionsInterval == 0)
        {
            InputAction.clearDisposed();
        }
        _timeActive++;
        
        if (!_enabled)
        {
            return;
        }
        
        var c : InputController;
        for (c in _controllers)
        {
            if (c.updateEnabled && c.enabled){
                c.update();
            }
        }

        for (i in 0..._actions.length)
        {
			var thisAction:InputAction = _actions[i];
			
			if (thisAction!=null){
				thisAction.itime++;
				if (thisAction.phase > InputPhase.END)
				{
					thisAction.dispose();
					_actions.splice(i, 1);
				}
				else if (_actions[i].phase != InputPhase.ON)
				{
				  thisAction._phase++;
				}
			}
        }
    }
    
    public function removeController(controller : InputController) : Void {
        var i : Int = _controllers.lastIndexOf(controller);
        stopActionsOf(controller);
        _controllers.splice(i, 1);
    }
    
    public function stopActionsOf(controller : InputController, channel : Int = -1) : Void {
        var action : InputAction;
        for (action in _actions)
        {
            if (action.controller != controller){
                continue;
            }
            
            if (channel > -1){
                if (action.channel == channel)
                {
                    action._phase = InputPhase.ENDED;
                }
            }
            else
            {
                action._phase = InputPhase.ENDED;
            }
        }
    }
    
    public function resetActions() : Void {
       _actions = new Array<InputAction>();
    }
    
    /**
		 *  addOrSetAction sets existing parameters of an action to new values or adds action if
		 *  it doesn't exist.
		 */
    public function addOrSetAction(action : InputAction) : Void {
        var a : InputAction;
        for (a in _actions)
        {
            if (a.eq(action)){
                a._phase = action.phase;
                a._value = action.value;
                return;
            }
        }
        _actions[_actions.length] = action;
    }
    
    /**
		 * returns a Vector of all actions in current frame.
		 * actions are cloned (no longer active inside the input system) 
		 * as opposed to using getActions().
		 */
    public function getActionsSnapshot() : Array<InputAction>
    {
        var snapshot : Array<InputAction> = new Array<InputAction>();
        var a : InputAction;
        for (a in _actions)
        {
            snapshot.push(a.clone());
        }
        return snapshot;
    }
    
    /**
		 * Start routing all actions to a single channel - used for pause menus or generally overriding the Input system.
		 */
    public function startRouting(channel : Int) : Void {
        _routeActions = true;
        _routeChannel = channel;
    }
    
    /**
		 * Stop routing actions.
		 */
    public function stopRouting() : Void {
        _routeActions = false;
        _routeChannel = 0;
    }
    
    /**
		 * Helps knowing if Input is routing actions or not.
		 */
    public function isRouting() : Bool {
        return _routeActions;
    }
    
   public function get_enabled() : Bool {
        return _enabled;
    }
    
   public function set_enabled(value : Bool) : Bool {
        if (_enabled == value)
        {
            return value;
        }
        
        var controller : InputController;
        for (controller in _controllers)
        {
            controller.enabled = value;
        }
        
        _enabled = value;
        return value;
    }
    
    private function destroyControllers() : Void {
        for (c in _controllers)
        {
            c.destroy();
        }
        as3hx.Compat.setArrayLength(_controllers, 0);
        as3hx.Compat.setArrayLength(_actions, 0);
    }
    
    public function destroy() : Void {
        destroyControllers();
        
        actionON.removeAll();
        actionOFF.removeAll();
        actionCHANGE.removeAll();
        
        resetActions();
        InputAction.clearDisposed();
    }
}

