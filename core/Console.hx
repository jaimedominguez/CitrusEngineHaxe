package citrus.core;

import flash.errors.ArgumentError;
import haxe.Constraints.Function;
import msignal.Signal;
//import hx.event.Signal;

//import org.osflash.signals.Signal;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.net.SharedObject;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import flash.utils.Dictionary;


/**
	 * You can use the console to perform any type of command at your game's runtime. Press the key that opens it, then type a
	 * command into the console, then press enter. If your command is recognized, the command's handler function will fire.
	 * 
	 * <p>You can create your own console commands by using the <code>addCommand</code> method.</p>
	 * 
	 * <p>When the console is open, it does not disable game input. You can manually toggle game input by listening for
	 * the <code>onShowConsole</code> and <code>onHideConsole</code> Signals.</p>
	 * 
	 * <p>When the console is open, you can press the up key to step backwards through your executed command history, 
	 * even after you've closed your SWF. Pressing the down key will step forward through your history.
	 * Use this to quickly access commonly executed commands.</p>
	 * 
	 * <p>Each command follows this pattern: <code>commandName param1 param2 param3...</code>. First, you call the 
	 * command name that you want to execute, then you pass any parameters into the command. For instance, you can
	 * set the jumpHeight property on a Hero object using the following command: "set myHero jumpHeight 20". That
	 * command finds an object named "myHero" and sets its jumpHeight property to 20.</p>
	 * 
	 * <p>Make sure and see the <code>addCommand</code> definition to learn how to add your own console commands.</p>
	 */
class Console extends Sprite
{
    public var onShowConsole(get, never) : Signal0;
    public var onHideConsole(get, never) : Signal0;
    public var enabled(get, set) : Bool;

    /**
		 * Default is tab key.
		 */
    public var openKey : Int = 9;
    
    private var _inputField : TextField;
    private var _executeKey : Int;
    private var _prevHistoryKey : Int;
    private var _nextHistoryKey : Int;
    private var _commandHistory : Array<Dynamic>;
    private var _historyMax : Float;
    private var _showing : Bool;
    private var _currHistoryIndex : Int;
    private var _commandDelegates : Dictionary<String,Dynamic>;
   

    private var _numCommandsInHistory : Float;
    private var _shared : SharedObject;
    private var _enabled : Bool = true;
    
    //events
    private var _onShowConsole : Signal0;
    private var _onHideConsole : Signal0;
    
    /**
		 * Creates the instance of the console. This is a display object, so it is also added to the stage. 
		 */
    public function new(openKey : Int = 9)
    {
        super();
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        
        _shared = SharedObject.getLocal("history");
        
        this.openKey = openKey;
        _executeKey = Keyboard.ENTER;
        _prevHistoryKey = Keyboard.UP;
        _nextHistoryKey = Keyboard.DOWN;
        _historyMax = 25;
        _showing = false;
        _currHistoryIndex = 0;
        _numCommandsInHistory = 0;
        
        if (_shared.data.history)
        {
            _commandHistory = cast(_shared.data.history, Array<Dynamic>);
            _numCommandsInHistory = _commandHistory.length;
        }
        else
        {
            _commandHistory = new Array<Dynamic>();
            _shared.data.history = _commandHistory;
        }
       // _commandDelegates = new Map<String, Dynamic>();
        _commandDelegates = new Dictionary<String,Dynamic>();
        
        _inputField = try cast(addChild(new TextField()), TextField) catch(e:Dynamic) null;
        _inputField.type = TextFieldType.INPUT;
        _inputField.addEventListener(FocusEvent.FOCUS_OUT, onConsoleFocusOut);
        _inputField.defaultTextFormat = new TextFormat("_sans", 14, 0xFFFFFF, false, false, false);
        
        visible = false;
        
        _onShowConsole = new Signal0();
        _onHideConsole = new Signal0();
    }
    
    public function destroy() : Void {
        stage.removeEventListener(KeyboardEvent.KEY_UP, onToggleKeyPress);
        
        _onShowConsole.removeAll();
        _onHideConsole.removeAll();
    }
    
    /**
		 * Gets dispatched when the console is shown. Handler accepts 0 params.
		 */
   public function get_onShowConsole() : Signal0
    {
        return _onShowConsole;
    }
    
    /**
		 * Gets dispatched when the console is hidden. Handler accepts 0 params.
		 */
   public function get_onHideConsole() : Signal0
    {
        return _onHideConsole;
    }
    
    /**
		 * Determines whether the console can be used. Set this property to false before releasing your final game. 
		 */
   public function get_enabled() : Bool {
        return _enabled;
    }
    
   public function set_enabled(value : Bool) : Bool {
        if (_enabled == value)
        {
            return value;
        }
        
        _enabled = value;
        
        if (_enabled)
        {
            stage.addEventListener(KeyboardEvent.KEY_UP, onToggleKeyPress);
        }
        else
        {
            stage.removeEventListener(KeyboardEvent.KEY_UP, onToggleKeyPress);
            hideConsole();
        }
        return value;
    }
    
    /**
		 * Can be called to clear the command history. 
		 */
    public function clearStoredHistory() : Void {
        _shared.clear();
    }
    
