package citrus.datastructures;


/**
	 * A doubly linked list is a linked data structure that consists of a set of sequentially linked records called nodes.
	 * Each node contains two fields, called links, that are references to the previous and to the next node in the sequence of nodes. 
	 */
class DoublyLinkedList
{
    public var length(get, never) : Int;

    
    public var head : DoublyLinkedListNode;
    public var tail : DoublyLinkedListNode;
    
    private var _count : Int;
    
    public function new()
    {
        head = tail = null;
        _count = 0;
    }
    
    /**
		 * Append an object to the list.
		 * @param data an object of any type added at the end of the list.
		 * @return returns the tail.
		 */
    public function append(data : Dynamic) : DoublyLinkedListNode
    {
        var node : DoublyLinkedListNode = new DoublyLinkedListNode(data);
        
        if (tail != null)
        {
            tail.next = node;
            node.prev = tail;
            tail = node;
        }
        else
        {
            head = tail = node;
        }
        
        ++_count;
        
        return tail;
    }
    
    /**
		 * Append a node to the list.
		 * @param node a DoublyLinkedListNode object of any type added at the end of the list.
		 * @return returns the doublyLinkedList.
		 */
    public function appendNode(node : DoublyLinkedListNode) : DoublyLinkedList
    {
        if (head != null)
        {
            tail.next = node;
            node.prev = tail;
            tail = node;
        }
        else
        {
            head = tail = node;
        }
        
        
        ++_count;
        
        return this;
    }
    
    /**
		 * Prepend an object to the list.
		 * @param data an object of any type added at the beginning of the list.
		 * @return returns the head.
		 */
    public function prepend(data : Dynamic) : DoublyLinkedListNode
    {
        var node : DoublyLinkedListNode = new DoublyLinkedListNode(data);
        
        if (head != null)
        {
            head.prev = node;
            node.next = head;
            head = node;
        }
        else
        {
            head = tail = node;
        }
        
        ++_count;
        
        return head;
    }
    
    /**
		 * Prepend a node to the list.
		 * @param node a DoublyLinkedListNode object of any type added at the beginning of the list.
		 * @return returns the doublyLinkedList.
		 */
    public function prependNode(node : DoublyLinkedListNode) : DoublyLinkedList
    {
        if (head != null)
        {
            head.prev = node;
            node.next = head;
            head = node;
        }
        else
        {
            head = tail = node;
        }
        
        ++_count;
        
        return this;
    }
    
    /**
		 * Remove a node from the list and return its data.
		 * @param node the node to remove from the list.
		 * @return returns the removed node data.
		 */
    public function removeNode(node : DoublyLinkedListNode) : Dynamic
    {
        var data : Dynamic = node.data;
        
        var countChanged : Bool = false;
        
        if (node == head)
        {
            removeHead();
            countChanged = true;
        }
        else
        {
            node.prev.next = node.next;
        }
        
        if (node == tail)
        {
            removeTail();
            countChanged = true;
        }
        else
        {
            node.next.prev = node.prev;
        }
        
        if (!countChanged)
        {
            --_count;
        }
        
        return data;
    }
    
    public function removeHead() : Dynamic
    {
        var node : DoublyLinkedListNode = head;
        
        if (head != null)
        {
            var data : Dynamic = node.data;
            
            head = head.next;
            
            if (head != null){
                head.prev = null;
            }
            
            --_count;
            
            return data;
        }
    }
    
    public function removeTail() : Dynamic
    {
        var node : DoublyLinkedListNode = tail;
        
        if (tail != null)
        {
            var data : Dynamic = node.data;
            
            tail = tail.prev;
            
            if (tail != null){
                tail.next = null;
            }
            
            --_count;
            
            return data;
        }
    }
    
    /**
		 * Get the lengh of the list.
		 * @return the list length.
		 */
   public function get_length() : Int
    {
        return _count;
    }
    
    public function content() : String
    {
        var tmpHead : DoublyLinkedListNode = head;
        var text : String = "";
        
        while (tmpHead != null)
        {
            text += Std.string(tmpHead.data) + " ";
            tmpHead = tmpHead.next;
        }
        
        return text;
    }
}

