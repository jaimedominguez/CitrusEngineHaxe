package citrus.core;

import citrus.system.Entity;
import citrus.view.ACitrusView;

/**
	 * Take a look on the 2 respective states to have some information on the functions.
	 */
interface IState
{
    
    
    var view(get, never) : ACitrusView;

    
    function destroy() : Void
    ;
    
    function initialize() : Void
    ;
    
    function update(timeDelta : Float) : Void
    ;
    
    function add(object : CitrusObject) : CitrusObject
    ;
    
    function addEntity(entity : Entity) : Entity
    ;
    
    function remove(object : CitrusObject) : Void
    ;
    
    function getObjectByName(name : String) : CitrusObject
    ;
    
    function getFirstObjectByType(type : Class<Dynamic>) : CitrusObject
    ;
    
    function getObjectsByType(type : Class<Dynamic>) : Array<CitrusObject>
    ;
}

