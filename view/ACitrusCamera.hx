package citrus.view;

import flash.errors.Error;
import haxe.Constraints.Function;
//import aze.motion.EazeTween;
import citrus.core.CitrusEngine;
import citrus.math.MathUtils;
import citrus.math.MathVector;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.Capabilities;

/**
	 * Citrus's camera.
	 */
class ACitrusCamera
{
    public var target(get, set) : Dynamic;
    public var camPos(get, never) : Point;
    public var manualPosition(get, set) : Point;
    public var allowRotation(get, set) : Bool;
    public var allowZoom(get, set) : Bool;
    public var camProxy(get, never) : Dynamic;
    public var ghostTarget(get, never) : Point;
    private var mzoom(get, set) : Float;
    public var transformMatrix(get, never) : Matrix;

    
    /**
		 * Is the camera allowed to Zoom?
		 */
    private var _allowZoom : Bool = false;
    
    /**
		 * Is the camera allowed to Rotate?
		 */
    private var _allowRotation : Bool = false;
    
    /**
		 * the targeted rotation value.
		 */
    private var _rotation : Float = 0;
    
    /**
		 * the targeted zoom value.
		 */
    private var _zoom : Float = 1;
    
    /**
		 * base zoom - this is the overall zoom factor of the camera
		 */
    public var baseZoom : Float = 1;
    
    /**
		 * _aabb holds the axis aligned bounding box of the camera in rect
		 * and its relative position to it (with offsetX and offsetY)
		 */
    private var _aabbData : Dynamic = {
            offsetX : 0,
            offsetY : 0,
            rect : new Rectangle()
        };
    
    /**
		 * ghostTarget is the eased position of target.
		 */
    private var _ghostTarget : Point = new Point();
    
    /**
		 * targetPos is used for calculating ghostTarget.
		 * (not sure if really necessary)
		 */
    private var _targetPos : Point = new Point();
    
    /**
		 * the _camProxy object is used as a container to hold the data to be applied to the _viewroot.
		 * it can be accessible publicly so that debugView can be correctly displaced, rotated and scaled as _viewroot will be.
		 */
    private var _camProxy : Dynamic = {
            x : 0,
            y : 0,
            offset : new Point(),
            scale : 1,
            rotation : 0
        };
    
    /**
		 * projected camera position + offset. (used internally)
		 */
    private var _camPos : Point = new Point();
    
    /**
		 * the ease factor for zoom
		 */
    public var zoomEasing : Float = 0.05;
    
    /**
		 * the ease factor for rotation
		 */
    public var rotationEasing : Float = 0.05;
    
    private var _viewRoot : Dynamic;
    
    // Camera properties
    /**
		 * The thing that the camera will follow if a manual position is not set.
		 */
    private var _target : Dynamic;
    
    /**
		 * The camera position to be set manually if target is not set.
		 */
    private var _manualPosition : Point;
    
    /**
		 * decides wether the camera will be updated by citrus engine.
		 * If you use the camera only for multi resolution purposes or for 'non moving' states,
		 * you may disable the camera to save some performances. In such cases, you may still call
		 * reset() in the state's initialize() so that the camera will set itself up at the right position/zoom/rotation.
		 */
    public var enabled : Bool = false;
    
    /**
		 * This defines the camera "center" position as a factor of the camera lens dimensions.
		 * x and y components will be multiplied to cameraLensWidth/cameraLensHeight
		 * to determine the position of the camera center.
		 * values must be between 0 and 1.
		 */
    public var center : Point = new Point(0.5, 0.5);
    
    /**
		 * real camera center position
		 */
    private var offset : Point = new Point();
    
    /**
		 * A value between 0 and 1 that specifies the speed at which the camera catches up to the target.
		 * 0 makes the camera not follow the target at all and 1 makes the camera follow the target exactly.
		 */
    public var easing : Point = new Point(0.25, 0.05);
    
    /**
		 * A rectangle specifying the minimum and maximum area that the camera is allowed to follow the target in. 
		 */
    public var bounds : Rectangle;
    
