package citrus.objects;

import flash.errors.Error;
import citrus.physics.nape.INapePhysicsObject;
import citrus.physics.nape.Nape;
import citrus.physics.PhysicsCollisionCategories;
import citrus.view.ISpriteView;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.dynamics.InteractionFilter;
import nape.geom.GeomPoly;
import nape.geom.GeomPolyList;
import nape.geom.Vec2;
import nape.geom.Vec2List;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.shape.Shape;
import nape.shape.ValidationResult;

/**
	 * You should extend this class to take advantage of Nape. This class provides template methods for defining
	 * and creating Nape bodies, fixtures, shapes, and joints. If you are not familiar with Nape, you should first
	 * learn about it via the <a href="http://napephys.com/help/manual.html">Nape Manual</a>.
	 */
class NapePhysicsObject extends APhysicsObject implements ISpriteView implements INapePhysicsObject {
	public var x(get, set) : Float;
	public var y(get, set) : Float;
	public var z(get, never) : Float;
	public var rotation(get, set) : Float;
	public var width(get, set) : Float;
	public var height(get, set) : Float;
	public var depth(get, never) : Float;
	public var radius(get, set) : Float;
	public var body(get, never) : Body;
	public var velocity(get, set) : Array<Float>;
	public var beginContactCallEnabled(get, set) : Bool;
	public var endContactCallEnabled(get, set) : Bool;

	public static var PHYSICS_OBJECT : CbType = new CbType();

	private var _nape : Nape;
	private var _bodyType : BodyType;
	private var _body : Body;
	private var _material : Material;
	private var _shape : Shape;

	private var _width : Float = 30;
	private var _height : Float = 30;

	private var _beginContactCallEnabled : Bool = false;
	private var _endContactCallEnabled : Bool = false;

	/**
		 * Used to define vertices' x and y points.
		 */
	public var points : Array<Dynamic>;
	public var citrus_internal_data : Dynamic;

	/**
		 * Creates an instance of a NapePhysicsObject. Natively, this object does not default to any graphical representation,
		 * so you will need to set the "view" property in the params parameter.
		 */
	public function new(name : String, params : Dynamic = null) {
		super(name, params);
	}

	/**
		 * All your init physics code must be added in this method, no physics code into the constructor. It's automatically called when the object is added to the state.
		 * <p>You'll notice that the NapePhysicsObject's initialize method calls a bunch of functions that start with "define" and "create".
		 * This is how the Nape objects are created. You should override these methods in your own NapePhysicsObject implementation
		 * if you need additional Nape functionality. Please see provided examples of classes that have overridden
		 * the NapePhysicsObject.</p>
		 */
	override public function addPhysics() : Void {
		_nape = try cast(_ce.state.getFirstObjectByType(Nape), Nape) catch (e:Dynamic) null;

		if (_nape == null) {
			throw new Error("Cannot create a NapePhysicsObject when a Nape object has not been added to the state.");
		}

		//Override these to customize your Nape initialization. Things must be done in this order.
		defineBody();
		createBody();
		createMaterial();
		createShape();
		createFilter();
		createConstraint();
	}

	override public function destroy() : Void {

		destroyPhysics();
		destroyView();

		super.destroy();
	}

	private function destroyPhysics():Void {
		if (_body != null) {
			_body.shapes.clear();
			_nape.space.bodies.remove(_body);
			_body.space = null;
			_body = null;
			_shape = null;
			_material = null;
			_bodyType = null;
			_nape = null;
		}
	}

	public function handlePreContact(callback : PreCallback) : PreFlag {
		return PreFlag.ACCEPT;
	}

	/**
		 * Override this method to handle the begin contact collision.
		 */
	public function handleBeginContact(callback : InteractionCallback) : Void {
	}

	/**
		 * Override this method to handle the end contact collision.
		 */
	public function handleEndContact(callback : InteractionCallback) : Void {
	}

	/**
		 * This method will often need to be overridden to provide additional definition to the Nape body object.
		 */
	private function defineBody() : Void {
		_bodyType = BodyType.DYNAMIC;
	}

	/**
		 * This method will often need to be overridden to customize the Nape body object.
		 */
	private function createBody() : Void {
		_body = new Body(_bodyType, new Vec2(_x, _y));
		_body.userData.myData = this;
		_body.isBullet = false;
		_body.disableCCD = true;
		_body.rotate(new Vec2(_x, _y), _rotation);
	}

	/**
		 * This method will often need to be overridden to customize the Nape material object.
		 */
	private function createMaterial() : Void {
		//  _material = new Material(0.65, 0.57, 1.2, 1, 0);
		_material = new Material();
	}

	/**
		 * This method will often need to be overridden to customize the Nape shape object.
		 * The PhysicsObject creates a rectangle by default if the radius it not defined, but you can replace this method's
		 * definition and instead create a custom shape, such as a line or circle.
		 */
	private function createShape() : Void
	// Used by the Tiled Map Editor software, if we defined a polygon/polyline
	{

		if (points != null && points.length > 1) {
			var verts : Vec2List = new Vec2List();

			for (point in points) {
				verts.push(new Vec2(Std.parseFloat(point.x), Std.parseFloat(point.y)));
			}

			var polygon : Polygon = new Polygon(verts, _material);
			var validation : ValidationResult = polygon.validity();

			if (validation == ValidationResult.VALID) {
				_shape = polygon;
			} else if (validation == ValidationResult.CONCAVE) {
				var concave : GeomPoly = new GeomPoly(verts);
				var convex : GeomPolyList = concave.convexDecomposition();
				convex.foreach(function(p : GeomPoly) : Void {
					_body.shapes.add(new Polygon(p));
				});
				return;
			} else {
				throw new Error("Invalid polygon/polyline");
			}
		} else if (_radius != 0) {
			_shape = new Circle(_radius, null, _material);
		} else
		{
			_shape = new Polygon(Polygon.box(_width, _height), _material);
		}

		_body.shapes.add(_shape);
	}

