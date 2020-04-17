package citrus.system;

import citrus.core.CitrusObject;
import openfl.errors.Error;

/**
	 * A game entity is compound by components. The entity serves as a link to communicate between components.
	 * It extends the CitrusObject class to enjoy its params setter.
	 */

using Lambda;	 
class Entity extends CitrusObject
{
    public var components(get, never) : Array<Component>;

    
    private var _components : Array<Component>;
    
    public function new(name : String, params : Dynamic = null)
    {
        updateCallEnabled = true;
        
        if (params == null)
        {
            params = {
                        type : "entity"
                    };
        }
        else
        {
            Reflect.setField(params, "type", "entity");
        }
        
        super(name, params);
        
        _components = new Array<Component>();
    }
    
    /**
		 * Add a component to the entity.
		 */
    public function add(component : Component) : Entity
    {
        doAddComponent(component);
        
        return this;
    }
    
    private function doAddComponent(component : Component) : Bool {
        if (component.name == "")
        {
            trace("A component name was not specified. This might cause problems later.");
        }
        
        if (lookupComponentByName(component.name)!=null)
        {
            throw cast(("A component with name '" + component.name + "' already exists on this entity."), Error);
        }
        
        if (component.entity!=null)
        {
            if (component.entity == this){
                trace("Component with name '" + component.name + "' already has entity ('" + this.name + "') defined. Manually defining components is no longer needed");
                _components.push(component);
                return true;
            }
            
            throw cast(("The component '" + component.name + "' already has an owner. ('" + component.entity.name + "')"), Error);
        }
        
        component.entity = this;
        _components.push(component);
        return true;
    }
    
    /**
		 * Remove a component from the entity.
		 */
    public function remove(component : Component) : Void {
        var indexOfComponent : Int = Lambda.indexOf(_components, component);
        if (indexOfComponent != -1)
        {
            _components.splice(indexOfComponent, 1)[0].destroy();
        }
    }
    
    /**
		 * Search and return first componentType's instance found in components
		 *
		 * @param 	componentType  Component instance class we're looking for
		 * @return 	Component
		 */
    public function lookupComponentByType(componentType : Class<Dynamic>) : Component
    {
        var component : Component = null;
        var filteredComponents : Array<Component> = new Array<Component>();
		for (i in 0... _components.length) {
			if (Std.is(_components[i], componentType)){
				filteredComponents.push(_components[i]);
			}
		}

        if (filteredComponents.length != 0)
        {
            component = filteredComponents[0];
        }
        
        return component;
    }
    
    /**
		 * Search and return all componentType's instance found in components
		 *
		 * @param 	componentType  Component instance class we're looking for
		 */
    public function lookupComponentsByType(componentType : Class<Dynamic>) : Array<Component>
    {
        var filteredComponents : Array<Component> = new Array<Component>();
		for (i in 0... _components.length) {
			if (Std.is(_components[i], componentType)){
				filteredComponents.push(_components[i]);
			}
		}
        
        return filteredComponents;
    }
    
    /**
		 * Search and return a component using its name
		 *
		 * @param 	name Component's name we're looking for
		 * @return 	Component
		 */
    public function lookupComponentByName(name : String) : Component
    {
		var filteredComponents : Array<Component> = new Array<Component>();
		for (i in 0... _components.length) {
			if (_components[i].name == name){
				return _components[i];
			}
		}		
		
		var component : Component = null;
		return component;
		
    }
    
    /**
		 * After all the components have been added call this function to perform an init on them.
		 * Mostly used if you want to access to other components through the entity.
		 * Components initialization will be perform according order in which components
		 * has been add to entity
		 */
    override public function initialize(poolObjectParams : Dynamic = null) : Void {
        super.initialize();
        for (i in 0... _components.length) {
			_components[i].initialize();
		}
    }
    
    /**
		 * Destroy the entity and its components.
		 * Components destruction will be perform according order in which components
		 * has been add to entity
		 */
    override public function destroy() : Void {
		for (i in 0... _components.length) {
			_components[i].destroy();
		}
		_components = null;
		
		/*  _components.foreach(function(item : Component, index : Int, vector : Array<Component>) : Void
                {
                    item.destroy();
                });
        _components = null;
        */
        super.destroy();
    }
    
    /**
		 * Perform an update on all entity's components.
		 * Components update will be perform according order in which components
		 * has been add to entity
		 */
    override public function update(timeDelta : Float) : Void {

		for (i in 0... _components.length) {
			_components[i].update(timeDelta);
		}
		/*_components.foreach(function(item : Component, index : Int, vector : Array<Component>) : Void
                {
                    item.update(timeDelta);
                }, this);*/
    }
    
   public function get_components() : Array<Component>
    {
        return _components;
    }
}

