package citrus.view.starlingview;

import citrus.core.CitrusObject;
import citrus.objects.CitrusSprite;
import citrus.physics.APhysicsEngine;
import citrus.physics.nape.NapeDebugArt;
import citrus.view.ACitrusView;
import citrus.view.ISpriteView;
import citrus.view.starlingview.StarlingArt;

import starling.display.Sprite3D;
import starling.display.Sprite;
import flash.display.MovieClip;

//	import dragonBones.animation.WorldClock;
/**
	 * StarlingView is based on Adobe Stage3D and the <a href="http://gamua.com/starling/">Starling</a> framework to render graphics. 
	 * It creates and manages graphics like the traditional Flash display list (but on the GPU!!) thanks to Starling :
	 * (addChild(), removeChild()) using Starling DisplayObjects (MovieClip, Image, Sprite, Quad etc).
	 */
class StarlingView extends ACitrusView
{
    public var viewRoot(get, never) : Sprite;

    
    private var _viewRoot : Sprite;
    
    public function new(root : Sprite)
    {
        super(root, ISpriteView);
        
        root.alpha = 0.999;  // Starling's simple trick to avoid the state changes.  
        
        _viewRoot = new Sprite();
        root.addChild(_viewRoot);
        
        camera = new StarlingCamera(_viewRoot);
    }
    
   public function get_viewRoot() : Sprite
    {
        return _viewRoot;
    }
    
    override public function destroy() : Void {
        _viewRoot.dispose();
        
        super.destroy();
    }
    
    override public function update(timeDelta : Float) : Void {
        super.update(timeDelta);
        
        if (camera.enabled) {
            camera.update();
        }
        var sprite:StarlingArt;
		
        // Update art positions
    	for (s in _viewObjects) {

			
			sprite = _viewObjects[s];
			//trace("sprite:" + sprite.name);
			
			if (sprite.group != sprite.citrusObject.group){
				updateGroupForSprite(sprite);
			}
			
			if (sprite.updateArtEnabled) {
				
				try	{
					sprite.update(this);
				}catch (e:Dynamic){
					trace("some spriteArt IS FUCKED");
					trace("sprite:"+sprite.name);
					trace("e:"+e);
				}
			
			}
			
        }
    }
    
	
    override private function createArt(citrusObject : Dynamic) : Dynamic
    {
        var viewObject : ISpriteView = try cast(citrusObject, ISpriteView) catch(e:Dynamic) null;
       
		if (Std.is(citrusObject, APhysicsEngine))
			cast (citrusObject, APhysicsEngine).view = StarlingPhysicsDebugView;
			//Reflect.setField(citrusObject, "view", StarlingPhysicsDebugView);
	
        var art : StarlingArt = new StarlingArt(viewObject);
        
        // Perform an initial update
        art.update(this);
        
        updateGroupForSprite(art);
        
        return art;
    }
    
    override private function destroyArt(citrusObject : CitrusObject) : Void {
        var starlingArt : StarlingArt = cast (_viewObjects[citrusObject.getString()], StarlingArt);
		//trace("starlingArt:" + starlingArt);
		
		if (starlingArt!=null){
			starlingArt.destroy();
			if (starlingArt.parent != null) starlingArt.parent.removeChild(starlingArt);
			else trace("destroyArt Error");
		}
    }
    
    private function updateGroupForSprite(sprite : StarlingArt) : Void {
        if (sprite.citrusObject.group > _viewRoot.numChildren + 100)
        {
            trace("the group property value of " + sprite.citrusObject + ":" + sprite.citrusObject.group + " is higher than +100 to the current max group value (" + _viewRoot.numChildren + ") and may perform a crash");
        }
        
        // Create the container sprite (group) if it has not been created yet.
        while (sprite.citrusObject.group >= _viewRoot.numChildren)
        {
            _viewRoot.addChild(new Sprite3D());
        }
        
        // Add the sprite to the appropriate group
        cast((_viewRoot.getChildAt(sprite.citrusObject.group)), Sprite3D).addChild(sprite);
    }
}

