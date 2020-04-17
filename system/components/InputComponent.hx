package citrus.system.components;

import citrus.system.Component;
import kaleidoEngine.data.dataType.Boolean;

/**
	 * An input component, it will inform if the key is down, just pressed or just released.
	 */
class InputComponent extends Component
{
    
    public var isDoingRight : Bool = false;
    public var isDoingLeft : Bool = false;
    public var isDoingDuck : Bool = false;
    public var isDoingJump : Bool = false;
    public var justDidJump : Bool = false;
    
    public function new(name : String, params : Dynamic = null)
    {
        super(name, params);
    }
    
    override public function update(timeDelta : Float) : Void {
        super.update(timeDelta);
       
        isDoingRight = Boolean.isTrue(_ce.input.isDoing("right"));
        isDoingLeft = Boolean.isTrue(_ce.input.isDoing("left"));
        isDoingDuck =  Boolean.isTrue(_ce.input.isDoing("duck"));
        isDoingJump =  Boolean.isTrue(_ce.input.isDoing("jump"));
        justDidJump =  Boolean.isTrue(_ce.input.justDid("jump"));
    }
	
	
}

