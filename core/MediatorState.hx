package citrus.core;

import as3hx.Debug;
import kaleidoEngine.data.utils.object.Objects;
import kaleidoEngine.debug.InArray;
import flash.errors.Error;

import citrus.objects.APhysicsObject;
import citrus.system.Component;
import citrus.system.Entity;
import citrus.system.components.ViewComponent;
import citrus.view.ACitrusView;

/**
	 * The MediatorState class is very important. It usually contains the logic for a particular state the game is in.
	 * You should never instanciate/extend this class by your own. It's used via a wrapper: State or StarlingState or Away3DState.
	 * There can only ever be one state running at a time. You should extend the State class
	 * to create logic and scripts for your levels. You can build one state for each level, or
	 * create a state that represents all your levels. You can get and set the reference to your active
	 * state via the CitrusEngine class.
	 */
@:final class MediatorState
{
    public var view(get, set) : ACitrusView;
    public var objects(get, never) : Array<CitrusObject>;

    
    private var _objects : Array<CitrusObject> = new Array<CitrusObject>();
   // private var _poolObjects : Array<PoolObject> = new Array<PoolObject>();
    private var _view : ACitrusView;
    
    public function new()
    {
    }
    
    /**
		 * Called by the Citrus Engine.
		 */
    public function destroy() : Void
    // Call destroy on all objects, and remove all art from the stage.
    {
       // trace("MEDIATOR STATE DESTROY IF THINGS BREAK TRY destroy() instead or .kill=true");
     
       
        for (i in 0..._objects.length)
        {
	
            var object : CitrusObject = _objects[i];
			
		
			//trace("DESTROY OBJECT[" + i + "]");
			if (object != null) {
				object.kill = true;	
				
			}else {
			
			}
           // --i;
        }
	
	   //trace("MEDIATOR DESTROYED"); 
        _view.destroy();
		
		//trace("MEDIATOR VIEW DESTROYED"); 
    }
    
    /**
		 * Gets a reference to this state's view manager. Take a look at the class definition for more information about this. 
		 */
   public function get_view() : ACitrusView
    {
        return _view;
    }
    
   public function set_view(value : ACitrusView) : ACitrusView
    {
        _view = value;
        return value;
    }
    
    /**
		 * This method calls update on all the CitrusObjects that are attached to this state.
		 * The update method also checks for CitrusObjects that are ready to be destroyed and kills them.
		 * Finally, this method updates the View manager. 
		 */
    public function update(timeDelta : Float) : Void
    // Search objects to destroy
    {
        
        var garbage : Array<Dynamic> = [];
        var n : Int = _objects.length;
        
        var object : CitrusObject;
        
        for (i in 0...n)
        {
            object = _objects[i];
           
            if (object.kill) {
			
                garbage.push(object);
            }
            else if (object.updateCallEnabled){
                object.update(timeDelta);
            }
        }
        
        // Destroy all objects marked for destroy
        // TODO There might be a limit on the number of Box2D bodies that you can destroy in one tick?
        n = garbage.length;
        var garbageObject : CitrusObject;
        for (i in 0...n)
        {
            garbageObject = garbage[i];
			
            _objects.splice(Lambda.indexOf(_objects, garbageObject), 1);
            
            if (Std.is(garbageObject, Entity)){
                var views : Array<Component> = cast(garbageObject, Entity).lookupComponentsByType(ViewComponent);
                if (views.length > 0)
                {
                    for (view in views)
                    {
						//trace("DESTROY removeArt[1] FROM:"+garbageObject.name + "{"+view+"}");
                        _view.removeArt(view);
                    }
                }
            }
            else
            {
				//trace("DESTROY tries to removeArt[2] FROM:"+garbageObject.name);
                if (_view.removeArt(garbageObject)) {
				//	  Objects.removeKey(_view._viewObjects, citrusObject);
				}
            }
            
			//trace("DESTROY object:"+garbageObject.name);
            garbageObject.destroy();
			//trace("REMOVE GARBAGE OBJ...Completed");
        }
        
       /* for (poolObject in _poolObjects)
        {
            poolObject.updatePhysics(timeDelta);
        }*/
        
        // Update the state's view
        _view.update(timeDelta);
    }
    
    /**
		 * Call this method to add a CitrusObject to this state. All visible game objects and physics objects
		 * will need to be created and added via this method so that they can be properly created, managed, updated, and destroyed. 
		 * @return The CitrusObject that you passed in. Useful for linking commands together.
		 */
    public function add(object : CitrusObject) : CitrusObject
    {
      
		//trace("****ADD OBJECT("+object+")");
		
		if (Std.is(object, Entity))
        {
            throw new Error("Object named: " + object.name + " is an entity and should be added to the state via addEntity method.");
        }
       
		
		if (has(object)) throw new Error(object.name + " is already added to the state.");
       
       /* for (objectAdded in objects)
        {
            if (object == objectAdded){
                throw new Error(object.name + " is already added to the state.");
            }
        }*/
      
        if (Std.is(object, APhysicsObject)){
            cast(object, APhysicsObject).addPhysics();
        }

        _objects.push(object);
        _view.addArt(object);
        return object;
    }
	
		
	 public function has(object : CitrusObject) : Bool{
		for (objectAdded in objects){
            if (object == objectAdded){
               return true;
            }
        }
        return false;
	 }
    
    /**
		 * Call this method to add an Entity to this state. All entities will need to be created
		 * and added via this method so that they can be properly created, managed, updated, and destroyed.
		 * @return The Entity that you passed in. Useful for linking commands together.
		 */
    public function addEntity(entity : Entity) : Entity
    {
        for (objectAdded in objects)
        {
            if (entity == objectAdded){
                throw new Error(entity.name + " is already added to the state.");
            }
        }
        
        _objects.push(entity);
        
        var views : Array<Component> = entity.lookupComponentsByType(ViewComponent);
        if (views.length > 0)
        {
            for (view in views){
                _view.addArt(view);
            }
        }
        
        return entity;
    }
    
    /**
		 * Call this method to add a PoolObject to this state. All pool objects and  will need to be created 
		 * and added via this method so that they can be properly created, managed, updated, and destroyed.
		 * @param poolObject The PoolObject isCitrusObjectPool's value must be true to be render through the State.
		 * @return The PoolObject that you passed in. Useful for linking commands together.
		 */
  /*  public function addPoolObject(poolObject : PoolObject) : PoolObject
    {
        if (poolObject.isCitrusObjectPool)
        {
            _poolObjects.push(poolObject);
            
            return poolObject;
        }
        else
        {
            return null;
        }
    }*/
    
    /**
		 * When you are ready to remove an object from getting updated, viewed, and generally being existent, call this method.
		 * Alternatively, you can just set the object's kill property to true. That's all this method does at the moment. 
		 */
    public function remove(object : CitrusObject) : Void {
        object.kill = true;
    }
    
    /**
		 * Gets a reference to a CitrusObject by passing that object's name in.
		 * Often the name property will be set via a level editor such as the Flash IDE. 
		 * @param name The name property of the object you want to get a reference to.
		 */
    public function getObjectByName(name : String) : CitrusObject
    {
        for (object in _objects)
        {
            if (object.name == name){
                return object;
            }
        }
        
       /* if (_poolObjects.length > 0)
        {
            var poolObject : PoolObject;
            var found : Bool = false;
            for (poolObject in _poolObjects){
                poolObject.foreachRecycled(function(pobject : Dynamic) : Bool
                        {
                            if (Std.is(pobject, CitrusObject) && Reflect.field(pobject, "name") == name)
                            {
                                object = pobject;
                                return found = true;
                            }
                            return false;
                        });
                
                if (found)
                {
                    return object;
                }
            }
        }*/
        
        return null;
    }
    
    /**
		 * This returns a vector of all objects of a particular name. This is useful for adding an event handler
		 * to objects that aren't similar but have the same name. For instance, you can track the collection of 
		 * coins plus enemies that you've named exactly the same. Then you'd loop through the returned vector to change properties or whatever you want.
		 * @param name The name property of the object you want to get a reference to.
		 */
    public function getObjectsByName(name : String) : Array<CitrusObject>
    {
        var objects : Array<CitrusObject> = new Array<CitrusObject>();
        var object : CitrusObject;
        
        for (object in _objects)
        {
            if (object.name == name){
                objects.push(object);
            }
        }
        
     /*   if (_poolObjects.length > 0)
        {
            var poolObject : PoolObject;
            for (poolObject in _poolObjects){
                poolObject.foreachRecycled(function(pobject : Dynamic) : Bool
                        {
                            if (Std.is(pobject, CitrusObject) && Reflect.field(pobject, "name") == name)
                            {
                                objects.push(try cast(pobject, CitrusObject) catch(e:Dynamic) null);
                            }
                            return false;
                        });
            }
        }
        */
        return objects;
    }
    
    /**
		 * Returns the first instance of a CitrusObject that is of the class that you pass in. 
		 * This is useful if you know that there is only one object of a certain time in your state (such as a "Hero").
		 * @param type The class of the object you want to get a reference to.
		 */
    public function getFirstObjectByType(type : Class<Dynamic>) : CitrusObject
    {
        var object : CitrusObject;
        
        for (object in _objects)
        {
            if (Std.is(object, type)){
                return object;
            }
        }
        
      /*  if (_poolObjects.length > 0)
        {
            var poolObject : PoolObject;
            var found : Bool = false;
            for (poolObject in _poolObjects){
                poolObject.foreachRecycled(function(pobject : Dynamic) : Bool
                        {
                            if (Std.is(pobject, type))
                            {
                                object = pobject;
                                return found = true;
                            }
                            return false;
                        });
                
                if (found)
                {
                    return object;
                }
            }
        }
        */
        return null;
    }
    
    /**
		 * This returns a vector of all objects of a particular type. This is useful for adding an event handler
		 * to all similar objects. For instance, if you want to track the collection of coins, you can get all objects
		 * of type "Coin" via this method. Then you'd loop through the returned array to add your listener to the coins' event.
		 * @param type The class of the object you want to get a reference to.
		 */
    public function getObjectsByType(type : Class<Dynamic>) : Array<CitrusObject>
    {
        var objects : Array<CitrusObject> = new Array<CitrusObject>();
        var object : CitrusObject;
        
        for (object in _objects)
        {
            if (Std.is(object, type)){
                objects.push(object);
            }
        }
        
      /*  if (_poolObjects.length > 0)
        {
            var poolObject : PoolObject;
            for (poolObject in _poolObjects){
                poolObject.foreachRecycled(function(pobject : Dynamic) : Bool
                        {
                            if (Std.is(pobject, type))
                            {
                                objects.push(try cast(pobject, CitrusObject) catch(e:Dynamic) null);
                            }
                            return false;
                        });
            }
        }
        */
        return objects;
    }
    
    /**
		 * Destroy all the objects added to the State and not already killed.
		 * @param except CitrusObjects you want to save.
		 */
    public function killAllObjects(except : Array<Dynamic>) : Void {
        for (objectToKill in _objects)
        {
            objectToKill.kill = true;
            
            for (objectToPreserve in except){
                if (objectToKill == objectToPreserve)
                {
                    objectToPreserve.kill = false;
                    except.splice(Lambda.indexOf(except, objectToPreserve), 1);
                    break;
                }
            }
        }
    }
    
    /**
		 * Contains all the objects added to the State and not killed.
		 */
   public function get_objects() : Array<CitrusObject>
    {
        return _objects;
    }
}
