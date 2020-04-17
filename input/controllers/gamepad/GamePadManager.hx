package citrus.input.controllers.gamepad;


import citrus.input.controllers.gamepad.maps.CSLSnesMap;
import citrus.input.controllers.gamepad.maps.FreeboxGamepadMap;
import citrus.input.controllers.gamepad.maps.GamepadMap;
import citrus.input.controllers.gamepad.maps.JoyConDual;
import citrus.input.controllers.gamepad.maps.JoyConDual;
import citrus.input.controllers.gamepad.maps.JoyConLeft;
import citrus.input.controllers.gamepad.maps.JoyConRight;
import citrus.input.controllers.gamepad.maps.OUYAGamepadMap;
import citrus.input.controllers.gamepad.maps.PS3GamepadMap;
import citrus.input.controllers.gamepad.maps.Xbox360GamepadMap;
import citrus.input.InputController;
import kaleidoEngine.data.utils.object.ArraySortFunctions;
import kaleidoEngine.data.utils.object.Objects;
import flash.events.GameInputEvent;
import flash.ui.GameInput;
import flash.ui.GameInputDevice;
import flash.utils.Dictionary;
import kaleidoEngine.core.EngineVars;
import msignal.Signal;

class GamePadManager extends InputController
{
    public var defaultMap(get, never) : Class<Dynamic>;
    public var numGamePads(get, never) : Int;
    public var gamePads(get, never) : Dictionary<String,Gamepad>;

    private static var _gameInput : GameInput = new GameInput();
    
    /**
		 * key = substring in devices id/name to recognize
		 * value = map class
		 */
    public var devicesMapDictionary : Dictionary<String,Dynamic>;
    
 
    
    private var _gamePads : Dictionary<String,Gamepad>;
    //default map should extend GamePadMap, will be applied to each new device plugged in.
    private var _defaultMap : Class<Dynamic>;
    //maximum number of game input devices we can add (as gamepads)
    private var _maxPlayers : Int = 0;
    //last channel used (by the last device plugged in)
    private var _lastChannel : Int = 0;
    
    private static var _instance : GamePadManager;
    
    /**
		 * dispatches a newly created Gamepad object when a new GameInputDevice is added.
		 */
    public var onControllerAdded : Signal1<Gamepad>;
    /**
		 * dispatches the Gamepad object corresponding to the GameInputDevice that got removed.
		 */
    public var onControllerRemoved : Signal1<Gamepad>;
    
