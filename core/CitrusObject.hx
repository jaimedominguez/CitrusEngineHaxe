package citrus.core;

import kaleidoEngine.data.dataType.Boolean;
import kaleidoEngine.debug.InObject;

import flash.errors.Error;

/**
	 * CitrusObject is simple. Too simple. Despite its simplicity, it is the foundational object that should
	 * be used for all game objects logic you create, such as spaceships, enemies, coins, bosses.
	 * CitrusObject is basically an abstract class that gets added to a State instance.
	 * The current State calls update on all CitrusObjects. Also, CitrusObjects are useful because they can be
	 * initialized with a params object, which can be created via an object parser/factory. 
	 */
class CitrusObject
{
    public var ID : Int;

    /**
		 * data used internally
		 */
    
    private var data : Dynamic = {
            ID : 0
        };
    private static var last_id : Int = 0;
    
    public var hideParamWarnings : Bool = false;
    
    /**
		 * A name to identify easily an objet. You may use duplicate name if you wish.
		 */
    public var name : String;
    
    /**
		 * Set it to true if you want to remove, clean and destroy the object. 
		 */
    public var kill : Bool = false;
   
    
    /**
		 * This property prevent the <code>update</code> method to be called by the enter frame, it will save performances. 
		 * Set it to true if you want to execute code in the <code>update</code> method.
		 */
    public var updateCallEnabled : Bool = false;
    
    /**
		 * Added to the CE's render list via the State and the add method.
		 */
    public var type : String = "classicObject";
    
    public var _initialized : Bool = false;
    private var _ce : CitrusEngine;
    
    private var _params : Dynamic;
    
    /**
		 * The time elasped between two update call.
		 */
    private var _timeDelta : Float;
    
    /**
		 * Every Citrus Object needs a name. It helps if it's unique, but it won't blow up if it's not.
		 * Also, you can pass parameters into the constructor as well. Hopefully you'll commonly be
		 * creating CitrusObjects via an editor, which will parse your shit and create the params object for you. 
		 * @param name Name your object.
		 * @param params Any public properties or setters can be assigned values via this object.
		 * 
		 */
    public function new(name : String, params : Dynamic = null)
    {
        this.name = name;

        _ce = CitrusEngine.getInstance();
        _params = params;

        if (params != null) {
            if (type == "classicObject" && Reflect.field(params, "type") == null)  {
                initialize();
            }
        } else  {
            initialize();
        }
        

		ID = data.ID = last_id += 1;
		
    }
    
    /**
		 * Call in the constructor if the Object is added via the State and the add method.
		 * <p>If it's a pool object or an entity initialize it yourself.</p>
		 * <p>If it's a component, it should be call by the entity.</p>
		 */
    public function initialize(poolObjectParams : Dynamic = null) : Void {
		
        if (poolObjectParams != null) {
            _params = poolObjectParams;
        }
      
        if (_params != null){
			
            setParams(_params);
		
        } else {
		
            _initialized = true;
        }
		
    }
    
    /**
		 * Seriously, dont' forget to release your listeners, signals, and physics objects here. Either that or don't ever destroy anything.
		 * Your choice.
		 */
    public function destroy() : Void {
		
		kill = true;
		updateCallEnabled = false;
		
        data = null;
        _initialized = false;
		_ce = null;
		_params = null;
		
		//if (InObject.extractValids(this)){
       //
        //}
           
    }
    
    /**
		 * The current state calls update every tick. This is where all your per-frame logic should go. Set velocities, 
		 * determine animations, change properties, etc. 
		 * @param timeDelta This is a ratio explaining the amount of time that passed in relation to the amount of time that
		 * was supposed to pass. Multiply your stuff by this value to keep your speeds consistent no matter the frame rate. 
		 */
    public function update(timeDelta : Float) : Void {
        _timeDelta = timeDelta;
    }
    
	private function setParams(params : Dynamic) : Void {
		
        for (paramKey in Reflect.fields(params)) {
          var paramValue:Dynamic = Reflect.field(params, paramKey);
		  
			if ( paramValue == "true" || paramValue=="false"){
			
				Reflect.setProperty(this, paramKey, Boolean.isTrue(paramValue));
			}else{
				//trace("PARAM [" + paramKey + "] = " + Reflect.field(params, paramKey));
				Reflect.setProperty(this, paramKey, Reflect.field(params, paramKey));
			}
			
		
        }
	
		_initialized = true;
		
		
    }
	
    public function getString() : String {
	     return "Citrus_Object_ID_" + ID;
      }

	
	public function exists(paramName:String):Bool {
		 return Reflect.hasField(this, paramName);
	}
}
