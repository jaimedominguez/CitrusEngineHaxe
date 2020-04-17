package citrus.core;

import citrus.input.Input;
import citrus.sounds.SoundManager;
import kaleidoEngine.core.EngineVars;
import msignal.Signal;

import openfl.display.MovieClip;
import openfl.display.StageAlign;
import openfl.display.StageDisplayState;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.events.FullScreenEvent;
import openfl.geom.Matrix;
import openfl.media.SoundMixer;

/**
	 * CitrusEngine is the top-most class in the library. When you start your project, you should make your
	 * document class extend this class unless you use Starling. In this case extends StarlingCitrusEngine.
	 * 
	 * <p>CitrusEngine is a singleton so that you can grab a reference to it anywhere, anytime. Don't abuse this power,
	 * but use it wisely. With it, you can quickly grab a reference to the manager classes such as current State, Input and SoundManager.</p>
	 */
class CitrusEngine extends MovieClip
{
    public var state(get, set) : IState;
    public var futureState(get, set) : IState;
    public var playing(get, set) : Bool;
    public var input(get, never) : Input;
    public var soundMng(get, never) : SoundManager;
   // public var console(get, never) : Console;
    public var fullScreen(get, set) : Bool;
    public var screenWidth(get, never) : Int;
    public var screenHeight(get, never) : Int;

    public static inline var VERSION : String = "3.1.9";
    
    private static var _instance : CitrusEngine;
    
    /**
		 * Used to pause animations in SpriteArt and StarlingArt.
		 */
    public var onPlayingChange : Signal1<Bool>;
    
    /**
		 * called after a stage resize event
		 * signal passes the new screenWidth and screenHeight as arguments.
		 */
    public var onStageResize : Signal2<Int,Int>;
   
    /**
		 * the matrix that describes the transformation required to go from state container space to flash stage space.
		 * note : this does not include the camera's transformation.
		 * the transformation required to go from flash stage to in state space when a camera is active would be obtained with
		 * var m:Matrix = camera.transformMatrix.clone();
		 * m.concat(_ce.transformMatrix);
		 * 
		 * using flash only, the state container is aligned and of the same scale as the flash stage, so this is not required.
		 */
    public var transformMatrix(default, never) : Matrix = new Matrix();
    
    private var _state : IState;
    private var _newState : IState;
    private var _stateTransitionning : IState;
    private var _futureState : IState;
    private var _stateDisplayIndex : Int = 0;
    private var _playing : Bool = true;
    private var _input : Input;
    
    private var _fullScreen : Bool = false;
    private var _screenWidth : Int = 0;
    private var _screenHeight : Int = 0;
    
    private var _startTime : Float;
    private var _gameTime : Float;
    private var _nowTime : Float;
    private var _timeDelta : Float;
    
    private var _sound : SoundManager;
   // private var _console : Console;
    
    public static function getInstance() : CitrusEngine
    {
        return _instance;
    }
    
