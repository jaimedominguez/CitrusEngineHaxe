package citrus.input.controllers.gamepad.maps;


import citrus.input.controllers.gamepad.controls.ButtonController;
import citrus.input.controllers.gamepad.controls.StickController;
import citrus.input.controllers.gamepad.Gamepad;

class OUYAGamepadMap extends GamepadMap
{
    
    public function new()
    {
        super();
    }
    
    override public function setupAND() : Void {
        var joy : StickController;
        
        joy = _gamepad.registerStick(GamepadMap.STICK_LEFT, "AXIS_0", "AXIS_1");
        joy.threshold = 0.2;
 
        joy.threshold = 0.2;
        
        _gamepad.registerButton(GamepadMap.L1, "BUTTON_102");
        _gamepad.registerButton(GamepadMap.R1, "BUTTON_103");
        
        _gamepad.registerButton(GamepadMap.L2, "AXIS_17");
        _gamepad.registerButton(GamepadMap.R2, "AXIS_18");
        
        _gamepad.registerButton(GamepadMap.L3, "BUTTON_106");
        _gamepad.registerButton(GamepadMap.R3, "BUTTON_107");
        _gamepad.registerButton(GamepadMap.START, "BUTTON_109", "pause");
        
        
        //RAZER NO TIENE DPAD CON BOTONES. SON KEYS
        _gamepad.registerButton(GamepadMap.DPAD_UP, "BUTTON_19", "up");
        _gamepad.registerButton(GamepadMap.DPAD_DOWN, "BUTTON_20", "down");
        _gamepad.registerButton(GamepadMap.DPAD_RIGHT, "BUTTON_22", "right");
        _gamepad.registerButton(GamepadMap.DPAD_LEFT, "BUTTON_21", "left");
      
        _gamepad.registerButton(GamepadMap.BUTTON_BOTTOM, "BUTTON_96");  // O  
        _gamepad.registerButton(GamepadMap.BUTTON_LEFT, "BUTTON_99");  //   U  
        _gamepad.registerButton(GamepadMap.BUTTON_TOP, "BUTTON_100");  //   Y  
        _gamepad.registerButton(GamepadMap.BUTTON_RIGHT, "BUTTON_97");
    }
    
    override public function setupLNX() : Void {
        setupAND();
    }
    
    override public function setupWIN() : Void {
        setupAND();
    }
    
    override public function setupMAC() : Void {
        setupAND();
    }
}

