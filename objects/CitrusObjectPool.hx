package citrus.objects;

import citrus.core.CitrusObject;
import citrus.datastructures.DoublyLinkedListNode;
import citrus.datastructures.PoolObject;

/**
	 * Base CitrusObject PoolObject (ex: CitrusSprites)
	 */
class CitrusObjectPool extends PoolObject
{
    
    public function new(pooledType : Class<Dynamic>, defaultParams : Dynamic, poolGrowthRate : Int = 1)
    {
        super(pooledType, defaultParams, poolGrowthRate, true);
    }
    
    override private function _create(node : DoublyLinkedListNode, params : Dynamic = null) : Void {
        var co : CitrusObject = node.data = new PoolType("aPoolObject", params);
        co.initialize(params);
        onCreate.dispatch(co, params);
    }
    
    override private function _recycle(node : DoublyLinkedListNode, params : Dynamic = null) : Void {
        var co : CitrusObject = try cast(node.data, CitrusObject) catch(e:Dynamic) null;
        super._recycle(node, params);
    }
    
    override private function _dispose(node : DoublyLinkedListNode) : Void {
        var co : CitrusObject = try cast(node.data, CitrusObject) catch(e:Dynamic) null;
        super._dispose(node);
    }
    
    override private function _destroy(node : DoublyLinkedListNode) : Void {
        var co : CitrusObject = try cast(node.data, CitrusObject) catch(e:Dynamic) null;
        co.destroy();
        super._destroy(node);
    }
}

