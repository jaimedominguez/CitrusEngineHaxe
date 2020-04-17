package citrus.input.controllers.displaylist;

import citrus.input.controllers.AVirtualButton;
import flash.display.Sprite;
import flash.events.MouseEvent;

class VirtualButton extends AVirtualButton
{
    public var graphic : Sprite;  //main Sprite container.  
    
    private var button : Sprite;
    
    public var buttonUpGraphic : Sprite;
    public var buttonDownGraphic : Sprite;
    
    public function new(name : String, params : Dynamic = null)
    {
        graphic = new Sprite();
        super(name, params);
        _x = (_x) ? _x : _ce.stage.stageWidth - (_margin + 3 * _buttonradius);
        _y = (_y) ? _y : _ce.stage.stageHeight - 3 * _buttonradius;
        
        initGraphics();
    }
    
    override private function initGraphics() : Void {
        button = new Sprite();
        
        if (buttonUpGraphic == null)
        {
            buttonUpGraphic = new Sprite();
            buttonUpGraphic.graphics.beginFill(0x000000, 0.1);
            buttonUpGraphic.graphics.drawCircle(0, 0, _buttonradius);
            buttonUpGraphic.graphics.endFill();
        }
        
        if (buttonDownGraphic == null)
        {
            buttonDownGraphic = new Sprite();
            buttonDownGraphic.graphics.beginFill(0xEE0000, 0.85);
            buttonDownGraphic.graphics.drawCircle(0, 0, _buttonradius);
            buttonDownGraphic.graphics.endFill();
        }
        
        button.addChild(buttonUpGraphic);
        
        graphic.addChild(button);
        
        graphic.x = _x;
        graphic.y = _y;
        
        //Add graphic
        _ce.stage.addChild(graphic);
        
        //MOUSE EVENTS
        
        graphic.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvent);
        graphic.addEventListener(MouseEvent.MOUSE_UP, handleMouseEvent);
    }
    
    private function handleMouseEvent(e : MouseEvent) : Void {
        if (e.type == MouseEvent.MOUSE_DOWN && button == e.target.parent)
        {
            triggerON(buttonAction, 1, null, buttonChannel);
            button.removeChildAt(0);
            button.addChild(buttonDownGraphic);
            
            _ce.stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseEvent);
        }
        
        if (e.type == MouseEvent.MOUSE_UP && button == e.target.parent)
        {
            triggerOFF(buttonAction, 0, null, buttonChannel);
            button.removeChildAt(0);
            button.addChild(buttonUpGraphic);
            
            _ce.stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseEvent);
        }
    }
    
    overridepublic function get_visible() : Bool {
        return _visible = graphic.visible;
    }
    
    overridepublic function set_visible(value : Bool) : Bool {
        _visible = graphic.visible = value;
        return value;
    }
    
    override public function destroy() : Void
    //remove mouse events.
    {
        
        graphic.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvent);
        graphic.removeEventListener(MouseEvent.MOUSE_UP, handleMouseEvent);
        
        //remove graphic
        _ce.stage.removeChild(graphic);
    }
}

