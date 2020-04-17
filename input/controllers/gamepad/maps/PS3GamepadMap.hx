package citrus.input.controllers.gamepad.maps;

import citrus.input.controllers.gamepad.controls.StickController;
import citrus.input.controllers.gamepad.Gamepad;

class PS3GamepadMap extends GamepadMap
{
    
    public function new()
    {
        super();
    }
    
    override public function setupMAC() : Void {
        var joy : StickController;
        
        joy = _gamepad.registerStick(GamepadMap.STICK_LEFT, "AXIS_0", "AXIS_1");
        joy.invertY = true;
        joy.threshold = 0.2;
        
        joy = _gamepad.registerStick(GamepadMap.STICK_RIGHT, "AXIS_2", "AXIS_3");
        joy.invertY = true;
        joy.threshold = 0.2;
        
        _gamepad.registerButton(GamepadMap.L1, "BUTTON_14");
        _gamepad.registerButton(GamepadMap.R1, "BUTTON_15");
        
        _gamepad.registerButton(GamepadMap.L2, "BUTTON_12");
        _gamepad.registerButton(GamepadMap.R2, "BUTTON_13");
        
        
        _gamepad.registerButton(GamepadMap.SELECT, "BUTTON_4");
        _gamepad.registerButton(GamepadMap.START, "BUTTON_7");
        
        _gamepad.registerButton(GamepadMap.L3, "BUTTON_5");
        _gamepad.registerButton(GamepadMap.R3, "BUTTON_6");
        
        _gamepad.registerButton(GamepadMap.DPAD_UP, "BUTTON_8", "up");
        _gamepad.registerButton(GamepadMap.DPAD_DOWN, "BUTTON_10", "down");
        _gamepad.registerButton(GamepadMap.DPAD_RIGHT, "BUTTON_9", "right");
        _gamepad.registerButton(GamepadMap.DPAD_LEFT, "BUTTON_11", "left");
        
        _gamepad.registerButton(GamepadMap.BUTTON_BOTTOM, "BUTTON_18");  // X  
        _gamepad.registerButton(GamepadMap.BUTTON_LEFT, "BUTTON_19");  //   square  
        _gamepad.registerButton(GamepadMap.BUTTON_TOP, "BUTTON_16");  //   triangle  
        _gamepad.registerButton(GamepadMap.BUTTON_RIGHT, "BUTTON_17");
    }
    
    override public function setupAND() : Void {
        var joy : StickController;
        
        joy = _gamepad.registerStick(GamepadMap.STICK_LEFT, "AXIS_0", "AXIS_1");
        joy.threshold = 0.2;
        
        joy = _gamepad.registerStick(GamepadMap.STICK_RIGHT, "AXIS_11", "AXIS_14");
        joy.threshold = 0.2;
        
        _gamepad.registerButton(GamepadMap.L1, "BUTTON_102");
        _gamepad.registerButton(GamepadMap.R1, "BUTTON_103");
        
        _gamepad.registerButton(GamepadMap.L2, "BUTTON_104");
        _gamepad.registerButton(GamepadMap.R2, "BUTTON_105");
        
        _gamepad.registerButton(GamepadMap.START, "BUTTON_108");
        
        _gamepad.registerButton(GamepadMap.L3, "BUTTON_106");
        _gamepad.registerButton(GamepadMap.R3, "BUTTON_107");
        
        _gamepad.registerButton(GamepadMap.DPAD_UP, "AXIS_36", "up");
        _gamepad.registerButton(GamepadMap.DPAD_DOWN, "AXIS_38", "down");
        _gamepad.registerButton(GamepadMap.DPAD_RIGHT, "AXIS_37", "right");
        _gamepad.registerButton(GamepadMap.DPAD_LEFT, "AXIS_39", "left");
        
        _gamepad.registerButton(GamepadMap.BUTTON_BOTTOM, "BUTTON_96");  // X  
        _gamepad.registerButton(GamepadMap.BUTTON_LEFT, "BUTTON_99");  //   square  
        _gamepad.registerButton(GamepadMap.BUTTON_TOP, "BUTTON_100");  //   triangle  
        _gamepad.registerButton(GamepadMap.BUTTON_RIGHT, "BUTTON_97");
    }
    
    override public function setupWIN() : Void {
        setupAND();
    }
    
    override public function setupLNX() : Void {
        setupAND();
    }
}

