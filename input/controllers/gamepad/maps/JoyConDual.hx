package citrus.input.controllers.gamepad.maps;

import waifu.Main;
import citrus.core.CitrusEngine;
import kaleidoEngine.core.EngineVars;

import kaleidoEngine.screen.MainBasic;


import citrus.input.controllers.gamepad.Gamepad;
import citrus.input.controllers.gamepad.controls.StickController;
import flash.system.Capabilities;

class JoyConDual extends GamepadMap
{

    public function new()
    {
        super();
    }
    
    override public function setupMAC() : Void {
        setupWIN();
    }
    
    override public function setupLNX() : Void {
        setupWIN();
    }
    
    override public function setupWIN() : Void {
		 
		//  trace("SETUP GAMEPADMAP()");
		  
        var stick : StickController;
        
        stick = _gamepad.registerStick(GamepadMap.STICK_LEFT, "AXIS_0", "AXIS_1");
       // stick.invertY = true;  // AXIS_1 is inverted  
        stick.threshold = 0.2;
        
        stick = _gamepad.registerStick(GamepadMap.STICK_RIGHT, "AXIS_2", "AXIS_3");
        stick.invertY = true;  // AXIS_3 is inverted  
        stick.threshold = 0.2;
        
        _gamepad.registerButton(GamepadMap.L1, "BUTTON_9");
        _gamepad.registerButton(GamepadMap.R1, "BUTTON_10"); 
        
       _gamepad.registerButton(GamepadMap.L2, "BUTTON_16");
        _gamepad.registerButton(GamepadMap.R2, "BUTTON_15");
        
        _gamepad.registerButton(GamepadMap.L3, "BUTTON_7");
        _gamepad.registerButton(GamepadMap.R3, "BUTTON_8");//STICK PAD CENTER
        
       // _gamepad.registerButton(GamepadMap.SELECT, "BUTTON_4");
       // _gamepad.registerButton(GamepadMap.HOME, "BUTTON_5");
     //   _gamepad.registerButton(GamepadMap.START, "BUTTON_6");
        
        _gamepad.registerButton(GamepadMap.DPAD_UP, "BUTTON_11", "up");
        _gamepad.registerButton(GamepadMap.DPAD_DOWN, "BUTTON_12", "down");

		_gamepad.registerButton(GamepadMap.DPAD_RIGHT, "BUTTON_14", "right");
		_gamepad.registerButton(GamepadMap.DPAD_LEFT, "BUTTON_13", "left");
		
		
			
		//NOT WORKING
		/*_gamepad.registerButton(GamepadMap.L2, "BUTTON_4");
		_gamepad.registerButton(GamepadMap.R1, "BUTTON_5");
	    _gamepad.registerButton(GamepadMap.R2, "BUTTON_8");
        _gamepad.registerButton(GamepadMap.R3, "BUTTON_11");*/
		//--------------
       
        
        _gamepad.registerButton(GamepadMap.START, "BUTTON_6");//PLUS
        _gamepad.registerButton(GamepadMap.SELECT, "BUTTON_4");//MINUS
		//_gamepad.registerButton(GamepadMap.SELECT, "BUTTON_7");//CENTRAL JOYPAD BUTTON!!!
        
        /*
        _gamepad.registerButton(GamepadMap.BUTTON_LEFT, "BUTTON_3");
		_gamepad.registerButton(GamepadMap.BUTTON_TOP, "BUTTON_1");
		
        _gamepad.registerButton(GamepadMap.BUTTON_RIGHT, "BUTTON_0");
      	_gamepad.registerButton(GamepadMap.BUTTON_BOTTOM, "BUTTON_2");
		*/
		
	   _gamepad.registerButton(GamepadMap.BUTTON_TOP, "BUTTON_3");
        _gamepad.registerButton(GamepadMap.BUTTON_RIGHT, "BUTTON_1");
        _gamepad.registerButton(GamepadMap.BUTTON_BOTTOM, "BUTTON_0");
        _gamepad.registerButton(GamepadMap.BUTTON_LEFT, "BUTTON_2");
		
		

		
		_gamepad.fillUnbindedMap();
		
		
    }
    
	
	
	
}

