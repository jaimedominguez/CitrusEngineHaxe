package citrus.physics.nape;

import citrus.physics.APhysicsEngine;
import citrus.physics.PhysicsCollisionCategories;
import citrus.view.ISpriteView;
import kaleidoEngine.core.EngineVars;
import nape.geom.Vec2;
import nape.space.Space;
import starling.display.Sprite;

/**
	 * This is a simple wrapper class that allows you to add a Nape space to your game's state.
	 * Add an instance of this class to your State before you create any physics bodies. It will need to 
	 * exist first, or your physics bodies will throw an error when they try to create themselves.
	 */
class Nape extends APhysicsEngine implements ISpriteView
{
    public var space(get, never) : Space;
    public var gravity(get, set) : Vec2;
    public var contactListener(get, never) : NapeContactListener;

    
    /**
		 * timeStep the amount of time to simulate, this should not vary.
		 */
    public var timeStep : Float = 1 / 20;
    
    /**
		 * velocityIterations for the velocity constraint solver.
		 */
    public var velocityIterations : Int = 8;
    
    /**
		 *positionIterations for the position constraint solver.
		 */
    public var positionIterations : Int = 8;
    
    private var _space : Space;
    private var _gravity : Vec2 = new Vec2(0, 450);
    private var _contactListener : NapeContactListener;
    
    /**
		 * Creates and initializes a Nape space. 
		 */
    public function new(name : String, params : Dynamic = null)
    {
			if (params != null) {
				params.view = NapeDebugArt;
			}else{
				params = {
					view : NapeDebugArt
			   };
			}

        super(name, params);
    }
    
    override public function initialize(poolObjectParams : Dynamic = null) : Void {
        super.initialize();

        _realDebugView = _view;
        
        _space = new Space(_gravity);
        _contactListener = new NapeContactListener(_space);
      
    }
    
    override public function destroy() : Void {
        _contactListener.destroy();
        _space.clear();
        
        super.destroy();
    }
    
    /**
		 * Gets a reference to the actual Nape space object. 
		 */
    @:meta(Inline())

    @:finalpublic function get_space() : Space
    {
        return _space;
    }
    
    /**
		 * Change the gravity of the space.
		 */
   public function get_gravity() : Vec2
    {
        return _gravity;
    }
    
   public function set_gravity(value : Vec2) : Vec2
    {
        _gravity = value;
        
        if (_space != null)
        {
            _space.gravity = _gravity;
        }
        return value;
    }
    
    /**
		 * Return a ContactListener class where some InteractionListeners are already defined.
		 */
    @:meta(Inline())

    @:finalpublic function get_contactListener() : NapeContactListener
    {
        return _contactListener;
    }
    
    /**
		 * This is where the time step of the physics world occurs.
		 */
    override public function update(timeDelta : Float) : Void {
        super.update(timeDelta);
        _space.step(timeStep, velocityIterations, positionIterations);
    }
}

