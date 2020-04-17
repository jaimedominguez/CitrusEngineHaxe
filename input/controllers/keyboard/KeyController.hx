package citrus.input.controllers.keyboard;

/**
 * ...
 * @author Jaime Dominguez
 */
class KeyController{
	public var name:String;
	public var channel:Int;
	
	public function new(_actionName:String,_channel:Int) {
		name = _actionName;
		channel = _channel;
	}
	
}