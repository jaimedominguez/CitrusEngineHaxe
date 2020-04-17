package citrus.utils;

import flash.errors.Error;
import haxe.Constraints.Function;
import flash.display.Stage;
import flash.display.Stage3D;
import flash.events.ErrorEvent;
import flash.events.Event;

/**
	 * https://github.com/PrimaryFeather/Starling-Framework/issues/337#issuecomment-20620689
	 */
class Context3DUtil
{
    private static var contexts : Array<String>;
    private static var supportsCallback : Function;
    private static var checkingProfile : String;
    
    public static function supportsProfile(nativeStage : Stage, profile : String, callback : Function) : Void {
        supportsCallback = callback;
        checkingProfile = profile;
        
        if (nativeStage.stage3Ds.length > 0)
        {
            var stage3D : Stage3D = nativeStage.stage3Ds[0];
            stage3D.addEventListener(Event.CONTEXT3D_CREATE, supportsProfileContextCreatedListener, false, 10, true);
            stage3D.addEventListener(ErrorEvent.ERROR, supportsProfileContextErroredListener, false, 10, true);
            try
            {
                stage3D.requestContext3D("auto", profile);
            }
            catch (e : Error){
                stage3D.removeEventListener(flash.events.Event.CONTEXT3D_CREATE, supportsProfileContextCreatedListener);
                stage3D.removeEventListener(ErrorEvent.ERROR, supportsProfileContextErroredListener);
                
                if (supportsCallback != null)
                {
                    supportsCallback(checkingProfile, false);
                }
            }
        }
        // no Stage3D instances
        else
        {
            
            if (supportsCallback != null){
                supportsCallback(checkingProfile, false);
            }
        }
    }
    
    private static function supportsProfileContextErroredListener(event : ErrorEvent) : Void {
        var targetStage3D : Stage3D = try cast(event.target, Stage3D) catch(e:Dynamic) null;
        if (targetStage3D != null)
        {
            targetStage3D.removeEventListener(Event.CONTEXT3D_CREATE, supportsProfileContextCreatedListener);
            targetStage3D.removeEventListener(ErrorEvent.ERROR, supportsProfileContextErroredListener);
        }
        if (supportsCallback != null)
        {
            supportsCallback(checkingProfile, false);
        }
    }
    
    private static function supportsProfileContextCreatedListener(event : Event) : Void {
        var targetStage3D : Stage3D = try cast(event.target, Stage3D) catch(e:Dynamic) null;
        
        if (targetStage3D != null)
        {
            targetStage3D.removeEventListener(Event.CONTEXT3D_CREATE, supportsProfileContextCreatedListener);
            targetStage3D.removeEventListener(ErrorEvent.ERROR, supportsProfileContextErroredListener);
            
            if (targetStage3D.context3D)
            
            // the context is recreated as long as there are listeners on it, but there shouldn't be here.{
                
                // Beginning with AIR 3.6, we can guarantee that with an additional parameter of false.
                var disposeContext3D : Function = targetStage3D.context3D.dispose;
                if (as3hx.Compat.getFunctionLength(disposeContext3D) == 1)
                {
                    disposeContext3D(false);
                }
                else
                {
                    disposeContext3D();
                }
                
                if (supportsCallback != null)
                {
                    supportsCallback(checkingProfile, true);
                }
            }
        }
    }

    public function new()
    {
    }
}

