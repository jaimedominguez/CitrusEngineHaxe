package citrus.physics.nape;

import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.space.Space;

/**
	 * Used to determine the contact's interaction between objects. It calls function in NapePhysicsObject.
	 */
class NapeContactListener
{
    
    private var _space : Space;
    
    public function new(space : Space)
    {
        _space = space;
        
        _space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, onInteractionBegin));
        _space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, onInteractionEnd));
    }
    
    public function destroy() : Void {
        _space.listeners.clear();
    }
    
    public function onInteractionBegin(interactionCallback : InteractionCallback) : Void {
	    var a : INapePhysicsObject = interactionCallback.int1.userData.myData;
     	var b : INapePhysicsObject = interactionCallback.int2.userData.myData;
       
        if (a != null && a.beginContactCallEnabled)
        {
			if (a.handleBeginContact != null)
			a.handleBeginContact(interactionCallback);
        }
        
        if (b != null && b.beginContactCallEnabled)
        {
			if (b.handleBeginContact != null)
            b.handleBeginContact(interactionCallback);
        }
    }
    
    public function onInteractionEnd(interactionCallback : InteractionCallback) : Void {
        var a : INapePhysicsObject = interactionCallback.int1.userData.myData;
        var b : INapePhysicsObject = interactionCallback.int2.userData.myData;
        
        if (a != null && a.endContactCallEnabled)
        {
            a.handleEndContact(interactionCallback);
        }
        
        if (b != null && b.endContactCallEnabled)
        {
            b.handleEndContact(interactionCallback);
        }
    }
}

