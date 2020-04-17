package citrus.objects;

import flash.errors.Error;
import citrus.core.CitrusEngine;
import citrus.datastructures.DoublyLinkedListNode;
import citrus.datastructures.PoolObject;
import citrus.view.ACitrusView;
import citrus.view.ICitrusArt;

//import citrus.core.citrus_internal;
class CitrusSpritePool extends PoolObject
{
    private static var stateView : ACitrusView;
    
    public function new(pooledType : Class<Dynamic>, defaultParams : Dynamic, poolGrowthRate : Int = 1)
    {
        super(pooledType, defaultParams, poolGrowthRate, true);
        
        //test if defined pooledType class inherits from CitrusSprite
        var test : Dynamic;
        if (Std.is((test = Type.createInstance(pooledType, ["test"])), CitrusSprite))
        {
            test.kill = true;test = null;
        }
        else
        {
            throw new Error("CitrusSpritePool: " + Std.string(pooledType) + " is not a CitrusSprite");
        }
        
        stateView = CitrusEngine.getInstance().state.view;
    }
    
    override private function _create(node : DoublyLinkedListNode, params : Dynamic = null) : Void {
        if (params == null)
        {
            params = { };
        }
        
        var cs : CitrusSprite = node.data = try cast(new PoolType("aPoolObject", params), CitrusSprite) catch(e:Dynamic) null;
        cs.initialize(params);
        onCreate.dispatch(try cast(node.data, _poolType) catch(e:Dynamic) null, params);
        stateView.addArt(cs);
        
        cs.citrus_internal_data = {};
        cs.citrus_internal_data["updateCall"] = cs.updateCallEnabled;
        cs.citrus_internal_data["updateArt"] = (try cast(stateView.getArt(cs), ICitrusArt) catch(e:Dynamic) null).updateArtEnabled;
    }
    
    override private function _recycle(node : DoublyLinkedListNode, params : Dynamic = null) : Void {
        var cs : CitrusSprite = try cast(node.data, CitrusSprite) catch(e:Dynamic) null;
        cs.initialize(params);
        if (Lambda.has(cs.view, "pauseAnimation"))
        {
            cs.view.pauseAnimation(true);
        }
        cs.visible = true;
        cs.updateCallEnabled = try cast(cs.citrus_internal_data["updateCall"], Bool) catch(e:Dynamic) null;
        (try cast(stateView.getArt(cs), ICitrusArt) catch(e:Dynamic) null).updateArtEnabled = try cast(cs.citrus_internal_data["updateArt"], Bool) catch(e:Dynamic) null;
        super._recycle(node, params);
    }
    
    override private function _dispose(node : DoublyLinkedListNode) : Void {
        var cs : CitrusSprite = try cast(node.data, CitrusSprite) catch(e:Dynamic) null;
        if (Lambda.has(cs.view, "pauseAnimation"))
        {
            cs.view.pauseAnimation(false);
        }
        cs.visible = false;
        cs.updateCallEnabled = false;
        (try cast(stateView.getArt(cs), ICitrusArt) catch(e:Dynamic) null).updateArtEnabled = false;
        super._dispose(node);
        (try cast(stateView.getArt(cs), ICitrusArt) catch(e:Dynamic) null).update(stateView);
    }
    
    override private function _destroy(node : DoublyLinkedListNode) : Void {
        var cs : CitrusSprite = try cast(node.data, CitrusSprite) catch(e:Dynamic) null;
        stateView.removeArt(cs);
        cs.destroy();
        super._destroy(node);
    }
}

