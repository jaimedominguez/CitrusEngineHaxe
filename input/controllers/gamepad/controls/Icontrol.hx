package citrus.input.controllers.gamepad.controls;

import citrus.input.controllers.gamepad.Gamepad;

/**
	 * defines control wrappers we use in Gamepad.
	 */
interface Icontrol
{
    var gamePad(get, never) : Gamepad;

    function updateControl(control : String, value : Float) : Void
    ;function hasControl(id : String) : Bool
    ;function destroy() : Void
    ;
}