    /**
		 * defines a zone in the camera space where target will be able to move without the camera following it.
		 * left to its default value (0,0,0,0) the camera will constantly try to move/ease to the target.
		 * if set to 0,0,100,100, the target has to move 50px left or 50px right (in camera space) for horizontal tracking to start,
		 * the same vertically. 
		 * 
		 * the deadZone's rectangle x and y values are not used.
		 */
    public var deadZone : Rectangle = new Rectangle();
    
    /**
		 * The width of the visible game screen. This will usually be the same as your stage width unless your game has a border.
		 */
    public var cameraLensWidth : Float;
    
    public var followTarget : Bool = true;
    
    /**
		 * The height of the visible game screen. This will usually be the same as your stage width unless your game has a border.
		 */
    public var cameraLensHeight : Float;
    
    /**
		 * helper matrix for transformation
		 */
    private var _m : Matrix = new Matrix();
    
    /**
		 * helper point
		 */
    private var _p : Point = new Point();
    
    /**
		 * helper rectangle
		 */
    private var _r : Rectangle = new Rectangle();
    
    /**
		 * camera rectangle
		 */
    private var _rect : Rectangle = new Rectangle();
    
    /**
		 * helper object for bounds checking
		 */
    private var _b : Dynamic = {
            w2 : 0,
            h2 : 0,
            diag2 : 0,
            rotoffset : new Point(),
            br : 0,
            bl : 0,
            bt : 0,
            bb : 0
        };
    
    /**
		 * this mode will force the camera (and its 'content') to be contained within the bounds.
		 * zoom will be restricted - and recalculated if required.
		 * this restriction is based on the camera's AABB rectangle,you will never see anything out of the bounds.
		 * actually makes the camera 'hit' the bounds, the camera will be displaced to prevent it.
		 */
    public static inline var BOUNDS_MODE_AABB : String = "BOUNDS_MODE_AABB";
    
    /**
		 * this mode will force the offset point of the camera to stay within the bounds (whatever the zoom and rotation are)
		 * things can be seen outside of the bounds, but there's no zoom recalculation or camera displacement when rotating and colliding with the bounds 
		 * unlike the other mode.
		 */
    public static inline var BOUNDS_MODE_OFFSET : String = "BOUNDS_MODE_OFFSET";
    
    /**
		 * This mode is a mix of the two other modes :
		 * The camera offset point is now contained inside inner bounds  which allows to never see anything outside of the level
		 * like the AABB mode, but unlike the AABB mode, when rotating, the camera doesn't collide with borders as the inner bounds
		 * sides are distant from their correspoding bounds sides from the camera's half diagonal length :
		 * this means the camera can freely rotate in a circle, and that circle cannot go out of the defined bounds.
		 * this also means the corners of the bounded area will never be seen.
		 */
    public static inline var BOUNDS_MODE_ADVANCED : String = "BOUNDS_MODE_ADVANCED";
    
    /**
		 * how camera movement should be allowed within the defined bounds.
		 * defaults to ACitrusCamera.BOUNDS_MODE_AABB
		 */
    public var boundsMode : String = BOUNDS_MODE_AABB;
    
    /**
		 * the parallaxed objects are based on (0,0) of the level.
		 * this is how parallax has been applied since the beginning of CE.
		 */
    public static inline var PARALLAX_MODE_TOPLEFT : String = "PARALLAX_MODE_TOPLEFT";
    
    /**
		 * parallaxed objects are 'displaced' according to their parallax value from the center of the camera,
		 * giving a perspective/fake depth effect where the vanishing point is the center of the camera.
		 */
    public static inline var PARALLAX_MODE_DEPTH : String = "PARALLAX_MODE_DEPTH";
    
    /**
		 * defines the way parallax is applied to objects position.
		 * the default is PARALLAX_MODE_TOPLEFT.
		 */
    public var parallaxMode : String = PARALLAX_MODE_TOPLEFT;
    
    private var _ce : CitrusEngine;
    
    public function new(viewRoot : Dynamic)
    {
        _viewRoot = viewRoot;
        initialize();
    }
    
