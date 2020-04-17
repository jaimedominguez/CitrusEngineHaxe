package citrus.sounds;

import citrus.core.CitrusObject;
import citrus.view.ACitrusCamera;
import citrus.view.ICitrusArt;
import citrus.view.ISpriteView;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
	 * Experimental spatial sound system
	 */
class CitrusSoundSpace extends CitrusObject implements ISpriteView
{
    public var soundManager(get, never) : SoundManager;
    public var view(get, set) : Dynamic;
    public var x(get, never) : Float;
    public var y(get, never) : Float;
    public var z(get, never) : Float;
    public var width(get, never) : Float;
    public var height(get, never) : Float;
    public var depth(get, never) : Float;
    public var velocity(get, never) : Array<Dynamic>;
    public var parallaxX(get, never) : Float;
    public var parallaxY(get, never) : Float;
    public var rotation(get, never) : Float;
    public var group(get, set) : Int;
    public var visible(get, set) : Bool;
    public var touchable(get, set) : Bool;
    public var animation(get, never) : String;
    public var inverted(get, never) : Bool;
    public var offsetX(get, never) : Float;
    public var offsetY(get, never) : Float;
    public var registration(get, never) : String;

    private var _visible : Bool = false;
    private var _touchable : Bool = false;
    private var _group : Int = 1;
    private var _view : Dynamic;
    private var _realDebugView : Dynamic;
    
    private var _debugArt : CitrusSoundDebugArt;
    private var _objects : Array<CitrusSoundObject>;
    private var _soundManager : SoundManager;
    private var _camera : ACitrusCamera;
    
    public var drawRadius : Bool = false;
    public var drawObject : Bool = true;
    
    public function new(name : String, params : Dynamic = null)
    {
        super(name, params);
        updateCallEnabled = true;
        touchable = false;
        _soundManager = _ce.soundMng;
        _objects = new Array<CitrusSoundObject>();
        
        updateCameraProperties();
    }
    
    public function add(citrusSoundObject : CitrusSoundObject) : Void {
        _objects.push(citrusSoundObject);
        updateObject(citrusSoundObject);
        citrusSoundObject.initialize();
    }
    
    public function remove(citrusSoundObject : CitrusSoundObject) : Void {
        var i : Int = Lambda.indexOf(_objects, citrusSoundObject);
        if (i > -1)
        {
            _objects.splice(i, 1);
        }
    }
    
    private var camCenter : Point = new Point();
    private var camRect : Rectangle = new Rectangle();
    private var camRotation : Float = 0;
    
    private function updateCameraProperties() : Void {
        _camera = _ce.state.view.camera;
        camRect.copyFrom(_camera.getRect());
        camCenter.setTo(camRect.x + camRect.width * 0.5, camRect.y + camRect.height * 0.5);
        camRotation = _camera.getRotation();
    }
    
    override public function update(timeDelta : Float) : Void {
        super.update(timeDelta);
        
        updateCameraProperties();
        
        if (_visible)
        {
            _debugArt.graphics.clear();
        }
        
        var object : CitrusSoundObject;
        for (object in _objects)
        {
            updateObject(object);
            
            if (_visible){
                if (drawObject)
                {
                    _debugArt.graphics.lineStyle(0.1, 0xFF0000, 0.8);
                    _debugArt.graphics.drawCircle(object.citrusObject.x, object.citrusObject.y, 1 + 120 * object.totalVolume);
                }
                if (drawRadius)
                {
                    _debugArt.graphics.lineStyle(0.5, 0x00FF00, 0.8);
                    _debugArt.graphics.drawCircle(object.citrusObject.x, object.citrusObject.y, object.radius);
                }
            }
        }
        
        if (_visible)
        {
            var m : Matrix = _debugArt.transform.matrix;
            m.copyFrom(_camera.transformMatrix);
            m.concat(_ce.transformMatrix);
            _debugArt.transform.matrix = m;
        }
    }
    
    private function updateObject(object : CitrusSoundObject) : Void {
        if (_camera != null)
        {
            object.camVec.setTo(object.citrusObject.x - camCenter.x, object.citrusObject.y - camCenter.y);
            object.camVec.angle += camRotation;
            object.rect.width = _camera.cameraLensWidth;
            object.rect.height = _camera.camProxy.scale;
        }
        object.update();
    }
    
    override public function destroy() : Void {
        visible = false;
        _camera = null;
        _soundManager = null;
        as3hx.Compat.setArrayLength(_objects, 0);
        super.destroy();
    }
    
   public function get_soundManager() : SoundManager
    {
        return _soundManager;
    }
    
    public function getBody() : Dynamic
    {
        return null;
    }
    
   public function get_view() : Dynamic
    {
        return _view;
    }
    
   public function set_view(value : Dynamic) : Dynamic
    {
        _view = value;
        return value;
    }
    
   public function get_x() : Float
    {
        return 0;
    }
    
   public function get_y() : Float
    {
        return 0;
    }
    
   public function get_z() : Float
    {
        return 0;
    }
    
   public function get_width() : Float
    {
        return 0;
    }
    
   public function get_height() : Float
    {
        return 0;
    }
    
   public function get_depth() : Float
    {
        return 0;
    }
    
   public function get_velocity() : Array<Dynamic>
    {
        return null;
    }
    
   public function get_parallaxX() : Float
    {
        return 1;
    }
    
   public function get_parallaxY() : Float
    {
        return 1;
    }
    
   public function get_rotation() : Float
    {
        return 0;
    }
    
   public function get_group() : Int
    {
        return _group;
    }
    
   public function set_group(value : Int) : Int
    {
        _group = value;
        return value;
    }
    
   public function get_visible() : Bool {
        return _visible;
    }
    
   public function set_visible(value : Bool) : Bool {
        if (value == _visible)
        {
            return value;
        }
        
        if (value)
        {
            _debugArt = new CitrusSoundDebugArt();
            _ce.stage.addChild(_debugArt);
        }
        else if (_debugArt != null)
        {
            _debugArt.destroy();
            _ce.stage.removeChild(_debugArt);
        }
        
        _visible = value;
        return value;
    }
    
   public function get_touchable() : Bool {
        return _touchable;
    }
    
   public function set_touchable(value : Bool) : Bool {
        _touchable = value;
        return value;
    }
    
   public function get_animation() : String
    {
        return "";
    }
    
   public function get_inverted() : Bool {
        return false;
    }
    
   public function get_offsetX() : Float
    {
        return 0;
    }
    
   public function get_offsetY() : Float
    {
        return 0;
    }
    
   public function get_registration() : String
    {
        return "topLeft";
    }
    
    public function handleArtReady(citrusArt : ICitrusArt) : Void {
    }
    
    public function handleArtChanged(citrusArt : ICitrusArt) : Void {
    }
}

