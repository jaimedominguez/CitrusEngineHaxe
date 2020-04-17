package citrus.input.controllers.gamepad.maps;

import waifu.Main;
import citrus.core.CitrusEngine;
import kaleidoEngine.core.EngineVars;

import kaleidoEngine.screen.MainBasic;


import citrus.input.controllers.gamepad.Gamepad;
import citrus.input.controllers.gamepad.controls.StickController;
import flash.system.Capabilities;

class GamepadMap
{
    public static var devPlatform(never, set) : String;

    private static var _platform : String;
    private var _gamepad : Gamepad;
    public var canBeRebinded : Bool = true;
    
    public function new()
    {
//		trace("CHECK PLATFORM");
		//_platform = "WIN";
       /* if (_platform == null)
        {
            _platform = Capabilities.version.slice(0, 3);
        }*/
    }
    
    public function setup(gamepad : Gamepad) : Void {
        _gamepad = gamepad;
        _gamepad.stopAllActions();
        _gamepad.currentMap = this;
		
		setupWIN();
       
    }
    
    /**
		 * force GamePadMap to use a certain platform when running : WIN,MAC,LNX,AND
		 */
    private static function set_devPlatform(value : String) : String
    {
        _platform = value;
        return value;
    }
    
    /**
		 * override those functions to set up a gamepad for different OS's by default,
		 * or override setup() to define your own way.
		 */
   /* public function setupWIN() : Void {
    }*/
    public function setupMAC() : Void {
    }
    public function setupLNX() : Void {
    }
    public function setupAND() : Void {
    }
    
    public static inline var L1 : String = "L1";
    public static inline var R1 : String = "R1";
    
    public static inline var L2 : String = "L2";
    public static inline var R2 : String = "R2";
    
    public static inline var STICK_LEFT : String = "STICK_LEFT";
    public static inline var STICK_RIGHT : String = "STICK_RIGHT";
    /**
		 * Joystick buttons.
		 */
    public static inline var L3 : String = "L3";
    public static inline var R3 : String = "R3";
    
    public static inline var SELECT : String = "SELECT";
    public static inline var START : String = "START";
    
    public static inline var HOME : String = "HOME";
    
    /**
		 * directional button on the left of the game pad.
		 */
    public static inline var DPAD_UP : String = "DPAD_UP";
    public static inline var DPAD_RIGHT : String = "DPAD_RIGHT";
    public static inline var DPAD_DOWN : String = "DPAD_DOWN";
    public static inline var DPAD_LEFT : String = "DPAD_LEFT";
    
    /**
		 * buttons on the right, conventionally 4 arranged as a rhombus ,
		 * example, playstation controllers , with in the same order as below : triangle, square, cross, circle
		 */
    public static inline var BUTTON_TOP : String = "BUTTON_TOP";
    public static inline var BUTTON_RIGHT : String = "BUTTON_RIGHT";
    public static inline var BUTTON_BOTTOM : String = "BUTTON_BOTTOM";
    public static inline var BUTTON_LEFT : String = "BUTTON_LEFT";
	
	 public function setupWIN() : Void {
		 
		//trace("SETUP GAMEPADMAP()");
		  
        var stick : StickController;
        
        stick = _gamepad.registerStick(GamepadMap.STICK_LEFT, "AXIS_0", "AXIS_1");
       // stick.invertY = true;  // AXIS_1 is inverted  
        stick.threshold = 0.2;
        
        stick = _gamepad.registerStick(GamepadMap.STICK_RIGHT, "AXIS_2", "AXIS_3");
        stick.invertY = true;  // AXIS_3 is inverted  
        stick.threshold = 0.2;
        
        _gamepad.registerButton(GamepadMap.L1, "BUTTON_9");
        _gamepad.registerButton(GamepadMap.R1, "BUTTON_10"); 
        
       _gamepad.registerButton(GamepadMap.L2, "BUTTON_10");
       _gamepad.registerButton(GamepadMap.R2, "BUTTON_11");
        
        _gamepad.registerButton(GamepadMap.L3, "BUTTON_7");
        _gamepad.registerButton(GamepadMap.R3, "BUTTON_8");
        
        _gamepad.registerButton(GamepadMap.SELECT, "BUTTON_4");
        _gamepad.registerButton(GamepadMap.HOME, "BUTTON_5");
        _gamepad.registerButton(GamepadMap.START, "BUTTON_6");
        
        _gamepad.registerButton(GamepadMap.DPAD_UP, "BUTTON_11", "up");
        _gamepad.registerButton(GamepadMap.DPAD_DOWN, "BUTTON_12", "down");

		_gamepad.registerButton(GamepadMap.DPAD_RIGHT, "BUTTON_14", "right");
		_gamepad.registerButton(GamepadMap.DPAD_LEFT, "BUTTON_13", "left");
		
        _gamepad.registerButton(GamepadMap.BUTTON_TOP, "BUTTON_3");
        _gamepad.registerButton(GamepadMap.BUTTON_RIGHT, "BUTTON_1");
        _gamepad.registerButton(GamepadMap.BUTTON_BOTTOM, "BUTTON_0");
        _gamepad.registerButton(GamepadMap.BUTTON_LEFT, "BUTTON_2");
    }
    
	
	
	
}