    /**
		 * Override this function to change the way camera lens dimensions are calculated 
		 * or to set other inital properties for the camera type.
		 */
    private function initialize() : Void {
        _ce = CitrusEngine.getInstance();
        cameraLensWidth = _ce.screenWidth;
        cameraLensHeight = _ce.screenHeight;
        
        _ce.onStageResize.add(onResize);
    }
    
    private function onResize(w : Float, h : Float) : Void {
        cameraLensWidth = _ce.screenWidth;
        cameraLensHeight = _ce.screenHeight;
    }
    
    /**
		 * This is a non-critical helper function that allows you to quickly set available camera properties in one place.
		 * if center and easing are set to null, the default values are used.
		 * @param target object with x and y properties that will be tracked by the camera
		 * @param center values between 0 and 1 - x/y components will be multiplied to the cameraLensWidth/cameraLensHeight value to determine the position of the camera center.
		 * @param bounds rectangle that determines the area the camera is allowed to move in
		 * @param easing values between 0 and 1 - that specifies by how much distance from the target the camera should move on each update
		 * @return this The Instance of the ACitrusCamera.
		 */
    public function setUp(target : Dynamic, bounds : Rectangle = null, center : Point = null, easing : Point = null) : ACitrusCamera
    {
        if (target != null)
        {
            this.target = target;
            _ghostTarget.x = target.x;
            _ghostTarget.y = target.y;
        }
        if (center != null)
        {
            if (center.x > 1){
                center.x = 1;
            }
            if (center.x < 0){
                center.x = 0;
            }
            if (center.y > 1){
                center.y = 1;
            }
            if (center.y < 0){
                center.y = 0;
            }
            
            this.center = center;
        }
        if (bounds != null)
        {
            this.bounds = bounds;
        }
        if (easing != null)
        {
            this.easing = easing;
        }
        
        enabled = true;
        return this;
    }
    
    /**
		 * sets camera transformation with no easing
		 * by setting all easing values to 1 temporarily and updating camera once.
		 * can be called at the beginning of a state to prevent camera effects then.
		 */
    public function reset() : Void {
        var tmp1 : Point = easing.clone();
        var tmp2 : Float = rotationEasing;
        var tmp3 : Float = zoomEasing;
        
        rotationEasing = 1;
        zoomEasing = 1;
        easing.setTo(1, 1);
        
        update();
        
        easing.copyFrom(tmp1);
        rotationEasing = tmp2;
        zoomEasing = tmp3;
    }
    
    /**
		 * Moves from the current target to the newTarget at a linear speed, sets the camera's target to be the newTarget
		 * then calls onComplete.
		 * @param	newTarget any object with x/y properties
		 * @param	speed by how much should the camera move towards the new target on each frame?
		 * @param	onComplete
		 */
    /*public function switchToTarget(newTarget : Dynamic, speed : Float = 10, onComplete : Function = null) : Void {
        var moveTarget : Point = new Point(camPos.x, camPos.y);
        var vec : MathVector = new MathVector(0, 0);
        
        var oldEasing : Point = easing.clone();
        easing.setTo(1, 1);
        
        var oldDeadZone : Rectangle = deadZone.clone();
        deadZone.setTo(0, 0, 0, 0);
        
        target = moveTarget;
        
        var switchTo : Function = function(e : Event) : Void
        {
            if (!_ce.playing){
                return;
            }
            
            vec.setTo(newTarget.x - moveTarget.x, newTarget.y - moveTarget.y);
            if (vec.length > speed){
                vec.length = speed;
            }
            moveTarget.x += vec.x;
            moveTarget.y += vec.y;
            
            if (MathUtils.DistanceBetweenTwoPoints(newTarget.x, moveTarget.x, newTarget.y, moveTarget.y) <= 0.1){
                _ce.removeEventListener(Event.ENTER_FRAME, arguments.callee);
                target = newTarget;
                easing = oldEasing;
                deadZone = oldDeadZone;
                if (onComplete != null)
                {
                    onComplete();
                }
            }
        }
        
        _ce.addEventListener(Event.ENTER_FRAME, switchTo);
    }*/
    
