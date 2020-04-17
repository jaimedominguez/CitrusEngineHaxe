package citrus.core.starling;

import citrus.core.CitrusEngine;
import citrus.core.State;
import citrus.utils.Mobile;
import flash.display.Stage3D;
import flash.events.Event;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.events.Event;
import starling.utils.RectangleUtil;
import starling.utils.ScaleMode;

/**
	 * Extends this class if you create a Starling based game. Don't forget to call <code>setUpStarling</code> function.
	 * 
	 * <p>CitrusEngine can access to the Stage3D power thanks to the <a href="http://starling-framework.org/">Starling Framework</a>.</p>
	 */
class StarlingCitrusEngine extends CitrusEngine
{
    public var starling(get, never) : Starling;
    public var baseWidth(get, never) : Int;
    public var baseHeight(get, never) : Int;
    public var juggler(get, never) : CitrusStarlingJuggler;

    
    public var scaleFactor : Float = 1;
	static public inline var ROOT_CREATED:String = "rootCreated";
    
    private var _starling : Starling;
    private var _juggler : CitrusStarlingJuggler;
    
    private var _assetSizes : Array<Int> = [1];
    public var _baseWidth : Int = -1;
    public var _baseHeight : Int = -1;
    public var _viewportMode : String = ViewportMode.LEGACY;
    public var _viewport : Rectangle;
    
    private var _viewportBaseRatioWidth : Float = 1;
    private var _viewportBaseRatioHeight : Float = 1;
    
    /**
		 * context3D profiles to test for in Ascending order (the more important first).
		 * reset this array to a single entry to force one specific profile. <a href="http://wiki.starling-framework.org/manual/constrained_stage3d_profile">More informations</a>.
		 */
    private var _context3DProfiles : Array<String> = ["baselineExtended", "baseline", "baselineConstrained"];
    private var _context3DProfileTestDelay : Int = 100;
    
    public function new()
    {
        super();
        
        _juggler = new CitrusStarlingJuggler();
    }
    
    /**
		 * @inheritDoc
		 */
    override public function destroy() : Void {
        super.destroy();
        
        _juggler.purge();
        
        if (_state != null )
        {
            if (_starling != null){
                _starling.stage.removeChild(cast(_state, StarlingState));
                _starling.root.dispose();
                _starling.dispose();
            }
        }
    }
    
    /**
		 * @inheritDoc
		 */
    override private function handlePlayingChange(value : Bool) : Void {
        super.handlePlayingChange(value);
        
        _juggler.paused = !value;
    }
    
    /**
		 * You should call this function to create your Starling view. The RootClass is internal, it is never used elsewhere. 
		 * StarlingState is added on the starling stage : <code>_starling.stage.addChildAt(_state as StarlingState, _stateDisplayIndex);</code>
		 * @param debugMode If true, display a Stats class instance.
		 * @param antiAliasing The antialiasing value allows you to set the anti-aliasing (0 - 16), generally a value of 1 is totally acceptable.
		 * @param viewPort Starling's viewport, default is (0, 0, stage.stageWidth, stage.stageHeight, change to (0, 0, stage.fullScreenWidth, stage.fullScreenHeight) for mobile.
		 * @param stage3D The reference to the Stage3D, useful for sharing a 3D context. <a href="http://wiki.starling-framework.org/tutorials/combining_starling_with_other_stage3d_frameworks">More informations</a>.
		 */
    public function setUpStarling(debugMode : Bool = false, antiAliasing : Int = 1, viewPort : Rectangle = null, stage3D : Stage3D = null) : Void {
        if (Mobile.isAndroid()){
            Starling.handleLostContext = true;
        }
        
        if (viewPort != null){
            _viewport = viewPort;
        }
        
       
        _starling = new Starling(RootClass, stage, null, stage3D, "auto", "auto");
        _starling.antiAliasing = antiAliasing;
        _starling.showStats = debugMode;
        _starling.addEventListener(Event.CONTEXT3D_CREATE, _context3DCreated);
    }
    
    /**
		 * returns the asset size closest to one of the available asset sizes you have (based on <code>Starling.contentScaleFactor</code>).
		 * If you design your app with a Starling's stage dimension equals to the Flash's stage dimension, you will have to overwrite 
		 * this function since the <code>Starling.contentScaleFactor</code> will be always equal to 1.
		 * @param	assetSizes Array of numbers listing all asset sizes you use
		 * @return
		 */
    private function findScaleFactor(assetSizes : Array<Int>) : Float
    {
        var arr : Array<Int> = assetSizes;
     
        var scaleF : Float = Math.floor(starling.contentScaleFactor * 10) / 10;
        var closest : Float = 0;
        var f : Float = 0;
        for (f in arr){
            if (closest==0 || Math.abs(f - scaleF) < Math.abs(closest - scaleF)){
                closest = f;
            }
        }
	
        return closest;
    }
    
