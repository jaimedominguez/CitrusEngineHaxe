package citrus.input.controllers.starling;

import citrus.input.InputController;
import citrus.view.starlingview.StarlingView;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

/**
	 * ScreenTouch is a small InputController to get a starling touch into the input system :
	 * the common use case is if you want your hero to react on the touch of a screen and handle that
	 * in the hero's update loop without having to change your code, for example having ScreenTouch with
	 * "jump" for touchAction, let's you touch the touchTarget(the state by default) and make your Hero jump
	 * with no changes to Hero's code as it will respond to justDid("jump").
	 */
class ScreenTouch extends InputController
{
    public var touchTarget(get, set) : DisplayObject;

    
    private var _touchTarget : DisplayObject;
    /**
		 * touch action is the action triggered on touch, it is jump by default.
		 */
    public var touchAction : String = "jump";
    
    public function new(name : String, params : Dynamic = null)
    {
        super(name, params);
        
        if (_touchTarget == null)
        {
            _touchTarget = (try cast((try cast(_ce.state.view, StarlingView) catch(e:Dynamic) null).viewRoot, Sprite) catch(e:Dynamic) null);
        }
        
        _touchTarget.addEventListener(TouchEvent.TOUCH, _handleTouch);
    }
    
    private function _handleTouch(e : TouchEvent) : Void {
        var t : Touch = e.getTouch(_touchTarget);
        if (t != null)
        {
            var _sw0_ = (t.phase);            

            switch (_sw0_){
                
                case TouchPhase.BEGAN:
                    triggerCHANGE(touchAction, 1, null, defaultChannel);
                    e.stopImmediatePropagation();
                case TouchPhase.ENDED:
                    triggerOFF(touchAction, 0, null, defaultChannel);
                    e.stopImmediatePropagation();
            }
        }
    }
    
    override public function destroy() : Void {
        _touchTarget.removeEventListener(TouchEvent.TOUCH, _handleTouch);
        _touchTarget = null;
        super.destroy();
    }
    
    /**
		 * By default, the touchTarget will be set to the state's viewroot,
		 * accessible from the state like so:
		 * <pre>((view as StarlingView).viewRoot as Sprite)</pre>
		 */
   public function get_touchTarget() : DisplayObject
    {
        return _touchTarget;
    }
    
   public function set_touchTarget(s : DisplayObject) : DisplayObject
    {
        if (s != _touchTarget)
        {
            _touchTarget.removeEventListener(TouchEvent.TOUCH, _handleTouch);
            s.addEventListener(TouchEvent.TOUCH, _handleTouch);
            _touchTarget = s;
        }
        return s;
    }
}
