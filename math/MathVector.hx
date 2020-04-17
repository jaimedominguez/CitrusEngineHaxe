package citrus.math;


class MathVector
{
    public var angle(get, set) : Float;
    public var length(get, set) : Float;
    public var normal(get, never) : MathVector;

    public var x : Float;
    public var y : Float;
    
    public function new(x : Float = 0, y : Float = 0)
    {
        this.x = x;
        this.y = y;
    }
    
    public function copy() : MathVector
    {
        return new MathVector(x, y);
    }
    
    public function copyFrom(vector : MathVector) : Void {
        this.x = vector.x;
        this.y = vector.y;
    }
    
    public function setTo(x : Float = 0, y : Float = 0) : Void {
        this.x = x;
        this.y = y;
    }
    
    public function rotate(angle : Float) : Void {
        var a : Float = angle;
        var ca : Float = Math.cos(a);
        var sa : Float = Math.sin(a);
        var tx : Float = x;
        var ty : Float = y;
        
        x = tx * ca - ty * sa;
        y = tx * sa + ty * ca;
    }
    
    public function scaleEquals(value : Float) : Void {
        x *= value;y *= value;
    }
    
    public function scale(value : Float, result : MathVector = null) : MathVector
    {
        if (result != null)
        {
            result.x = x * value;
            result.y = y * value;
            
            return result;
        }
        
        return new MathVector(x * value, y * value);
    }
    
    public function normalize() : Void {
        var l : Float = length;
        x /= l;
        y /= l;
    }
    
    public function plusEquals(vector : MathVector) : Void {
        x += vector.x;
        y += vector.y;
    }
    
    public function plus(vector : MathVector, result : MathVector = null) : MathVector
    {
        if (result != null)
        {
            result.x = x + vector.x;
            result.y = y + vector.y;
            
            return result;
        }
        
        return new MathVector(x + vector.x, y + vector.y);
    }
    
    public function minusEquals(vector : MathVector) : Void {
        x -= vector.x;
        y -= vector.y;
    }
    
    public function minus(vector : MathVector, result : MathVector = null) : MathVector
    {
        if (result != null)
        {
            result.x = x - vector.x;
            result.y = y - vector.y;
            
            return result;
        }
        
        return new MathVector(x - vector.x, y - vector.y);
    }
    
    public function dot(vector : MathVector) : Float
    {
        return (x * vector.x) + (y * vector.y);
    }
    
   public function get_angle() : Float
    {
        return Math.atan2(y, x);
    }
    
   public function set_angle(value : Float) : Float
    {
        var l : Float = length;
        var tx : Float = l * Math.cos(value);
        var ty : Float = l * Math.sin(value);
        x = tx;
        y = ty;
        return value;
    }
    
   public function get_length() : Float
    {
        return Math.sqrt((x * x) + (y * y));
    }
    
   public function set_length(value : Float) : Float
    {
        this.scaleEquals(value / length);
        return value;
    }
    
   public function get_normal() : MathVector
    {
        return new MathVector(-y, x);
    }
    
    public function toString() : String
    {
        return "[" + x + ", " + y + "]";
    }
}

