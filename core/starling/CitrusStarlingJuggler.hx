package citrus.core.starling;

import starling.animation.Juggler;

/**
	 * A Custom Starling Juggler used by CitrusEngine for pausing.
	 */
class CitrusStarlingJuggler extends Juggler
{
    public var paused : Bool = false;
    
    public function new()
    {
        super();
    }
    
    override public function advanceTime(timeDelta : Float) : Void {
        if (!paused)
        {
            super.advanceTime(timeDelta);
        }
    }
}