    /**
		 * Moves from current target to newTarget using EazeTween.
		 * function returns the EazeTween instance created.
		 * @param	newTarget any object with x/y properties
		 * @param	duration in seconds
		 * @param	easingFunction with the f(x) = y format
		 * @param	onComplete callback when the tween ends
		 * @return  EazeTween
		 */
    /*public function tweenSwitchToTarget(newTarget:Object, duration:Number = 2, easingFunction:Function = null, onComplete:Function = null):EazeTween
		{
			var moveTarget:Point = new Point(camPos.x,camPos.y);
			
			var oldEasing:Point = easing.clone();
			easing.setTo(1, 1);
			
			var oldDeadZone:Rectangle = deadZone.clone();
			deadZone.setTo(0, 0, 0, 0);
			
			target = moveTarget;
			
			var eaze:EazeTween = new EazeTween(moveTarget, false).to(duration, { x:newTarget.x, y:newTarget.y } ).onComplete(function():void{
				target = newTarget;
				easing = oldEasing;
				deadZone = oldDeadZone;
				if (onComplete != null)
					onComplete();
			});
			
			if (easingFunction != null)
				eaze.easing(easingFunction);
				
			eaze.start();
			return eaze;
		}
		*/
    public function zoom(factor : Float) : Void {
        throw (new Error("Warning: " + this + " cannot zoom."));
    }
    
    /**
		 * fits a defined area within the camera lens dimensions.
		 * Similar to fitting a rectangle inside another rectangle by multiplying its size,
		 * therefore keeping its aspect ratio. the factor used to fit is returned 
		 * and set as the current target zoom factor.
		 * 
		 * if storeInBaseZoom is set to true, then the calculated ratio is stored in the camera's baseZoom
		 * and from now, all zoom will be relative to that ratio (baseZoom is 1 by default and multiplied
		 * to every zoom operations you do using the camera methods) - this helps create relative zoom effects
		 * while keeping a base zoom when zooming at 1 where the camera would still fit the area you decided :
		 * specially usefull for multi resolution handling.
		 * @param width width of the area to fit inside the camera lens dimensions.
		 * @param height height of the area to fit inside the camera lens dimensions.
		 * @param storeInBaseZoom , whether to store the ratio into baseZoom or not.
		 * @return calculated zoom ratio
		 */
    public function zoomFit(width : Float, height : Float, storeInBaseZoom : Bool = false) : Float
    {
        throw (new Error("Warning: " + this + " cannot zoomFit."));
    }
    
    public function rotate(angle : Float) : Void {
        throw (new Error("Warning: " + this + " cannot rotate."));
    }
    
    public function setRotation(angle : Float) : Void {
        throw (new Error("Warning: " + this + " cannot rotate."));
    }
    
    public function setZoom(factor : Float) : Void {
        throw (new Error("Warning: " + this + " cannot zoom."));
    }
    
    public function getZoom() : Float
    {
        throw (new Error("Warning: " + this + " cannot zoom."));
    }
    
    public function getRotation() : Float
    {
        throw (new Error("Warning: " + this + " cannot rotate."));
    }
    
    /**
		 * Update the camera.
		 */
    public function update() : Void {
    }
    
    public function destroy() : Void {
        _ce.onStageResize.remove(onResize);
    }
    
    /*
		 * Getters and setters
		 */
    
    /**
		 * object with x and y properties that will be tracked by the camera
		 */
   public function set_target(o : Dynamic) : Dynamic
    {
        _manualPosition = null;
        _target = o;
        return o;
    }
   public function get_target() : Dynamic
    {
        return _target;
    }
    
    /**
		 * the camera center position in state coordinates
		 */
   public function get_camPos() : Point
    {
        return _camPos;
    }
    
   public function set_manualPosition(p : Point) : Point
    {
        _target = null;
        _manualPosition = p;
        return p;
    }
    
   public function get_manualPosition() : Point
    {
        return _manualPosition;
    }
    
   public function set_allowRotation(value : Bool) : Bool {
        throw (new Error("Warning: " + this + " cannot rotate."));
        return value;
    }
    
   public function set_allowZoom(value : Bool) : Bool {
        throw (new Error("Warning: " + this + " cannot zoom."));
        return value;
    }
    
