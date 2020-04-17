package citrus.input.controllers;

import citrus.input.InputController;
import citrus.input.controllers.keyboard.KeyController;
import kaleidoEngine.debug.InArray;
import kaleidoEngine.debug.InObject;
import openfl.utils.Object;
//import hx.event.Signal;
import msignal.Signal;
//import org.osflash.signals.Signal;
//import org.osflash.signals.Signal;

import flash.events.KeyboardEvent;
import flash.utils.Dictionary;

/**
	 *  The default Keyboard controller.
	 * 	A single key can trigger multiple actions, each of these can be sent to different channels.
	 *
	 *  Keyboard holds static keycodes constants (see bottom).
	 */
class Keyboard extends InputController
{
    private var _keyActions : Dictionary<Int,Array<KeyController>>;
    
    /**
		 * on native keyboard key up, dispatches keyCode and keyLocation as well as a 'vars' object which you can use to prevent default or stop immediate propagation of the native event.
		 * see the code below :
		 * 
		 * <code>
		 * public function onSoftKeys(keyCode:int,keyLocation:int,vars:Object):void
		 *	{
		 *		switch (keyCode)
		 *		{ 
		 *			case Keyboard.BACK: 
		 *				vars.prevent = true;
		 *	 			trace("back button, default prevented.");
		 *				break; 
		 *			case Keyboard.MENU: 
		 *				trace("menu");
		 *				break; 
		 *			case Keyboard.SEARCH: 
		 *				trace("search");
		 *				break; 
		 * 			case Keyboard.ENTER:
		 * 				vars.stop = true;
		 *				trace("enter, will not go through the input system because propagation was stopped.");
		 *				break; 
		 *		}
		 *	}
		 * </code>
		 */
    public var onKeyUp : Signal3<Int, Int, Dynamic>;
    
    /**
		 * on native keyboard key down, dispatches keyCode and keyLocation as well as a 'vars' object which you can use to prevent default or stop immediate propagation of the native event.
		 * see the code below :
		 * 
		 * <code>
		 * public function onSoftKeys(keyCode:int,keyLocation:int,vars:Object):void
		 *	{
		 *		switch (keyCode)
		 *		{ 
		 *			case Keyboard.BACK: 
		 *				vars.prevent = true;
		 *	 			trace("back button, default prevented.");
		 *				break; 
		 *			case Keyboard.MENU: 
		 *				trace("menu");
		 *				break; 
		 *			case Keyboard.SEARCH: 
		 *				trace("search");
		 *				break; 
		 * 			case Keyboard.ENTER:
		 * 				vars.stop = true;
		 *				trace("enter, will not go through the input system because propagation was stopped.");
		 *				break; 
		 *		}
		 *	}
		 * </code>
		 */
    public var onKeyDown : Signal3<Int, Int, Dynamic>;
    
    public function new(name : String, params : Dynamic = null)
    {
        super(name, params);
        
        _keyActions = new Dictionary<Int,Array<KeyController>>();

        _ce.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
        _ce.stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
      
        onKeyUp = new Signal3(Int, Int, Dynamic);
        onKeyDown = new Signal3(Int, Int, Dynamic);
    }
    
    private function handleKeyDown(e : KeyboardEvent) : Void {
        if (onKeyDown.numListeners > 0)
        {
            var vars : Dynamic = {
                prevent : false,
                stop : false
            };
            onKeyDown.dispatch(e.keyCode, e.keyLocation, vars);
            if (vars.prevent){
                e.preventDefault();
            }
            if (vars.stop){
                e.stopImmediatePropagation();
                return;
            }
        }
    
		
		var thisAction:KeyController;
		
		if (_keyActions[e.keyCode] != null)
        {
			var actions : Array<KeyController> = _keyActions[e.keyCode];
             for (i in 0...actions.length){
				thisAction = actions[i];
                triggerON(thisAction.name, 1, null, ((thisAction.channel < 0)) ? defaultChannel : thisAction.channel);
            }
        }
    }
    