    private function resetViewport() : Rectangle
    {
        if (_baseHeight < 0){
            _baseHeight = _screenHeight;
        }
        if (_baseWidth < 0){
            _baseWidth = _screenWidth;
        }
        
        var baseRect : Rectangle = new Rectangle(0, 0, _baseWidth, _baseHeight);
        var screenRect : Rectangle = new Rectangle(0, 0, _screenWidth, _screenHeight);
        
        switch (_viewportMode)
        {
            case ViewportMode.LETTERBOX:
                _viewport = RectangleUtil.fit(baseRect, screenRect, ScaleMode.SHOW_ALL);
                _viewport.x = _screenWidth * .5 - _viewport.width * .5;
                _viewport.y = _screenHeight * .5 - _viewport.height * .5;
                if (_starling != null)
                {
                    _starling.stage.stageWidth = _baseWidth;
                    _starling.stage.stageHeight = _baseHeight;
                }
            
            case ViewportMode.FULLSCREEN:
                _viewport = RectangleUtil.fit(baseRect, screenRect, ScaleMode.SHOW_ALL);
                _viewportBaseRatioWidth = _viewport.width / baseRect.width;
                _viewportBaseRatioHeight = _viewport.height / baseRect.height;
                _viewport.copyFrom(screenRect);
                
                _viewport.x = 0;
                _viewport.y = 0;
                
                if (_starling != null)
                {
                    _starling.stage.stageWidth = cast(screenRect.width / _viewportBaseRatioWidth,Int);
                    _starling.stage.stageHeight = cast(screenRect.height / _viewportBaseRatioHeight,Int);
                }
            case ViewportMode.NO_SCALE:
                _viewport = baseRect;
                _viewport.x = _screenWidth * .5 - _viewport.width * .5;
                _viewport.y = _screenHeight * .5 - _viewport.height * .5;
                
                if (_starling != null)
                {
                    _starling.stage.stageWidth = _baseWidth;
                    _starling.stage.stageHeight = _baseHeight;
                }
            case ViewportMode.LEGACY, ViewportMode.MANUAL:

                switch (_viewportMode)
                {
					case ViewportMode.LEGACY:
                        _viewport = screenRect;
                        if (_starling != null)
                        {
                            _starling.stage.stageWidth = cast(screenRect.width,Int);
                            _starling.stage.stageHeight = cast(screenRect.height,Int);
                        }
                }
                if (_viewport == null)
                {
                    _viewport = _starling.viewPort.clone();
                }
        }
        
        scaleFactor = findScaleFactor(_assetSizes);
        
        if (_starling != null)
        {
            transformMatrix.identity();
            transformMatrix.scale(_starling.contentScaleFactor, _starling.contentScaleFactor);
            transformMatrix.translate(_viewport.x, _viewport.y);
        }
        
        return _viewport;
    }
    
    /**
		 * @inheritDoc
		 */
    override private function resetScreenSize() : Void {
        super.resetScreenSize();
        
        if (_starling == null)
        {
            return;
        }
        
        resetViewport();
        _starling.viewPort.copyFrom(_viewport);
    }
    
    /**
		 * Be sure that starling is initialized (especially on mobile).
		 */
    private function _context3DCreated(evt : starling.events.Event) : Void {
		
        _starling.removeEventListener(Event.CONTEXT3D_CREATE, _context3DCreated);
        
        resetScreenSize();
        
        if (!_starling.isStarted)
        {
            _starling.start();
        }
        
      
    }
    
    /**
		 * This function is called when context3D is ready and the starling root is created.
		 * the idea is to use this function for asset loading through the starling AssetManager and create the first state.
		 */
    public function handleStarlingReady() : Void {
    }
    
   public function get_starling() : Starling
    {
        return _starling;
    }
    
    /**
		 * @inheritDoc
		 */
    override private function handleEnterFrame(e : flash.events.Event) : Void {
        if (_starling != null && _starling.isStarted && _starling.context!=null)
        {
            if (_newState!=null){
                if (_state!=null)
                {
                    if (Std.is(_state, StarlingState))
                    {
						//trace("DESTROY-STATE");
                        _state.destroy();
						//trace("DESTROY-STATE...STEP2");
                        _starling.stage.removeChild(cast(_state, StarlingState), true);
						//trace("DESTROY-STATE...COMPLETED");
                    }
                    else if (Std.is(_newState, StarlingState))
                    {
                        _state.destroy();
                        removeChild(cast(_state, State));
                    }
                }
                
                if (Std.is(_newState, StarlingState)) {
                    _state = _newState;
                    _newState = null;
                    
                    if (_futureState!=null){
                        _futureState = null;
                    }
                    else
                    {
                        _starling.stage.addChildAt(cast(_state, StarlingState), _stateDisplayIndex);
                        _state.initialize();
                    }
                }
            }
            
            if (_stateTransitionning!=null && Std.is(_stateTransitionning, StarlingState)){
                _futureState = _stateTransitionning;
                _stateTransitionning = null;
                
                starling.stage.addChildAt(cast(_futureState, StarlingState), _stateDisplayIndex);
                _futureState.initialize();
            }
        }
        
        super.handleEnterFrame(e);
        
        if (_juggler != null)
        {
            _juggler.advanceTime(_timeDelta);
        }
    }
    
    /**
		 * @inheritDoc
		 */
    override private function handleStageDeactivated(e : flash.events.Event) : Void {
        if (_playing && _starling != null)
        {
            _starling.stop(true);
        }
        
        super.handleStageDeactivated(e);
    }
    
    /**
		 * @inheritDoc
		 */
    override private function handleStageActivated(e : flash.events.Event) : Void {
        if (_starling != null && !_starling.isStarted){
            _starling.start();
        }
        
        super.handleStageActivated(e);
    }
    
   public function get_baseWidth() : Int
    {
        return _baseWidth;
    }
    
   public function get_baseHeight() : Int
    {
        return _baseHeight;
    }
    
   public function get_juggler() : CitrusStarlingJuggler
    {
        return _juggler;
    }
}