   public function get_allowZoom() : Bool {
        throw (new Error("Warning: " + this + " cannot zoom."));
    }
    
   public function get_allowRotation() : Bool {
        throw (new Error("Warning: " + this + " cannot rotate."));
    }
    
    /**
		 * camProxy is read only.
		 * contains the data to be applied to container layers (_viewRoot and debug views).
		 */
   public function get_camProxy() : Dynamic
    {
        return _camProxy;
    }
    
    /**
		 * read-only to get the eased position of the target, which is the actual point the camera
		 * is looking at ( - the offset )
		 */
   public function get_ghostTarget() : Point
    {
        return _ghostTarget;
    }
    
    /**
		 * zoom with base factor
		 */
   public function get_mzoom() : Float
    {
        return _zoom * baseZoom;
    }
    
   public function set_mzoom(val : Float) : Float
    {
        _zoom = val / baseZoom;
        return val;
    }
    
    /**
		 * This is the transform matrix the camera applies to the state viewroot.
		 * it is also applied to the physics debug view.
		 */
   public function get_transformMatrix() : Matrix
    {
        return _m;
    }
    
    /**
		 * Check is the given coordinates in State space are contained within the camera.
		 * 
		 * set the area argument to define a different area of the screen, for example if you want to check
		 * further left/right/up/down than the camera's default rectangle which is : (0,0,cameraLensWidth,cameraLensHeight)
		 */
    public function contains(xa : Float, ya : Float, area : Rectangle = null) : Bool {
        _p.setTo(xa, ya);
        
        if (area == null)
        {
            _rect.setTo(0, 0, cameraLensWidth, cameraLensHeight);
        }
        else
        {
            _rect.copyFrom(area);
        }
        
        _p.copyFrom(_m.transformPoint(_p));
        
        return _rect.contains(_p.x, _p.y);
    }
    
    /**
		 * Check is the given rectangle is fully contained within the camera.
		 * will return false even if partially visible, collision with borders included.
		 * 
		 * The rectangle *must* be in the same space as the camera's rectangle, this means in the starling stage if in a StarlingState,
		 * or the flash native stage if in a normal State.
		 * 
		 * set the area argument to define a different area of the screen, for example if you want to check
		 * further left/right/up/down than the camera's default rectangle which is : (0,0,cameraLensWidth,cameraLensHeight)
		 */
    public function containsRect(rectangle : Rectangle, area : Rectangle = null) : Bool {
        _p.setTo(rectangle.x + rectangle.width * .5, rectangle.y + rectangle.height * .5);
        
        if (area == null)
        {
            _rect.setTo(0, 0, cameraLensWidth, cameraLensHeight);
        }
        else
        {
            _rect.copyFrom(area);
        }
        
        _r.setTo(_p.x - rectangle.width * .5, _p.y - rectangle.height * .5, rectangle.width, rectangle.height);
        return _rect.containsRect(_r);
    }
    
    /**
		 * Check is the given rectangle intersects with the camera rectangle.
		 * (if its partially visible, true will be returned.
		 * 
		 * The rectangle *must* be in the same space as the camera's rectangle, this means in the starling stage if in a StarlingState,
		 * or the flash native stage if in a normal State.
		 * 
		 * set the area argument to define a different area of the screen, for example if you want to check
		 * further left/right/up/down than the camera's default rectangle which is : (0,0,cameraLensWidth,cameraLensHeight)
		 */
    public function intersectsRect(rectangle : Rectangle, area : Rectangle = null) : Bool {
        _p.setTo(rectangle.x + rectangle.width * .5, rectangle.y + rectangle.height * .5);
        
        if (area == null)
        {
            _rect.setTo(0, 0, cameraLensWidth, cameraLensHeight);
        }
        else
        {
            _rect.copyFrom(area);
        }
        
        _r.setTo(_p.x - rectangle.width * .5, _p.y - rectangle.height * .5, rectangle.width, rectangle.height);
        return _rect.intersects(_r);
    }
    
    /**
		 * returns the camera's axis aligned bounding rectangle in State space.
		 */
    public function getRect() : Rectangle
    {
        return _aabbData.rect;
    }
}