    private function handleKeyUp(e : KeyboardEvent) : Void {
        if (onKeyUp.numListeners > 0)
        {
            var vars : Dynamic = {
                prevent : false,
                stop : false
            };
            onKeyUp.dispatch(e.keyCode, e.keyLocation, vars);
            if (vars.prevent){
                e.preventDefault();
            }
            if (vars.stop){
                e.stopImmediatePropagation();
                return;
            }
        }
        
      
		if (_keyActions[e.keyCode] != null)    {
			var actions : Array<KeyController> = _keyActions[e.keyCode];
			var thisAction:KeyController;
           for (i in 0...actions.length){
				thisAction = actions[i];
				triggerOFF(thisAction.name, 0, null, ((thisAction.channel < 0)) ? defaultChannel : thisAction.channel);
            }
        }
	
		
    }
    
    /**
		 * Add an action to a Key if action doesn't exist on that Key.
		 */
    public function addKeyAction(actionName : String, keyCode : Int, channel : Int = -1) : Void {
		
		//trace("_keyActions[" + keyCode+"]=" + actionName);
        if (_keyActions[keyCode] == null)
        {
            _keyActions[keyCode] = new Array<KeyController>();
        }
        else
        {
       
			var actions : Array<KeyController> = _keyActions[keyCode];
			var thisAction:KeyController;
            for (i in 0...actions.length){
				thisAction = actions[i];
                if (thisAction.name == actionName && thisAction.channel == channel) {
					return;	
				}
			}
        }
        
		var keyController:KeyController = new KeyController(actionName,channel);
		//push key into array
		
		_keyActions[keyCode].push(keyController);
		
		
		
    }
	
	
	
	 public function viewAllKeyActions() : Void {
      
		for (keyCode in _keyActions) {
			
			var actions : Array<KeyController> = _keyActions[keyCode];
			var thisAction:KeyController;
            for (i in 0...actions.length){
				thisAction = actions[i];
               // trace("KEY:" + keyCode + " ACTIONS:" + thisAction.name);
			}
        }
       
		
    }
    
    
    /**
		 * Removes action from a key code, by name.
		 */
    public function removeActionFromKey(actionName : String, keyCode : Int) : Void {
        if (_keyActions[keyCode] != null)
        {
            var actions : Array<KeyController> = _keyActions[keyCode];
			var thisAction:KeyController;
            for (i in 0...actions.length){
				thisAction = actions[i];
                if (thisAction.name == actionName)
                {
                    triggerOFF(actionName);
                    actions.splice(i, 1);
                    return;
                }
            }
        }

    }
    
    /**
		 * Removes every actions by name, on every keys.
		 */
    public function removeAction(actionName : String) : Void {
		//trace("removeAction:" + actionName);
		for (keysID in _keyActions)
        {
			if (_keyActions[keysID]==null){
				
			}else {
			
				var actions : Array<KeyController> = _keyActions[keysID];
				var thisAction:KeyController;
				var i:Int = actions.length-1;
				while (i >= 0) {
					thisAction = actions[i];
					if (thisAction != null) {
					//	trace("ACTION["+ thisAction.name+" FOUND...");
						if (thisAction.name == actionName)
						{
						//	trace("ACTION ERASE FROM KEY:"+i);
							triggerOFF(actionName);
							actions.splice(i, 1);
							//return;
						}
					}
					i--;
				}
			}
		}
    }
    
    /**
		 * Deletes the entire registry of key actions.
		 */
    public function resetAllKeyActions() : Void {
        _keyActions = new Dictionary<Int,Array<KeyController>>();
        _ce.input.stopActionsOf(this);
    }
    
    /**
		 * Helps swap actions from a key to another key.
		 */
    public function changeKeyAction(previousKey : Int, newKey : Int) : Void {
        var actions : Array<KeyController> = getActionsByKey(previousKey);
        setKeyActions(newKey, actions);
        removeKeyActions(previousKey);
    }
    