	/**
		 * This method will often need to be overridden to customize the Nape filter object.
		 */
	private function createFilter() : Void {
		// trace("FILTER NOT FULLEY SET, PLEASE REMOVE SUPER CALL()");
		//	_body.setShapeFilters(new InteractionFilter(PhysicsCollisionCategories.Get(["Level"]), PhysicsCollisionCategories.Get()));
	}

	/**
		 * This method will often need to be overridden to customize the Nape constraint object.
		 */
	private function createConstraint() : Void {
		_body.space = _nape.space;
		_body.cbTypes.add(PHYSICS_OBJECT);
	}

	private function moveBodyRelative(vx:Float, vy:Float):Void {
		//_body.velocity = new Vec2(vx, vy);
		var pos : Vec2 = _body.position;
		if (vx!=0 || vy!=0) _body.position.setxy(pos.x + vx, pos.y + vy);
	}

	public function get_x() : Float {
		if (_body != null) {
			return _body.position.x;
		} else
		{
			return _x;
		}
	}
	@:meta(Inline())

	@:finalpublic function set_x(value : Float) : Float {
		_x = value;

		if (_body != null) {
			var pos : Vec2 = _body.position;
			pos.x = _x;
			_body.position = pos;
		}
		return value;
	}

	public function get_y() : Float {
		if (_body != null) {
			return _body.position.y;
		} else
		{
			return _y;
		}
	}

	@:meta(Inline())

	@:finalpublic function set_y(value : Float) : Float {
		_y = value;

		if (_body != null) {
			var pos : Vec2 = _body.position;
			pos.y = _y;
			_body.position = pos;
		}
		return value;
	}

	public function get_z() : Float {
		return 0;
	}

	@:meta(Inline())

	@:finalpublic function get_rotation() : Float {
		if (_body != null) {
			return _body.rotation * 180 / Math.PI;
		} else
		{
			return _rotation * 180 / Math.PI;
		}
	}

	@:meta(Inline())

	@:finalpublic function set_rotation(value : Float) : Float {
		_rotation = value * Math.PI / 180;

		if (_body != null) {
			_body.rotation = _rotation;
		}
		return value;
	}

	/**
		 * This can only be set in the constructor parameters.
		 */
	@:meta(Inline())

	@:finalpublic function get_width() : Float {
		return _width;
	}

	@:meta(Inline())

	@:finalpublic function set_width(value : Float) : Float {
		_width = value;

		if (_initialized && !hideParamWarnings) {
			trace("Warning: You cannot set " + this + " width after it has been created. Please set it in the constructor.");
		}
		return value;
	}

	/**
		 * This can only be set in the constructor parameters.
		 */
	@:meta(Inline())

	@:finalpublic function get_height() : Float {
		return _height;
	}

	@:meta(Inline())

	@:finalpublic function set_height(value : Float) : Float {
		_height = value;

		if (_initialized && !hideParamWarnings) {
			trace("Warning: You cannot set " + this + " height after it has been created. Please set it in the constructor.");
		}
		return value;
	}

	/**
		 * No depth in a 2D Physics world.
		 */
	@:meta(Inline())

	@:finalpublic function get_depth() : Float {
		return 0;
	}

	/**
		 * This can only be set in the constructor parameters.
		[Inline]
		final  */
	public function get_radius() : Float {
		return _radius;
	}

	/**
		 * The object has a radius or a width and height. It can't have both.
		 */
	@:meta(Inspectable(defaultValue="0"))

	@:meta(Inline())

	@:finalpublic function set_radius(value : Float) : Float {
		_radius = value;

		if (_initialized) {
			trace("Warning: You cannot set " + this + " radius after it has been created. Please set it in the constructor.");
		}
		return value;
	}

	/**
		 * A direct reference to the Nape body associated with this object.
		 */
	@:meta(Inline())

	@:finalpublic function get_body() : Body {
		return _body;
	}

	@:meta(Inline())

	@:final override public function getBody() : Dynamic {
		return _body;
	}

	public function get_velocity() : Array<Float> {
		return [_body.velocity.x, _body.velocity.y, 0];
	}

	public function set_velocity(value : Array<Float>) : Array<Float> {
		_body.velocity.setxy(value[0], value[1]);
		return value;
	}
	
	

	/**
		 * This flag determines if the <code>handleBeginContact</code> method is called or not. Default is false, it saves some performances.
		 */
	@:meta(Inline())

	@:finalpublic function get_beginContactCallEnabled() : Bool {
		return _beginContactCallEnabled;
	}

	/**
		 * Enable or disable the <code>handleBeginContact</code> method to be called. It doesn't change physics behavior.
		 */
	@:meta(Inline())

	@:finalpublic function set_beginContactCallEnabled(beginContactCallEnabled : Bool) : Bool {
		_beginContactCallEnabled = beginContactCallEnabled;
		return beginContactCallEnabled;
	}

	/**
		 * This flag determines if the <code>handleEndContact</code> method is called or not. Default is false, it saves some performances.
		 */
	@:meta(Inline())

	@:finalpublic function get_endContactCallEnabled() : Bool {
		return _endContactCallEnabled;
	}

	/**
		 * Enable or disable the <code>handleEndContact</code> method to be called. It doesn't change physics behavior.
		 */
	@:meta(Inline())

	@:finalpublic function set_endContactCallEnabled(endContactCallEnabled : Bool) : Bool {
		_endContactCallEnabled = endContactCallEnabled;
		return endContactCallEnabled;
	}
}

