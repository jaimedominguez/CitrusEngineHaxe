package citrus.input.controllers.gamepad;

import citrus.input.controllers.gamepad.controls.ButtonController;
import citrus.input.controllers.gamepad.controls.StickController;
import msignal.Signal.Signal1;

import citrus.input.InputAction;
import citrus.input.InputController;
import citrus.input.InputPhase;
import flash.events.TimerEvent;
import flash.utils.Timer;


/**
	 * Experimental InputController that waits for a new gamepad buttons pressed to assign a new button to it.
	 *
	 * var buttonRebinder:GamePadButtonRebinder = new GamePadButtonRebinder("", "down", true, true, 5000);
	 *              buttonRebinder.onDone.add(function(ok:Boolean):void
	 *              {
	 *                      if (ok)
	 *                              trace("ACTION HAS BEEN REBOUND CORRECTLY.");
	 *                      else
	 *                              trace("ACTION HAS NOT BEEN REBOUND, TIMER IS COMPLETE.");
	 *              });
	 */
class GamePadButtonRebinder extends InputController
{
    
    private var _actionName : String;
    private var _route : Bool;
    private var _removeActions : Bool;
    private var _gamePadManager : GamePadManager;
    private var _gamePadIndex : Int;
    private var _gamePad : Gamepad;
    private var _timeOut : Int;
    private var _timer : Timer;
    
    private var _success : Bool = false;
   
	private var time : Int = 0;
    /**
		 * dispatches true if rebound correctly, or false if timer is over.
		 */
    public var onDone : Signal1<Bool>;
    
    private var gp : Gamepad;
    
    public function new(name : String, action : String, route : Bool = true, removeActions : Bool = true, timeOut : Int = -1, gamePadIndex : Int = -1)
    {
        _actionName = action;
        _route = route;
        _removeActions = removeActions;
        super(name);
        _updateEnabled = true;
        _gamePadIndex = gamePadIndex;
        
        _gamePadManager = GamePadManager.getInstance();
        
        if (_gamePadManager == null)
        {
            trace("ERROR");
            destroy();
        }
        
        onDone = new Signal1(Bool);
        
        _timeOut = timeOut;
        
        if (_gamePadIndex > -1)
        {
            _gamePad = _gamePadManager.getGamePadAt(_gamePadIndex);
            _gamePad.triggerActivity = true;
        }
        else
        {
            var i : Int = 0;
            while (i < _gamePadManager.numGamePads){
                gp = _gamePadManager.getGamePadAt(i);
                gp.triggerActivity = true;
                i++;
            }
        }
        
        if (_route)
        {
            _input.startRouting(999);
        }
        
        if (_timeOut > -1)
        {
            _timer = new Timer(_timeOut, 1);
            _timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
            _timer.start();
        }
    }
    
   
    
    override public function update() : Void {
        time++;
        
        if (time % 2 == 0)
        {
            return;
        }
        
        var actions : Array<InputAction> = _input.getActions(999);
        //var actions:Vector.<InputAction> = _input.getActions();
        if (actions.length > 0)
        {
            trace("THERE ARE " + actions.length + " ACTIONS.");
            for (action in actions){
                if (Std.is(action.controller, ButtonController))
                {
                    setGamePadButton(action);
                    _success = true;
                }  /*else if (action.controller is StickController){
						trace("ACTION CONTROLLER: " + action.controller.name);
						setStickDirection(action);
						_success = true;
						
					}*/  
                
                if (_success)
                {
                    destroy();  //destroy self  
                    break;
                }
            }
        }
    }
    
    private function setGamePadButton(action : InputAction) : Void {
        var b : ButtonController = try cast(action.controller, ButtonController) catch(e:Dynamic) null;
        if ((_gamePad != null && b.gamePad == _gamePad) || _gamePad == null)
        {
            trace("GOT ACTION:" + _actionName);
            _input.stopActionsOf(b);  // stop action of ButtonController  
            if (_removeActions){
                b.gamePad.removeActionFromButtons(_actionName);
            }
            b.gamePad.setButtonAction(b.name, _actionName);  //set new action  
            trace("GOT ACTION IN:" + b.name);
        }
    }
    
    
    private function setStickDirection(action : InputAction) : Void {
        var b : StickController = try cast(action.controller, StickController) catch(e:Dynamic) null;
        
        if ((_gamePad != null && b.gamePad == _gamePad) || _gamePad == null)
        {
            trace("GOT STICK ACTION:" + _actionName + "[" + b.name + "]");
            _input.stopActionsOf(b);  // stop action of ButtonController  
            
            var nameLEFT : String = "";
            var nameUP : String = "";
            var nameDOWN : String = "";
            var nameRIGHT : String = "";
            
            switch (_actionName){
                case "up":
                    nameUP = _actionName;
                case "left":
                    nameLEFT = _actionName;
                case "right":
                    nameRIGHT = _actionName;
                case "down":
                    nameDOWN = _actionName;
            }
            
            
            b.gamePad.setStickActions(action.controller.name, nameUP, nameRIGHT, nameDOWN, nameLEFT);
        }
    }
    
    private function onTimerComplete(te : TimerEvent) : Void {
		stopCurrentTimer();
      
        destroy();
    }
	
	function stopCurrentTimer() {
		if (_timer != null) {
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			_updateEnabled = false;
		}
	}
    
    
    override public function destroy() : Void {
        if (_gamePad != null)
        {
            _gamePad.triggerActivity = false;
            _gamePad = null;
        }
        
        if (_gamePadManager != null)
        {
            var i : Int = 0;
            while (i < _gamePadManager.numGamePads){
                gp = _gamePadManager.getGamePadAt(i);
                gp.triggerActivity = false;
                i++;
            }
        }
        
        _input.stopRouting();
        _input.resetActions();
        _gamePadManager = null;
		
		stopCurrentTimer();
		
        super.destroy();
        
        onDone.dispatch(_success);
        onDone.removeAll();
    }
}