    /**
		 * Sets all actions on a key
		 */
    private function setKeyActions(keyCode : Int, actions : Array<KeyController>) : Void {
        if (_keyActions[keyCode] == null)
        {
            _keyActions[keyCode] = actions;
        }
        _ce.input.stopActionsOf(this);
    }
    
    /**
		 * Removes all actions on a key.
		 */
    public function removeKeyActions(keyCode : Int) : Void {
        _keyActions[keyCode] = null;
        _ce.input.stopActionsOf(this);
    }
    
    /**
		 * Returns all actions on a key in Vector format or returns null if none.
		 */
    public function getActionsByKey(keyCode : Int) : Array<KeyController>
    {
        if (_keyActions[keyCode] != null)
        {
            return _keyActions[keyCode];
        }
        else
        {
            return null;
        }
    }
    
    public function getKeyIDFromAction(actionName : String, inputChannel : Int, filterASCII : Bool = true, shortASCII : Bool = true) : String
    {
		//trace("getKeyIDFromAction(" + actionName+")");
        for (key in _keyActions)
        {
			var actions : Array<KeyController> = _keyActions[key];
			var thisAction:KeyController;
			
			
			for (i in 0...actions.length){
				thisAction = actions[i];
				//trace("thisAction?(" + thisAction.name+")");
                if ((thisAction.name == actionName && -1 == inputChannel) || (thisAction.name == actionName && thisAction.channel == inputChannel))
				{
				//	trace("thisAction!!:"+key);
                    if (filterASCII)
                    {
                        return filterASCIIToKey(key, shortASCII);
                    }
                    else
                    {
                        return Std.string(key);
                    }
                }
            }
        }
        
        return "N/A";
    } 
	
    public function filterASCIIToKey(key : Int, short : Bool = false) : String
    {
		
	//	trace("filterASCIIToKey:" + key);
		
        var nameID : String = "";
        switch (key)
        {
            case 8:
                nameID = "BCKSP";
            case 9:
                nameID = "TAB";
            case 13:
                nameID = "ENTER";
            case 15:
                nameID = "CMD";
            case 16:
                nameID = "SHIFT";
                if (short)
                {
                    nameID = "SHF";
                }
            case 17:
                nameID = "CTRL";
                if (short)
                {
                    nameID = "CTR";
                }
            case 18:
                nameID = "ALT";
            case 19:
                nameID = "BREAK";
                if (short)
                {
                    nameID = "BRK";
                }
            case 20:
                nameID = "CAPS";
                if (short)
                {
                    nameID = "CAP";
                }
            case 27:
                nameID = "ESC";
            case 32:
                nameID = "SPACE";
                if (short)
                {
                    nameID = "SPC";
                }
            case 33:
                nameID = "PGUP";
                if (short)
                {
                    nameID = "PUP";
                }
            case 34:
                nameID = "PGDN";
                if (short)
                {
                    nameID = "PDN";
                }
            case 35:
                nameID = "END";
            case 36:
                nameID = "HOME";
                if (short)
                {
                    nameID = "HM";
                }
            case 37:
                nameID = "LEFT";
                if (short)
                {
                    nameID = "LE";
                }
            case 38:
                nameID = "UP";
            case 39:
                nameID = "RIGHT";
                if (short)
                {
                    nameID = "RI";
                }
            case 40:
                nameID = "DOWN";
                if (short)
                {
                    nameID = "DO";
                }
            case 45:
                nameID = "INSR";
                if (short)
                {
                    nameID = "INS";
                }
            case 46:
                nameID = "DEL";
            case 144:
                nameID = "NUMLK";
            case 145:
                nameID = "SCRLK";
            case 96:
                nameID = "NPAD0";
            case 97:
                nameID = "NPAD1";
            case 98:
                nameID = "NPAD2";
            case 99:
                nameID = "NPAD3";
            case 100:
                nameID = "NPAD4";
            case 101:
                nameID = "NPAD5";
            case 102:
                nameID = "NPAD6";
            case 103:
                nameID = "NPAD7";
            case 104:
                nameID = "NPAD8";
            case 105:
                nameID = "NPAD9";
            case 106:
                nameID = "NPAD*";
            case 107:
                nameID = "NPAD+";
            case 109:
                nameID = "NPAD-";
            case 110:
                nameID = "NPAD.";
            case 111:
                nameID = "NPAD/";
            case 112:
                nameID = "F1";
            case 113:
                nameID = "F2";
            case 114:
                nameID = "F3";
            case 115:
                nameID = "F4";
            case 116:
                nameID = "F5";
            case 117:
                nameID = "F6";
            case 118:
                nameID = "F7";
            case 119:
                nameID = "F8";
            case 120:
                nameID = "F9";
            case 121:
                nameID = "F10";
            case 122:
                nameID = "F11";
            case 123:
                nameID = "F12";
            case 124:
                nameID = "F13";
            case 125:
                nameID = "F14";
            case 126:
                nameID = "F15";
            case 192:
                nameID = "QUOT2";
            case 222:
                nameID = "QUOTE";
            
            case 186:
                nameID = "SEMIC";
                nameID = ";";
            
            case 187:
                nameID = "EQUAL";
                nameID = "=";
            
            case 188:
                nameID = "COMMA";
                nameID = ",";
            
            case 189:
                nameID = "MINUS";
                nameID = "-";
            
            case 190:
                nameID = "PERIOD";
                nameID = ".";
            
            case 219:
                nameID = "[";
            case 221:
                nameID = "]";
            
            case 220:
                nameID = "\\";
            
            case 191:
                nameID = "/";
            default:
                nameID = String.fromCharCode(key);
        }

        return nameID;
    }
    
    
    override public function destroy() : Void {
        onKeyUp.removeAll();
        onKeyDown.removeAll();
        
        _ce.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
        _ce.stage.removeEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
        
        _keyActions = null;
        
        super.destroy();
    }
    
