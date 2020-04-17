package citrus.input.controllers.gamepad.maps;

import citrus.input.controllers.gamepad.controls.ButtonController;
import citrus.input.controllers.gamepad.controls.StickController;
import citrus.input.controllers.gamepad.Gamepad;
//import citrus.input.controllers.gamepad.maps.GamePadMap.GamepadMap;

class JoyConRight extends GamepadMap
{
	public static var TEMP_N:Int = 10;
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
        var stick : StickController;
        
        stick = _gamepad.registerStick(GamepadMap.STICK_LEFT, "AXIS_1", "AXIS_0");
        stick.invertX = true;  // AXIS_1 is inverted  
        stick.threshold = 0.2;

		_gamepad.registerButton(GamepadMap.R1, "BUTTON_10");//BUTTON "R";
		_gamepad.registerButton(GamepadMap.R3, "BUTTON_9");//BUTTON "SR";
		
		
		//NOT WORKING
		/*_gamepad.registerButton(GamepadMap.L2, "BUTTON_4");
		_gamepad.registerButton(GamepadMap.R1, "BUTTON_5");
	    _gamepad.registerButton(GamepadMap.R2, "BUTTON_8");
        _gamepad.registerButton(GamepadMap.R3, "BUTTON_11");*/
		//--------------
        
        _gamepad.registerButton(GamepadMap.START, "BUTTON_6");
       // _gamepad.registerButton(GamepadMap.SELECT, "BUTTON_7");//is JOYPAD BUTTON

        _gamepad.registerButton(GamepadMap.BUTTON_LEFT, "BUTTON_0");
        _gamepad.registerButton(GamepadMap.BUTTON_TOP, "BUTTON_2");
		_gamepad.registerButton(GamepadMap.BUTTON_BOTTOM, "BUTTON_1");
	    _gamepad.registerButton(GamepadMap.BUTTON_RIGHT, "BUTTON_3");
	   
	   
        
		_gamepad.fillUnbindedMap();
		
		
		//sr = 9
		//sl = 8;
		//plus = 7
		//minus = 4
		//zr = 5
		
		
		
    }
  
}