    /**
		 * Adds a command to the console. Use this method to create your own commands. The <code>name</code> parameter
		 * is the word that you must type into the console to fire the command handler. The <code>func</code> parameter
		 * is the function that will fire when the console command is executed.
		 * 
		 * <p>Your command handler should accept the parameters that are expected to be passed into the command. All
		 * of them should be typed as a String. As an example, this is a valid handler definition for the "set" command.</p>
		 * 
		 * <p><code>private function handleSetPropertyCommand(objectName:String, propertyName:String, propertyValue:String):void</code></p>
		 * 
		 * <p>You can then create logic for your command using the arguments.</p>
		 *  
		 * @param name The word you want to use to execute your command in the console.
		 * @param func The handler function that will get called when the command is executed. This function should accept the commands parameters as arguments.
		 * 
		 */
    public function addCommand(name : String, func : Function) : Void {
        Reflect.setField(_commandDelegates, name, func);
    }
    
    public function addCommandToHistory(command : String) : Void {
        var commandIndex : Int = Lambda.indexOf(_commandHistory, command);
        if (commandIndex != -1)
        {
            _commandHistory.splice(commandIndex, 1);
            _numCommandsInHistory--;
        }
        
        _commandHistory.push(command);
        _numCommandsInHistory++;
        
        if (_commandHistory.length > _historyMax)
        {
            _commandHistory.shift();
            _numCommandsInHistory--;
        }
        
        _shared.flush();
    }
    
    public function getPreviousHistoryCommand() : String
    {
        if (_currHistoryIndex > 0)
        {
            _currHistoryIndex--;
        }
        
        return getCurrentCommand();
    }
    
    public function getNextHistoryCommand() : String
    {
        if (_currHistoryIndex < _numCommandsInHistory)
        {
            _currHistoryIndex++;
        }
        
        return getCurrentCommand();
    }
    
    public function getCurrentCommand() : String
    {
        var command : String = _commandHistory[_currHistoryIndex];
        
        if (command == null)
        {
            return "";
        }
        return command;
    }
    
    public function toggleConsole() : Void {
        if (_showing)
        {
            hideConsole();
        }
        else
        {
            showConsole();
        }
    }
    
    public function showConsole() : Void {
        if (!_showing)
        {
            _showing = true;
            visible = true;
            stage.focus = _inputField;
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyPressInConsole);
            //_currHistoryIndex = Std.parseInt(_numCommandsInHistory);
            _currHistoryIndex = Std.int(_numCommandsInHistory);
            _onShowConsole.dispatch();
        }
    }
    
    public function hideConsole() : Void {
        if (_showing)
        {
            _showing = false;
            visible = false;
            stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyPressInConsole);
            _onHideConsole.dispatch();
        }
    }
    
    public function clearConsole() : Void {
        _inputField.text = "";
    }
    
    private function onAddedToStage(event : Event) : Void {
        graphics.beginFill(0x000000, .8);
        graphics.drawRect(0, 0, stage.stageWidth, 30);
        graphics.endFill();
        
        _inputField.width = stage.stageWidth;
        _inputField.y = 4;
        _inputField.x = 4;
        
        if (_enabled)
        {
            stage.addEventListener(KeyboardEvent.KEY_UP, onToggleKeyPress);
        }
    }
    
    private function onConsoleFocusOut(event : FocusEvent) : Void {
        hideConsole();
    }
    
    private function onToggleKeyPress(event : KeyboardEvent) : Void {
        if (event.keyCode == openKey)
        {
            toggleConsole();
        }
    }
    
    private function onKeyPressInConsole(event : KeyboardEvent) : Void {
        if (event.keyCode == _executeKey)
        {
            if (_inputField.text == "" || _inputField.text == " "){
                return;
            }
            
            addCommandToHistory(_inputField.text);
            
            var args : Array<Dynamic> = _inputField.text.split(" ");
            var command : String = args.shift();
            clearConsole();
            hideConsole();
            
            var func : Function = Reflect.field(_commandDelegates, command);
            if (func != null){
                try
                {
                    Reflect.callMethod(null, func, args);
                }
                catch (e : ArgumentError)
                {
                    if (e.errorID == 1063)
                    
                    //Argument count mismatch on [some function]. Expected [x], got [y]{
                        
                        {
                            trace(e.message);
                            var expected : Float = Std.parseFloat(e.message.slice(e.message.indexOf("Expected ") + 9, e.message.lastIndexOf(",")));
                            var lessArgs : Array<Dynamic> = args.slice(0, expected);
                            Reflect.callMethod(null, func, lessArgs);
                        }
                   
                }
            }
        }
        else if (event.keyCode == _prevHistoryKey)
        {
            _inputField.text = getPreviousHistoryCommand();
            event.preventDefault();
            _inputField.setSelection(_inputField.text.length, _inputField.text.length);
        }
        else if (event.keyCode == _nextHistoryKey)
        {
            _inputField.text = getNextHistoryCommand();
            event.preventDefault();
            _inputField.setSelection(_inputField.text.length, _inputField.text.length);
        }
    }
}