    /*
		 *  KEYCODES
		 *  they refer to the character written on a key (the first bottom left one if there are many).
		 *  based on commonly used QWERTY keyboard.
		 *
		 *  some regular AZERTY special chars based on a French AZERTY Layout are added for
		 *  your convenience (so you can refer to them if you have a similar layout) :
		 *  ²)=^$ù*!
		 */
    
    public static inline var NUMBER_0 : Int = 48;
    public static inline var NUMBER_1 : Int = 49;
    public static inline var NUMBER_2 : Int = 50;
    public static inline var NUMBER_3 : Int = 51;
    public static inline var NUMBER_4 : Int = 52;
    public static inline var NUMBER_5 : Int = 53;
    public static inline var NUMBER_6 : Int = 54;
    public static inline var NUMBER_7 : Int = 55;
    public static inline var NUMBER_8 : Int = 56;
    public static inline var NUMBER_9 : Int = 57;
    
    public static inline var A : Int = 65;
    public static inline var B : Int = 66;
    public static inline var C : Int = 67;
    public static inline var D : Int = 68;
    public static inline var E : Int = 69;
    public static inline var F : Int = 70;
    public static inline var G : Int = 71;
    public static inline var H : Int = 72;
    public static inline var I : Int = 73;
    public static inline var J : Int = 74;
    public static inline var K : Int = 75;
    public static inline var L : Int = 76;
    public static inline var M : Int = 77;
    public static inline var N : Int = 78;
    public static inline var O : Int = 79;
    public static inline var P : Int = 80;
    public static inline var Q : Int = 81;
    public static inline var R : Int = 82;
    public static inline var S : Int = 83;
    public static inline var T : Int = 84;
    public static inline var U : Int = 85;
    public static inline var V : Int = 86;
    public static inline var W : Int = 87;
    public static inline var X : Int = 88;
    public static inline var Y : Int = 89;
    public static inline var Z : Int = 90;
    
    
    
    
    public static inline var BACKSPACE : Int = 8;
    public static inline var TAB : Int = 9;
    public static inline var ENTER : Int = 13;
    public static inline var SHIFT : Int = 16;
    public static inline var CTRL : Int = 17;
    public static inline var CAPS_LOCK : Int = 20;
    public static inline var ESCAPE : Int = 27;
    public static inline var SPACE : Int = 32;
    
