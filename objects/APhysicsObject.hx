package citrus.objects;

import citrus.core.CitrusObject;
import citrus.view.ICitrusArt;
import citrus.view.starlingview.AnimationSequence;
import starling.display.DisplayObject;
import starling.display.Image;

/**
	 * An abstract template used by every physics object.
	 */
class APhysicsObject extends CitrusObject {
	public var view(get, set) : DisplayObject;
	public var viewAnim: AnimationSequence;
	public var viewImage: Image;
	public var art(get, never) : ICitrusArt;
	public var inverted(get, never) : Bool;
	public var animation(get, set) : String;
	public var visible(get, set) : Bool;
	public var parallaxX(get, set) : Float;
	public var parallaxY(get, set) : Float;
	public var touchable(get, set) : Bool;
	public var group(get, set) : Int;
	public var offsetX(get, set) : Float;
	public var offsetY(get, set) : Float;
	public var registration(get, set) : String;

	private var _view : Dynamic;
	// private var _viewAnim : AnimationSequence;
	private var _art : ICitrusArt;
	private var _inverted : Bool = false;
	private var _parallaxX : Float = 1;
	private var _parallaxY : Float = 1;
	private var _animation : String = "";
	private var _visible : Bool = true;
	private var _touchable : Bool = false;
	private var _x : Float = 0;
	private var _y : Float = 0;
	private var _z : Float = 0;
	private var _rotation : Float = 0;
	private var _radius : Float = 0;

	private var _group : Int = 0;
	private var _offsetX : Float = 0;
	private var _offsetY : Float = 0;
	private var _registration : String = "center";

	public function new(name : String, params : Dynamic = null) {
		super(name, params);
	}

	/**
		 * This function will add the physics stuff to the object. It's automatically called when the object is added to the state.
		 */
	public function addPhysics() : Void {
	}

	/**
		 * called when the art is created (and loaded if loading is required)
		 * @param	citrusArt the art
		 */
	public function handleArtReady(citrusArt : ICitrusArt) : Void {
		_art = citrusArt;
	}

	/**
		 * called when the art changes. the argument is the art with its previous content
		 * so that you can remove event listeners from it for example.
		 * @param	citrusArt the art
		 */
	public function handleArtChanged(oldArt : ICitrusArt) : Void {
	}

	/**
		 * You should override this method to extend the functionality of your physics object. This is where you will
		 * want to do any velocity/force logic.
		 */
	override public function update(timeDelta : Float) : Void {

		super.update(timeDelta);
	}

	/**
		 * This method doesn't depend of your application enter frame. Ideally, the time between two calls never change.
		 * In this method you will apply any velocity/force logic.
		 */
	public function fixedUpdate() : Void {
	}

	/**
		 * Destroy your physics objects!
		 */
	override public function destroy() : Void {
		_art = null;
		updateCallEnabled = false;
		kill = true;
		super.destroy();
	}

	/**
		 * Used for abstraction on body. There is also a getter on the body defined by each engine to keep body's type.
		 */

	public function getBody() : Dynamic {
		return null;
	}

	/**
		 * The view can be a class, a string to a file, or a display object. It must be supported by the view you target.
		 */
	public function get_view() : Dynamic {
		return _view;
	}

	//@:meta(Inspectable(defaultValue = "", format = "File", type = "String"))

	public function destroyView():Void {

		if (view != null && view.filter != null) {
			view.filter.dispose();
			view.filter = null;
		}

		if (viewAnim != null) viewAnim.destroy();
		if (viewImage != null) {
			viewImage.dispose();
			viewImage.removeFromParent(true);
		}
		

		viewAnim = null;
		viewImage = null;
		view = null;
	}

	public function set_view(value : Dynamic) : Dynamic {
		_view = value;
		if (Std.is(value, AnimationSequence)) viewAnim = value;
		else if (Std.is(value, Image)) viewImage = value;
		return value;
	}

	/*  public function set_viewAnim(value : AnimationSequence) : AnimationSequence
	  {
	      _viewAnim = value;
	      return value;
	  }

	public function get_viewAnim() : AnimationSequence
	  {
	      return _viewAnim;
	  }*/

	/**
		 * @inheritDoc
		 */
	public function get_art() : ICitrusArt {
		return _art;
	}

	/**
		 * Used to invert the view on the y-axis, number of animations friendly!
		 */
	public function get_inverted() : Bool {
		return _inverted;
	}

	/**
		 * Animations management works the same way than label whether it uses MovieClip, SpriteSheet or whatever.
		 */
	public function get_animation() : String {
		return _animation;
	}

	public function set_animation(value : String) : String {
		_animation = value;
		return value;
	}

	/**
		 * You can easily change if an object is visible or not. It hasn't any impact on physics computation.
		 */
	@:meta(Inline())

	@:finalpublic function get_visible() : Bool {
		return _visible;
	}

	@:meta(Inline())

	@:finalpublic function set_visible(value : Bool) : Bool {
		_visible = value;
		return value;
	}

	public function get_parallaxX() : Float {
		return _parallaxX;
	}

	@:meta(Inspectable(defaultValue="1"))

	public function set_parallaxX(value : Float) : Float {
		_parallaxX = value;
		return value;
	}

	public function get_parallaxY() : Float {
		return _parallaxY;
	}

	@:meta(Inline())

	@:finalpublic function get_touchable() : Bool {
		return _touchable;
	}

	@:meta(Inspectable(defaultValue="false"))

	public function set_touchable(value : Bool) : Bool {
		_touchable = value;
		return value;
	}

	@:meta(Inspectable(defaultValue="1"))

	public function set_parallaxY(value : Float) : Float {
		_parallaxY = value;
		return value;
	}

	/**
		 * The group is similar to a z-index sorting. Default is 0, 1 is over.
		 */
	@:meta(Inline())

	@:final public function get_group() : Int {
		//  trace("GET GROUP ["+_group+"]");
		return _group;
	}

	@:meta(Inspectable(defaultValue="0"))

	public function set_group(value : Int) : Int {
		_group = value;

		return value;
	}

	/**
		 * offsetX allows to move graphics on x axis compared to their initial point.
		 */
	public function get_offsetX() : Float {
		return _offsetX;
	}

	@:meta(Inspectable(defaultValue="0"))

	public function set_offsetX(value : Float) : Float {
		_offsetX = value;
		return value;
	}

	/**
		 * offsetY allows to move graphics on y axis compared to their initial point.
		 */
	public function get_offsetY() : Float {
		return _offsetY;
	}

	@:meta(Inspectable(defaultValue="0"))

	public function set_offsetY(value : Float) : Float {
		_offsetY = value;
		return value;
	}

	/**
		 * Flash registration point is topLeft, whereas physics engine use mostly center.
		 * You can change the registration point thanks to this property.
		 */
	@:meta(Inline())

	@:finalpublic function get_registration() : String {
		return _registration;
	}

	@:meta(Inspectable(defaultValue="center",enumeration="center,topLeft"))

	public function set_registration(value : String) : String {
		_registration = value;
		return value;
	}
}

