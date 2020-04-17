package citrus.core.starling;

import flash.errors.Error;
import citrus.core.CitrusEngine;
import citrus.core.CitrusObject;
import citrus.core.IState;
import citrus.core.MediatorState;

import citrus.input.Input;
import citrus.system.Entity;
import citrus.system.components.ViewComponent;
import citrus.view.ACitrusView;
import citrus.view.starlingview.StarlingCamera;
import citrus.view.starlingview.StarlingView;
import starling.display.Sprite;

#if (switch && !final)
	import lime.console.nswitch.Profiler;
#end

/**
	 * StarlingState class is just a wrapper for the AState class. It's important to notice it extends Starling Sprite.
	 */
class StarlingState extends Sprite implements IState {
	public var view(get, never) : ACitrusView;
	public var objects(get, never) : Array<CitrusObject>;
	public var camera(get, never) : StarlingCamera;

	/**
		 * Get a direct references to the Citrus Engine in your State.
		 */
	private var _ce : StarlingCitrusEngine;

	private var _realState : MediatorState;

	private var _input : Input;

	public function new() {
		super();

		_ce = cast(CitrusEngine.getInstance(), StarlingCitrusEngine);

		/*if (cast(_ce, StarlingCitrusEngine)==null || cast(_ce, StarlingCitrusEngine).starling!=null)
		{
		    throw new Error("Your Main " + _ce + " class doesn't extend StarlingCitrusEngine, or you didn't call its setUpStarling function");
		}
		*/
		_realState = new MediatorState();
	}

	/**
		 * Called by the Citrus Engine.
		 */
	public function destroy() : Void {
		_realState.destroy();
	}

	/**
		 * Gets a reference to this state's view manager. Take a look at the class definition for more information about this.
		 */
	public function get_view() : ACitrusView {
		return _realState.view;
	}

	/**
		 * You'll most definitely want to override this method when you create your own State class. This is where you should
		 * add all your CitrusObjects and pretty much make everything. Please note that you can't successfully call add() on a
		 * state in the constructur. You should call it in this initialize() method.
		 */
	public function initialize() : Void {
		_realState.view = createView();
		_input = _ce.input;
	}

	/**
		 * This method calls update on all the CitrusObjects that are attached to this state.
		 * The update method also checks for CitrusObjects that are ready to be destroyed and kills them.
		 * Finally, this method updates the View manager.
		 */
	public function update(timeDelta : Float) : Void {
		_realState.update(timeDelta);

		#if (switch && debug)
		Profiler.RecordHeartbeat();
		#end
	}

	/**
		 * Call this method to add a CitrusObject to this state. All visible game objects and physics objects
		 * will need to be created and added via this method so that they can be properly created, managed, updated, and destroyed.
		 * @return The CitrusObject that you passed in. Useful for linking commands together.
		 */
	public function add(object : CitrusObject) : CitrusObject {
		return _realState.add(object);
	}

	/**
		 * Call this method to add an Entity to this state. All entities will need to be created
		 * and added via this method so that they can be properly created, managed, updated, and destroyed.
		 * @return The Entity that you passed in. Useful for linking commands together.
		 */
	public function addEntity(entity : Entity) : Entity {
		return _realState.addEntity(entity);
	}

	/**
		 * Call this method to add a PoolObject to this state. All pool objects and  will need to be created
		 * and added via this method so that they can be properly created, managed, updated, and destroyed.
		 * @param poolObject The PoolObject isCitrusObjectPool's value must be true to be render through the State.
		 * @return The PoolObject that you passed in. Useful for linking commands together.
		 */
	/*  public function addPoolObject(poolObject : PoolObject) : PoolObject
	  {
	      return _realState.addPoolObject(poolObject);
	  }*/

	/**
		 * When you are ready to remove an object from getting updated, viewed, and generally being existent, call this method.
		 * Alternatively, you can just set the object's kill property to true. That's all this method does at the moment.
		 */
	public function remove(object : CitrusObject) : Void {
		_realState.remove(object);
	}

	/**
		 * Gets a reference to a CitrusObject by passing that object's name in.
		 * Often the name property will be set via a level editor such as the Flash IDE.
		 * @param name The name property of the object you want to get a reference to.
		 */
	public function getObjectByName(name : String) : CitrusObject {
		return _realState.getObjectByName(name);
	}

	/**
		 * This returns a vector of all objects of a particular name. This is useful for adding an event handler
		 * to objects that aren't similar but have the same name. For instance, you can track the collection of
		 * coins plus enemies that you've named exactly the same. Then you'd loop through the returned vector to change properties or whatever you want.
		 * @param name The name property of the object you want to get a reference to.
		 */
	public function getObjectsByName(name : String) : Array<CitrusObject> {
		return _realState.getObjectsByName(name);
	}

	/**
		 * Returns the first instance of a CitrusObject that is of the class that you pass in.
		 * This is useful if you know that there is only one object of a certain time in your state (such as a "Hero").
		 * @param type The class of the object you want to get a reference to.
		 */
	public function getFirstObjectByType(type : Class<Dynamic>) : CitrusObject {
		return _realState.getFirstObjectByType(type);
	}

	/**
		 * This returns a vector of all objects of a particular type. This is useful for adding an event handler
		 * to all similar objects. For instance, if you want to track the collection of coins, you can get all objects
		 * of type "Coin" via this method. Then you'd loop through the returned array to add your listener to the coins' event.
		 * @param type The class of the object you want to get a reference to.
		 */
	public function getObjectsByType(type : Class<Dynamic>) : Array<CitrusObject> {
		return _realState.getObjectsByType(type);
	}

	/**
		 * Destroy all the objects added to the State and not already killed.
		 * @param except CitrusObjects you want to save.
		 */
	public function killAllObjects(except : Array<Dynamic> = null) : Void {
		_realState.killAllObjects(except);
	}

	/**
		 * Contains all the objects added to the State and not killed.
		 */
	public function get_objects() : Array<CitrusObject> {
		return _realState.objects;
	}

	/**
		 * Override this method if you want a state to create an instance of a custom view.
		 */
	private function createView() : ACitrusView {
		return new StarlingView(this);
	}

	public function get_camera() : StarlingCamera {
		return try cast(view.camera, StarlingCamera) catch (e:Dynamic) null;
	}
}

