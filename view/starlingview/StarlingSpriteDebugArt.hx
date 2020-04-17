package citrus.view.starlingview;

import citrus.core.CitrusObject;
import citrus.objects.CitrusSprite;
import starling.display.DisplayObjectContainer;
import starling.display.Quad;

/**
	 * This class is created by the StarlingView if a CitrusSprite has no view mentionned. It is made for a quick debugging object's view.
	 */
class StarlingSpriteDebugArt extends DisplayObjectContainer {
	public function new()
    {
        super();
    }
	public function initialize(object : CitrusObject) : Void {
        var citrusSprite : CitrusSprite = cast(object, CitrusSprite);
		if (citrusSprite != null)
        {
            var quad : Quad = new Quad(citrusSprite.width, citrusSprite.height, 0x888888);
			addChild(quad);
        }
    }
}