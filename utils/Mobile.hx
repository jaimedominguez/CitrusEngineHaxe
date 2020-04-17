package citrus.utils;

import citrus.core.CitrusEngine;
import flash.display.Stage;
import flash.system.Capabilities;

/**
	 * This class provides mobile devices information.
	 */
class Mobile
{
    public static var iOS_MARGIN(get, never) : Int;
    public static var iPHONE_RETINA_WIDTH(get, never) : Int;
    public static var iPHONE_RETINA_HEIGHT(get, never) : Int;
    public static var iPHONE5_RETINA_HEIGHT(get, never) : Int;
    public static var iPAD_WIDTH(get, never) : Int;
    public static var iPAD_HEIGHT(get, never) : Int;
    public static var iPAD_RETINA_WIDTH(get, never) : Int;
    public static var iPAD_RETINA_HEIGHT(get, never) : Int;

    
    private static var _STAGE : Stage;
    
    private static inline var _IOS_MARGIN : Int = 40;
    
    private static inline var _IPHONE_RETINA_WIDTH : Int = 640;
    private static inline var _IPHONE_RETINA_HEIGHT : Int = 960;
    private static inline var _IPHONE5_RETINA_HEIGHT : Int = 1136;
    
    private static inline var _IPAD_WIDTH : Int = 768;
    private static inline var _IPAD_HEIGHT : Int = 1024;
    private static inline var _IPAD_RETINA_WIDTH : Int = 1536;
    private static inline var _IPAD_RETINA_HEIGHT : Int = 2048;
    
    public function new()
    {
    }
    
    public static function isIOS() : Bool {
        return (Capabilities.version.substr(0, 3) == "IOS");
    }
    
    public static function isAndroid() : Bool {
        return (Capabilities.version.substr(0, 3) == "AND");
    }
    
    public static function isLandscapeMode() : Bool {
        if (_STAGE == null)
        {
            _STAGE = CitrusEngine.getInstance().stage;
        }
        
        return (_STAGE.fullScreenWidth > _STAGE.fullScreenHeight);
    }
    
    public static function isRetina() : Bool {
        if (Mobile.isIOS())
        {
            if (_STAGE == null){
                _STAGE = CitrusEngine.getInstance().stage;
            }
            
            if (isLandscapeMode()){
                return (_STAGE.fullScreenWidth == _IPHONE_RETINA_HEIGHT || _STAGE.fullScreenWidth == _IPHONE5_RETINA_HEIGHT || _STAGE.fullScreenWidth == _IPAD_RETINA_HEIGHT || _STAGE.fullScreenHeight == _IPHONE_RETINA_HEIGHT || _STAGE.fullScreenHeight == _IPHONE5_RETINA_HEIGHT || _STAGE.fullScreenHeight == _IPAD_RETINA_HEIGHT);
            }
            else
            {
                return (_STAGE.fullScreenWidth == _IPHONE_RETINA_WIDTH || _STAGE.fullScreenWidth == _IPAD_RETINA_WIDTH || _STAGE.fullScreenHeight == _IPHONE_RETINA_WIDTH || _STAGE.fullScreenHeight == _IPAD_RETINA_WIDTH);
            }
        }
        else
        {
            return false;
        }
    }
    
    public static function isIpad() : Bool {
        if (Mobile.isIOS())
        {
            if (_STAGE == null){
                _STAGE = CitrusEngine.getInstance().stage;
            }
            
            if (isLandscapeMode()){
                return (_STAGE.fullScreenWidth == _IPAD_HEIGHT || _STAGE.fullScreenWidth == _IPAD_RETINA_HEIGHT || _STAGE.fullScreenHeight == _IPAD_HEIGHT || _STAGE.fullScreenHeight == _IPAD_RETINA_HEIGHT);
            }
            else
            {
                return (_STAGE.fullScreenWidth == _IPAD_WIDTH || _STAGE.fullScreenWidth == _IPAD_RETINA_WIDTH || _STAGE.fullScreenHeight == _IPAD_WIDTH || _STAGE.fullScreenHeight == _IPAD_RETINA_WIDTH);
            }
        }
        else
        {
            return false;
        }
    }
    
    public static function isIphone5() : Bool {
        if (Mobile.isIOS())
        {
            if (_STAGE == null){
                _STAGE = CitrusEngine.getInstance().stage;
            }
            
            return (_STAGE.fullScreenHeight == _IPHONE5_RETINA_HEIGHT || _STAGE.fullScreenHeight == Mobile._IPHONE5_RETINA_HEIGHT - _IOS_MARGIN);
        }
        else
        {
            return false;
        }
    }
    
    private static function get_iOS_MARGIN() : Int
    {
        return _IOS_MARGIN;
    }
    
    private static function get_iPHONE_RETINA_WIDTH() : Int
    {
        return _IPHONE_RETINA_WIDTH;
    }
    
    private static function get_iPHONE_RETINA_HEIGHT() : Int
    {
        return _IPHONE_RETINA_HEIGHT;
    }
    
    private static function get_iPHONE5_RETINA_HEIGHT() : Int
    {
        return _IPHONE5_RETINA_HEIGHT;
    }
    
    private static function get_iPAD_WIDTH() : Int
    {
        return _IPAD_WIDTH;
    }
    
    private static function get_iPAD_HEIGHT() : Int
    {
        return _IPAD_HEIGHT;
    }
    
    private static function get_iPAD_RETINA_WIDTH() : Int
    {
        return _IPAD_RETINA_WIDTH;
    }
    
    private static function get_iPAD_RETINA_HEIGHT() : Int
    {
        return _IPAD_RETINA_HEIGHT;
    }
}