    public function new(defaultMap : Class<Dynamic> = null)
    {
        super("GamePadManager");

        if (!GameInput.isSupported)
        {
            trace(this, "GameInput is not supported.");
            return;
        }

        initdevicesMapDictionaryMaps();
        _defaultMap = defaultMap;
        
        _gamePads = new Dictionary<String,Gamepad>();
        
        onControllerAdded = new Signal1(Gamepad);
        onControllerRemoved = new Signal1(Gamepad);
        
        _gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, handleDeviceAdded);
        _gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, handleDeviceRemoved);
        

        
        _instance = this;
		
    }
    
    public function start() : Void {
		
        var numDevices : Int;
        if ((numDevices = GameInput.numDevices) > 0)
        {
            var i : Int = 0;
            var device : GameInputDevice;
            while (i < numDevices){
                device = GameInput.getDeviceAt(i);
               // trace("INITING.... GAMEPAD [" + i + "]=" + device);
                if (device != null){
                    _gameInput.dispatchEvent(new GameInputEvent(GameInputEvent.DEVICE_ADDED, false, false, device));
                 //   trace("ADDED GAMEPAD:" + device.name);
                } else{
                    trace(this, "tried to get a device at", i, "and it returned null. please reference or initialize the GamePadManager sooner in your app!");
                }
                i++;
            }
        }
    }
    
    public static function getInstance() : GamePadManager
    {
        return _instance;
    }
    
    
		//creates the dictionary for default game pad maps to apply.
		 // key = substring in GameInputDevice.name to look for,
		// value = GamePadMap class to use for mapping the game pad correctly.
		
    private function initdevicesMapDictionaryMaps() : Void {
		//trace("*******************INIT DEVICES DEFAULT MAPS!");
		
		
        devicesMapDictionary = new Dictionary<String,GamepadMap>();
        devicesMapDictionary["Microsoft X-Box 360"] = Xbox360GamepadMap;
     //   devicesMapDictionary["Xbox 360 Controller"] = Xbox360GamepadMap;
      //  devicesMapDictionary["PLAYSTATION"] = PS3GamepadMap;
      //  devicesMapDictionary["OUYA"] = OUYAGamepadMap;
      //  devicesMapDictionary["Generic   USB  Joystick"] = FreeboxGamepadMap;
        devicesMapDictionary["Joy-Con (Left)"] = JoyConLeft;
        devicesMapDictionary["Joy-Con (Right)"] = JoyConRight;
        devicesMapDictionary["Joy-Con (Dual)"] = JoyConDual;
        devicesMapDictionary["Switch Pro Controller compatible"] = GamepadMap;
		
      
    }
    
 
    private function applyMap(device : GameInputDevice, gp : Gamepad) : Void {
        var substr : String = "";
		for (substr in devicesMapDictionary) {
            if (device.name.indexOf(substr) > -1 || device.id.indexOf(substr) > -1){
                gp.useMap(devicesMapDictionary[substr]);
                return;
            }
        }
        if (EngineVars.devMode) {
          //  trace("[GamePadManager] No default map found in GamePadManager.devicesMapDictionary for", gp, ", trying to use defaultMap specified in the constructor.");
        }
        gp.useMap(_defaultMap);
    }
    
    
		 //* checks if device has a defined map in the devicesMapDictionary.
		
    public function isDeviceKnownGamePad(device : GameInputDevice) : Bool {
        var substr : String = "";
        for (substr in devicesMapDictionary)
        {
            if (device.name.indexOf(substr) > -1 || device.id.indexOf(substr) > -1){
                return true;
            }
        }
        return false;
    }
    
    
		//* return the first gamePad using the defined channel.
		
    public function getGamePadByChannel(channel : Int = 0) : Gamepad
    {
        
        for (pad in _gamePads)
        {
            if (_gamePads[pad].defaultChannel == channel){
                return _gamePads[pad];
            }
        }
        return null;
    }
    
    public function getGamePadAt(index : Int = 0) : Gamepad
    {
        var c : Int = 0;
        for (k in _gamePads)
        {
            if (c == index){
                return _gamePads[k];
            }
            c++;
        }
        return null;
    }
    
    private var numDevicesAdded : Int = 0;
    
    private function handleDeviceAdded(e : GameInputEvent) : Void  {
		//log("handleDeviceAdded(" + e.device.name+")");
        var device : GameInputDevice = e.device;
		addGamePadHandle(device);
        
    }
	
	public function addGamePadHandle(device : GameInputDevice) {
		var deviceID : String = device.id;
        var pad : Gamepad;
		
        if (_gamePads[deviceID]!=null){
            trace(deviceID, "already added");
        }
        
		log("____ADDING DEVICE NUM:" + numDevicesAdded);
        pad = new Gamepad("gamepad" + numDevicesAdded, device, null);
      
        //check if we know a map for this device and apply it.
        applyMap(device, pad);
        
        numDevicesAdded++;
		
		pad.defaultChannel = findFirstPossibleChannel();
		

		log ("ADDED GAME PAD:" + device.name +" to :" + pad.defaultChannel + "[npadid:"+pad.deviceNpadID+"] CURRENT USED GAMEPADS: "+numGamePads+"]");
        
        _gamePads[pad.toString()] = pad;
        onControllerAdded.dispatch(pad);
	}
	
	function findLastUsedChannel():Int {
		var last:Int = -1;
		
		for (id in _gamePads) {
			if (_gamePads[id].defaultChannel > last) {
				last = _gamePads[id].defaultChannel;
			}
		}
		
		return last;
	}
	public function findFirstPossibleChannel():Int {
		var arr:Array<Int> = new Array<Int>();
		
		for (id in _gamePads) {
			arr.push(_gamePads[id].defaultChannel);
		}
		
		//arr.sort(ArraySortFunctions.DESCENDING);
		var restart:Bool = true;
		
		var earliest:Int = 0;
		while (restart) {
			restart = false;	
			for (i in 0...arr.length) {
				if (arr[i] == earliest) {
					earliest++;
					restart = true;
				}
			}
		}
		log("USING CHANNEL:"+ earliest + " (CURRENT USED CHANNELS:" + arr+")");
		
		return earliest;

	}
    
    private function handleDeviceRemoved(e : GameInputEvent) : Void {
	 //  log("handleDeviceREMOVED(" + e.device.name+")");
      // numDevicesAdded--;
	   var pad : Gamepad = null;
	   var selectedID:String="";
        for (id in _gamePads){
            pad = _gamePads[id];
            if (pad.device == e.device){
				selectedID = id;
                break;
            }
        }
        
        if (pad == null){
            return;
        }
		
		log("REMOVE PAD FROM CHANNEL:" + pad.defaultChannel);
		_gamePads.remove(selectedID);
        pad.destroy();
        onControllerRemoved.dispatch(pad);
		
		
    }
	
	function log(string:String) {
		//	trace("[GAMEPAD MANAGER]" + string);
	}
    
    override public function destroy() : Void {
        _gameInput.removeEventListener(GameInputEvent.DEVICE_ADDED, handleDeviceAdded);
        _gameInput.removeEventListener(GameInputEvent.DEVICE_REMOVED, handleDeviceRemoved);
        
        var gp : Gamepad;
        for (name in _gamePads)
        {
            gp = _gamePads[name];
            gp.destroy();
            _gamePads[name] = null;
        }
        devicesMapDictionary = null;
        _defaultMap = null;
        onControllerAdded.removeAll();
        onControllerRemoved.removeAll();
        super.destroy();
    }
    
   public function get_defaultMap() : Class<Dynamic>
    {
        return _defaultMap;
    }
    
   public function get_numGamePads() : Int
    {
        var count : Int = 0;
        for (k in _gamePads)
        {
            count++;
        }
        return count;
    }
	
	function get_gamePads():Dictionary<String,Gamepad> {
		return _gamePads;
	}
    
    public static inline var GAMEPAD_ADDED_ACTION : String = "GAMEPAD_ADDED_ACTION";
    public static inline var GAMEPAD_REMOVED_ACTION : String = "GAMEPAD_REMOVED_ACTION";
}

