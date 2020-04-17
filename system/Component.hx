package citrus.system;

import citrus.core.CitrusObject;

/**
	 * A component is an object dedicate to a (single) task for an entity : physics, collision, inputs, view, movement... management.
	 * You will use an entity when your object become too much complex to manage into a single class.
	 * Preferably if you use a physics engine, create at first the entity's physics component.
	 * It extends the CitrusObject class to enjoy its params setter.
	 */
class Component extends CitrusObject
{
    
    public var entity : Entity;
    
    public function new(name : String, params : Dynamic = null)
    {
        if (params == null)
        {
            params = {
                        type : "component"
                    };
        }
        else
        {
            Reflect.setField(params, "type", "component");
        }
        
        super(name, params);
    }
    
    /**
		 * Register other components in your component class in this function.
		 * It should be call after all components have been added to an entity.
		 */
    override public function initialize(poolObjectParams : Dynamic = null) : Void {
        super.initialize();
    }
    
    /**
		 * Destroy the component, most of the time called by its entity.
		 */
    override public function destroy() : Void {
        super.destroy();
    }
    
    /**
		 * Perform an update on the component, called by its entity.
		 */
    override public function update(timeDelta : Float) : Void {
        super.update(timeDelta);
    }
}

