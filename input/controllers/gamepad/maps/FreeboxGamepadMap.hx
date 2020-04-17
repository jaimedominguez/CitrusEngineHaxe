package citrus.input.controllers.gamepad.maps;

import citrus.input.controllers.gamepad.Gamepad;

/**
	 * This is the Freebox _gamepad controller preset
	 * It will work only in analog mode though (axes are weird when its not)
	 * http://www.lowcostmobile.com/img/operateurs/free/_gamepad_free.jpg
	 */
class FreeboxGamepadMap extends GamepadMap
{
    public function new()
    {
        super();
    }
    
    override public function setupWIN() : Void {
        _gamepad.registerStick(GamepadMap.STICK_LEFT, "AXIS_1", "AXIS_0");
        _gamepad.registerStick(GamepadMap.STICK_RIGHT, "AXIS_4", "AXIS_2");
        
        _gamepad.registerButton(GamepadMap.L1, "BUTTON_13");
        _gamepad.registerButton(GamepadMap.R1, "BUTTON_14");
        
        _gamepad.registerButton(GamepadMap.L2, "BUTTON_15");
        _gamepad.registerButton(GamepadMap.R2, "BUTTON_16");
        
        _gamepad.registerButton(GamepadMap.L3, "BUTTON_19");
        _gamepad.registerButton(GamepadMap.R3, "BUTTON_20");
        
        _gamepad.registerButton(GamepadMap.SELECT, "BUTTON_17");
        _gamepad.registerButton(GamepadMap.START, "BUTTON_18");
        
        _gamepad.registerButton(GamepadMap.DPAD_UP, "BUTTON_5", "up");
        _gamepad.registerButton(GamepadMap.DPAD_DOWN, "BUTTON_6", "down");
        _gamepad.registerButton(GamepadMap.DPAD_RIGHT, "BUTTON_8", "right");
        _gamepad.registerButton(GamepadMap.DPAD_LEFT, "BUTTON_7", "left");
        
        _gamepad.registerButton(GamepadMap.BUTTON_TOP, "BUTTON_9");
        _gamepad.registerButton(GamepadMap.BUTTON_RIGHT, "BUTTON_10");
        _gamepad.registerButton(GamepadMap.BUTTON_BOTTOM, "BUTTON_11");
        _gamepad.registerButton(GamepadMap.BUTTON_LEFT, "BUTTON_12");
    }
}