    public static inline var PAGE_UP : Int = 33;
    public static inline var PAGE_DOWN : Int = 34;
    public static inline var END : Int = 36;
    public static inline var HOME : Int = 35;
    
    public static inline var LEFT : Int = 37;
    public static inline var UP : Int = 38;
    public static inline var RIGHT : Int = 39;
    public static inline var DOWN : Int = 40;
    
    public static inline var INSERT : Int = 45;
    public static inline var DELETE : Int = 46;
    public static inline var BREAK : Int = 19;
    public static inline var NUM_LOCK : Int = 144;
    public static inline var SCROLL_LOCK : Int = 145;
    
    public static inline var NUMPAD_0 : Int = 96;
    public static inline var NUMPAD_1 : Int = 97;
    public static inline var NUMPAD_2 : Int = 98;
    public static inline var NUMPAD_3 : Int = 99;
    public static inline var NUMPAD_4 : Int = 100;
    public static inline var NUMPAD_5 : Int = 101;
    public static inline var NUMPAD_6 : Int = 102;
    public static inline var NUMPAD_7 : Int = 103;
    public static inline var NUMPAD_8 : Int = 104;
    public static inline var NUMPAD_9 : Int = 105;
    
    public static inline var NUMPAD_MULTIPLY : Int = 105;
    public static inline var NUMPAD_ADD : Int = 107;
    public static inline var NUMPAD_ENTER : Int = 13;
    public static inline var NUMPAD_SUBTRACT : Int = 109;
    public static inline var NUMPAD_DECIMAL : Int = 110;
    public static inline var NUMPAD_DIVIDE : Int = 111;
    
    public static inline var F1 : Int = 112;
    public static inline var F2 : Int = 113;
    public static inline var F3 : Int = 114;
    public static inline var F4 : Int = 115;
    public static inline var F5 : Int = 116;
    public static inline var F6 : Int = 117;
    public static inline var F7 : Int = 118;
    public static inline var F8 : Int = 119;
    public static inline var F9 : Int = 120;
    public static inline var F10 : Int = 121;
    public static inline var F11 : Int = 122;
    public static inline var F12 : Int = 123;
    public static inline var F13 : Int = 124;
    public static inline var F14 : Int = 125;
    public static inline var F15 : Int = 126;
    
    public static inline var COMMAND : Int = 15;
    public static inline var ALTERNATE : Int = 18;
    
    public static inline var BACKQUOTE : Int = 192;
    public static inline var QUOTE : Int = 222;
    public static inline var COMMA : Int = 188;
    public static inline var PERIOD : Int = 190;
    public static inline var SEMICOLON : Int = 186;
    public static inline var BACKSLASH : Int = 220;
    public static inline var SLASH : Int = 191;
    
    public static inline var EQUAL : Int = 187;
    public static inline var MINUS : Int = 189;
    
    public static inline var LEFT_BRACKET : Int = 219;
    public static inline var RIGHT_BRACKET : Int = 221;
    
    public static inline var AUDIO : Int = 0x01000017;
    public static inline var BACK : Int = 0x01000016;
    public static inline var MENU : Int = 0x01000012;
    public static inline var SEARCH : Int = 0x0100001F;
    
    //HELPER FOR AZERTY ----------------------------------
    public static inline var SQUARE : Int = 222;  // ²  
    public static inline var RIGHT_PARENTHESIS : Int = 219;
    public static inline var CIRCUMFLEX : Int = 221;  // ^  
    public static inline var DOLLAR_SIGN : Int = 186;  // $  
    public static inline var U_GRAVE : Int = 192;  // ù  
    public static inline var MULTIPLY : Int = 220;  // *  
    public static inline var EXCLAMATION_MARK : Int = 223;  // !  
}