    /**
		 * Flash's innards should be calling this, because you should be extending your document class with it.
		 */
    public function new()
    {
        super();
        _instance = this;
        
        onPlayingChange = new Signal1(Bool);
        onStageResize = new Signal2(Int, Int);
        
        onPlayingChange.add(handlePlayingChange);
        
        // on iOS if the physical button is off, mute the sound
       /* if (SoundMixer.audioPlaybackMode)
        {
            SoundMixer.audioPlaybackMode = "ambient";
        }*/
        
        //Set up console
       /* _console = new Console(9);  //Opens with tab key by default  
        _console.onShowConsole.add(handleShowConsole);
        _console.addCommand("set", handleConsoleSetCommand);
        _console.addCommand("get", handleConsoleGetCommand);
        addChild(_console);*/
        
        //timekeeping
        _gameTime = _startTime = EngineVars.getTimeNowMS();// Date.now().getTime();
        
        //Set up input
        _input = new Input();
        
        //Set up sound manager
        _sound = SoundManager.getInstance();
        
        addEventListener(Event.ENTER_FRAME, handleEnterFrame);
       
		///trace("***handleAddedToStage(pre)");
		addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);

    }
    
    /**
		 * Destroy the Citrus Engine, use it only if the Citrus Engine is just a part of your project and not your Main class.
		 */
    public function destroy() : Void {
        onPlayingChange.removeAll();
        
		
        stage.removeEventListener(Event.ACTIVATE, handleStageActivated);
        stage.removeEventListener(Event.DEACTIVATE, handleStageDeactivated);
		
        stage.removeEventListener(FullScreenEvent.FULL_SCREEN, handleStageFullscreen);
        stage.removeEventListener(Event.RESIZE, handleStageResize);
       
        removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
        
		
		
        if (_state != null)
        {
            _state.destroy();
            
            if (Std.is(_state, State)){
                removeChild(cast(_state, State));
            }
        }
        
       // _console.destroy();
       // removeChild(_console);
        
        _input.destroy();
        _sound.destroy();
    }
    
    /**
		 * A reference to the active game state. Actually, that's not entirely true. If you've recently changed states and a tick
		 * hasn't occurred yet, then this will reference your new state; this is because actual state-changes only happen pre-tick.
		 * That way you don't end up changing states in the middle of a state's tick, effectively fucking stuff up.
		 * 
		 * If you had set up a futureState, accessing the state it wil return you the futureState to enable some objects instantiation 
		 * (physics, views, etc).
		 */
   public function get_state() : IState
    {
        if (_futureState != null)
        {
            return _futureState;
        }
        else if (_newState != null)
        {
            return _newState;
        }
        else
        {
            return _state;
        }
    }
    
    /**
		 * We only ACTUALLY change states on enter frame so that we don't risk changing states in the middle of a state update.
		 * However, if you use the state getter, it will grab the new one for you, so everything should work out just fine.
		 */
   public function set_state(value : IState) : IState
    {
        _newState = value;
        return value;
    }
    
    /**
		 * Get a direct access to the futureState. Note that the futureState is really set up after an update so it isn't 
		 * available via state getter before a state update.
		 */
   public function get_futureState() : IState
    {
        return (_futureState != null) ? _futureState : _stateTransitionning;
    }
    
    /**
		 * The futureState variable is useful if you want to have two states running at the same time for making a transition. 
		 * Note that the futureState is added with the same index than the state, so it will be behind unless the state runs 
		 * on Starling and the futureState on the display list (which is absolutely doable).
		 */
   public function set_futureState(value : IState) : IState
    {
        _stateTransitionning = value;
        return value;
    }
    
    /**
		 * @return true if the Citrus Engine is playing
		 */
   public function get_playing() : Bool {
        return _playing;
    }
    
    /**
		 * Runs and pauses the game loop. Assign this to false to pause the game and stop the
		 * <code>update()</code> methods from being called.
		 * Dispatch the Signal onPlayingChange with the value.
		 * CitrusEngine calls its own handlePlayingChange listener to
		 * 1.reset all input actions when "playing" changes
		 * 2.pause or resume all sounds.
		 * override handlePlayingChange to override all or any of these behaviors.
		 */
   public function set_playing(value : Bool) : Bool {
        if (value == _playing)
        {
            return value;
        }
        
        _playing = value;
        if (_playing)
        {
            _gameTime = EngineVars.getTimeNowMS();// Date.now().getTime();
        }
        onPlayingChange.dispatch(_playing);
        return value;
    }
    
    /**
		 * You can get access to the Input manager object from this reference so that you can see which keys are pressed and stuff. 
		 */
   public function get_input() : Input
    {
        return _input;
    }
    
    /**
		 * A reference to the SoundManager instance. Use it if you want.
		 */
   public function get_soundMng() : SoundManager
    {
        return _sound;
    }
    
    /**
		 * A reference to the console, so that you can add your own console commands. See the class documentation for more info.
		 * The console can be opened by pressing the tab key.
		 * There is one console command built-in by default, but you can add more by using the addCommand() method.
		 * 
		 * <p>To try it out, try using the "set" command to change a property on a CitrusObject. You can toggle Box2D's
		 * debug draw visibility like this "set Box2D visible false". If your Box2D CitrusObject instance is not named
		 * "Box2D", use the name you gave it instead.</p>
		 */
  /* public function get_console() : Console
    {
        return _console;
    }
    */
    /**
		 * Set up things that need the stage access.
		 */
    private function handleAddedToStage(e : Event) : Void {
		
        removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		
		stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
		if (!EngineVars.devMode){
			stage.addEventListener(Event.DEACTIVATE, handleStageDeactivated);
			stage.addEventListener(Event.ACTIVATE, handleStageActivated);
        }
        stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleStageFullscreen);
        stage.addEventListener(Event.RESIZE, handleStageResize);
        
        _fullScreen = (stage.displayState == StageDisplayState.FULL_SCREEN || stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE);
        resetScreenSize();
        
        _input.initialize();
        
        this.initialize();
    }
    
    /**
		 * Called when CitrusEngine is added to the stage and ready to run.
		 */
    public function initialize() : Void {
    }
    
    private function handleStageFullscreen(e : FullScreenEvent) : Void
    //trace("handleStageFullscreen!");
    {
        
        _fullScreen = e.fullScreen;
    }
    
    private function handleStageResize(e : Event) : Void {
        resetScreenSize();
        onStageResize.dispatch(_screenWidth, _screenHeight);
    }
    
    /**
		 * on resize or fullscreen this is called and makes sure _screenWidth/_screenHeight is correct,
		 * it can be overriden to update other values that depend on the values of _screenWidth/_screenHeight.
		 */
    private function resetScreenSize() : Void {
        _screenWidth = stage.stageWidth;
        _screenHeight = stage.stageHeight;
    }
    
    /**
		 * called when the value of 'playing' changes.
		 * resets input actions , pauses/resumes all sounds by default.
		 */
    private function handlePlayingChange(value : Bool) : Void {
        if (input != null)
        {
            input.resetActions();
        }
        
        if (soundMng != null)
        {
            if (value){
                soundMng.resumeAll();
            }
            else
            {
                soundMng.pauseAll();
            }
        }
    }
    
    /**
		 * This is the game loop. It switches states if necessary, then calls update on the current state.
		 */
  
    private function handleEnterFrame(e : Event) : Void
    //Change states if it has been requested
    {
        
        if (_newState != null && Std.is(_newState, State))
        {
            if (_state != null && Std.is(_state, State)){
                _state.destroy();
                removeChild(try cast(_state, State) catch(e:Dynamic) null);
            }
            
            _state = _newState;
            _newState = null;
            
            if (_futureState != null){
                _futureState = null;
            }
            else
            {
                addChildAt(try cast(_state, State) catch(e:Dynamic) null, _stateDisplayIndex);
                _state.initialize();
            }
        }
        
        if (_stateTransitionning != null && Std.is(_stateTransitionning, State))
        {
            _futureState = _stateTransitionning;
            _stateTransitionning = null;
            
            addChildAt(try cast(_futureState, State) catch(e:Dynamic) null, _stateDisplayIndex);
            _futureState.initialize();
        }
        
        //Update the state
        if (_state != null && _playing)
        {
            _nowTime = EngineVars.getTimeNowMS();// Date.now().getTime();
            _timeDelta = (_nowTime - _gameTime) * 0.001;
            _gameTime = _nowTime;
            
            _state.update(_timeDelta);
            if (_futureState != null){
                _futureState.update(_timeDelta);
            }
        }
        
        _input.update();
		onEnterFrame();
    }
	
	public function onEnterFrame():Void {
		//override if necesary.
	}
    
    private function handleStageDeactivated(e : Event) : Void {
        playing = false;
    }
    
    private function handleStageActivated(e : Event) : Void {
        playing = true;
    }
    
   /* private function handleShowConsole() : Void {
        if (_input.enabled)
        {
            _input.enabled = false;
            _console.onHideConsole.addOnce(handleHideConsole);
        }
    }
    
    private function handleHideConsole() : Void {
        _input.enabled = true;
    }
    
    private function handleConsoleSetCommand(objectName : String, paramName : String, paramValue : String) : Void {
        var object : CitrusObject = _state.getObjectByName(objectName);
        
        if (object == null)
        {
            trace("Warning: There is no object named " + objectName);
            return;
        }
        
        var value : Dynamic;
        if (paramValue == "true")
        {
            value = true;
        }
        else if (paramValue == "false")
        {
            value = false;
        }
        else
        {
            value = paramValue;
        }
       // trace("object.exists changed to hasField ");
        if (object.exists(paramName))    {
            Reflect.setField(object, paramName, value);
        }
        else
        {
            trace("Warning: " + objectName + " has no parameter named " + paramName + ".");
        }
    }
    
    private function handleConsoleGetCommand(objectName : String, paramName : String) : Void {
        var object : CitrusObject = _state.getObjectByName(objectName);
        
        if (object == null)
        {
            trace("Warning: There is no object named " + objectName);
            return;
        }
        
        if (object.exists(paramName))
        {
            trace(objectName + " property:" + paramName + "=" + Reflect.field(object, paramName));
        }
        else
        {
            trace("Warning: " + objectName + " has no parameter named " + paramName + ".");
        }
    }
    */
   public function get_fullScreen() : Bool {
        return _fullScreen;
    }
    
   public function set_fullScreen(value : Bool) : Bool {
        if (value == _fullScreen){
            return value;
        }
        
        if (value){
            stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
        }else{
            stage.displayState = StageDisplayState.NORMAL;
        }
        
        resetScreenSize();
        return value;
    }
    
   public function get_screenWidth() : Int
    {
        return _screenWidth;
    }
    
   public function get_screenHeight() : Int
    {
        return _screenHeight;
    }
}
