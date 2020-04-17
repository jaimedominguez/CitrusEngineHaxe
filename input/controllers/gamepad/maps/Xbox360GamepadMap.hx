package citrus.input.controllers.gamepad.maps;

import citrus.input.controllers.gamepad.controls.ButtonController;
import citrus.input.controllers.gamepad.controls.StickController;
import citrus.input.controllers.gamepad.Gamepad;

class Xbox360GamepadMap extends GamepadMap
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
        var stick : StickController;
        
        stick = _gamepad.registerStick(GamepadMap.STICK_LEFT, "AXIS_0", "AXIS_1");
       // stick.invertY = true;  // AXIS_1 is inverted  
        stick.threshold = 0.2;
        
        stick = _gamepad.registerStick(GamepadMap.STICK_RIGHT, "AXIS_2", "AXIS_3");
        stick.invertY = true;  // AXIS_3 is inverted  
        stick.threshold = 0.2;
        
        _gamepad.registerButton(GamepadMap.L1, "BUTTON_8");
        _gamepad.registerButton(GamepadMap.R1, "BUTTON_9");
        
        _gamepad.registerButton(GamepadMap.L2, "BUTTON_10");
        _gamepad.registerButton(GamepadMap.R2, "BUTTON_11");
        
        _gamepad.registerButton(GamepadMap.L3, "BUTTON_14");
        _gamepad.registerButton(GamepadMap.R3, "BUTTON_15");
        
        _gamepad.registerButton(GamepadMap.SELECT, "BUTTON_12");
        _gamepad.registerButton(GamepadMap.START, "BUTTON_13");
        
        _gamepad.registerButton(GamepadMap.DPAD_UP, "BUTTON_16", "up");
        _gamepad.registerButton(GamepadMap.DPAD_DOWN, "BUTTON_17", "down");
        _gamepad.registerButton(GamepadMap.DPAD_RIGHT, "BUTTON_19", "right");
        _gamepad.registerButton(GamepadMap.DPAD_LEFT, "BUTTON_18", "left");
        
        _gamepad.registerButton(GamepadMap.BUTTON_TOP, "BUTTON_2");
        _gamepad.registerButton(GamepadMap.BUTTON_RIGHT, "BUTTON_3");
        _gamepad.registerButton(GamepadMap.BUTTON_BOTTOM, "BUTTON_4");
        _gamepad.registerButton(GamepadMap.BUTTON_LEFT, "BUTTON_1");
    }
    
    override public function setupAND() : Void {
        var stick : StickController;
        var button : ButtonController;
        
        stick = _gamepad.registerStick(GamepadMap.STICK_LEFT, "AXIS_0", "AXIS_1");
        stick.threshold = 0.2;
        
        stick = _gamepad.registerStick(GamepadMap.STICK_RIGHT, "AXIS_11", "AXIS_14");
        stick.threshold = 0.2;
        
        _gamepad.registerButton(GamepadMap.L1, "BUTTON_102");
        _gamepad.registerButton(GamepadMap.R1, "BUTTON_103");
        
        _gamepad.registerButton(GamepadMap.L2, "AXIS_17");
        _gamepad.registerButton(GamepadMap.R2, "AXIS_18");
        
        _gamepad.registerButton(GamepadMap.L3, "BUTTON_106");
        _gamepad.registerButton(GamepadMap.R3, "BUTTON_107");
        
        _gamepad.registerButton(GamepadMap.START, "BUTTON_108");
        
        button = _gamepad.registerButton(GamepadMap.DPAD_UP, "AXIS_16", "up");
        button.inverted = true;
        
        _gamepad.registerButton(GamepadMap.DPAD_DOWN, "AXIS_16", "down");
        _gamepad.registerButton(GamepadMap.DPAD_RIGHT, "AXIS_15", "right");
        
        button = _gamepad.registerButton(GamepadMap.DPAD_LEFT, "AXIS_15", "left");
        button.inverted = true;
        
        _gamepad.registerButton(GamepadMap.BUTTON_TOP, "BUTTON_100");
        _gamepad.registerButton(GamepadMap.BUTTON_RIGHT, "BUTTON_97");
        _gamepad.registerButton(GamepadMap.BUTTON_BOTTOM, "BUTTON_96");
        _gamepad.registerButton(GamepadMap.BUTTON_LEFT, "BUTTON_99");
    }
}

