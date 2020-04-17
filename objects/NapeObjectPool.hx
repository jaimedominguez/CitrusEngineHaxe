package citrus.objects;

import citrus.core.CitrusEngine;
import citrus.datastructures.DoublyLinkedListNode;
import citrus.datastructures.PoolObject;
import citrus.physics.nape.Nape;
import citrus.view.ACitrusView;
import citrus.view.ICitrusArt;

//import citrus.core.citrus_internal;
class NapeObjectPool extends PoolObject
{
    private static var stateView : ACitrusView;
    
    public function new(pooledType : Class<Dynamic>, defaultParams : Dynamic, poolGrowthRate : Int = 1)
    {
        super(pooledType, defaultParams, poolGrowthRate, true);
        
        //if (!(describeType(pooledType).factory.extendsClass.(@type == "citrus.objects::NapePhysicsObject").length() > 0))
        //	throw new Error("NapePoolObject: " + String(pooledType) + " is not a NapePhysicsObject");
        
        stateView = CitrusEngine.getInstance().state.view;
    }
    
    override private function _create(node : DoublyLinkedListNode, params : Dynamic = null) : Void {
        if (params == null)
        {
            params = { };
        }
        else if (_defaultParams)
        {
            if (Reflect.field(params, "width") != Reflect.field(_defaultParams, "width")){
                trace(this, "you cannot change the default width of your object.");
                Reflect.setField(params, "width", Reflect.field(_defaultParams, "width"));
            }
            if (Reflect.field(params, "height") != Reflect.field(_defaultParams, "height")){
                trace(this, "you cannot change the default height of your object.");
                Reflect.setField(params, "height", Reflect.field(_defaultParams, "height"));
            }
        }
        Reflect.setField(params, "type", "aPhysicsObject");
        node.data = new PoolType("aPoolObject", params);
        var np : NapePhysicsObject = try cast(node.data, NapePhysicsObject) catch(e:Dynamic) null;
        np.initialize(params);
        onCreate.dispatch(try cast(node.data, _poolType) catch(e:Dynamic) null, params);
        np.addPhysics();
        np.body.space = null;
        stateView.addArt(np);
        np.citrus_internal_data = {};
        
        np.citrus_internal_data["updateCall"] = np.updateCallEnabled;
        np.citrus_internal_data["updateArt"] = (try cast(stateView.getArt(np), ICitrusArt) catch(e:Dynamic) null).updateArtEnabled;
    }
    
    override private function _recycle(node : DoublyLinkedListNode, params : Dynamic = null) : Void {
        var np : NapePhysicsObject = try cast(node.data, NapePhysicsObject) catch(e:Dynamic) null;
        np.initialize(params);
        np.body.space = (try cast(CitrusEngine.getInstance().state.getFirstObjectByType(Nape), Nape) catch(e:Dynamic) null).space;
        if (Lambda.has(np.view, "pauseAnimation"))
        {
            np.view.pauseAnimation(true);
        }
        np.visible = true;
        np.updateCallEnabled = try cast(np.citrus_internal_data["updateCall"], Bool) catch(e:Dynamic) null;
        (try cast(stateView.getArt(np), ICitrusArt) catch(e:Dynamic) null).updateArtEnabled = try cast(np.citrus_internal_data["updateArt"], Bool) catch(e:Dynamic) null;
        super._recycle(node, params);
    }
    
    override private function _dispose(node : DoublyLinkedListNode) : Void {
        var np : NapePhysicsObject = try cast(node.data, NapePhysicsObject) catch(e:Dynamic) null;
        np.body.space = null;
        if (Lambda.has(np.view, "pauseAnimation"))
        {
            np.view.pauseAnimation(false);
        }
        np.visible = false;
        np.updateCallEnabled = false;
        (try cast(stateView.getArt(np), ICitrusArt) catch(e:Dynamic) null).updateArtEnabled = false;
        super._dispose(node);
        (try cast(stateView.getArt(np), ICitrusArt) catch(e:Dynamic) null).update(stateView);
    }
    
    override private function _destroy(node : DoublyLinkedListNode) : Void {
        var np : NapePhysicsObject = try cast(node.data, NapePhysicsObject) catch(e:Dynamic) null;
        stateView.removeArt(np);
        np.destroy();
        super._destroy(node);
    }
}

