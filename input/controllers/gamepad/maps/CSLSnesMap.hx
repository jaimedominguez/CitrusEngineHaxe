package citrus.input.controllers.gamepad.maps;

import citrus.input.controllers.gamepad.Gamepad;

/**
	 * This is the Freebox _gamepad controller preset
	 * It will work only in analog mode though (axes are weird when its not)
	 * http://www.lowcostmobile.com/img/operateurs/free/_gamepad_free.jpg
	 */
class CSLSnesMap extends GamepadMap
{
    public function new()
    {
        super();
        canBeRebinded = false;
    }
    
    override public function setupWIN() : Void {
        _gamepad.registerStick(GamepadMap.STICK_LEFT, "AXIS_2", "AXIS_4");
        //_gamepad.registerStick(GamePadMap.STICK_RIGHT,"", "");
        
        _gamepad.registerButton(GamepadMap.L1, "BUTTON_9");
        _gamepad.registerButton(GamepadMap.R1, "BUTTON_11");
        
        _gamepad.registerButton(GamepadMap.SELECT, "BUTTON_13");
        _gamepad.registerButton(GamepadMap.START, "BUTTON_14");
        
        _gamepad.registerButton(GamepadMap.BUTTON_TOP, "BUTTON_5");
        _gamepad.registerButton(GamepadMap.BUTTON_RIGHT, "BUTTON_6");
        _gamepad.registerButton(GamepadMap.BUTTON_BOTTOM, "BUTTON_7");
        _gamepad.registerButton(GamepadMap.BUTTON_LEFT, "BUTTON_8");
    }
}

