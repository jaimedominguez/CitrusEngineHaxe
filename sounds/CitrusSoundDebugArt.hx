package citrus.sounds;

import flash.display.Sprite;

/**
	 * flash.display.Sprite drawn onto by CitrusSoundSpace.
	 */
class CitrusSoundDebugArt extends Sprite
{
    
    public function new()
    {
        super();
        mouseEnabled = false;
        mouseChildren = false;
    }
    
    public function destroy() : Void {
    }
}

