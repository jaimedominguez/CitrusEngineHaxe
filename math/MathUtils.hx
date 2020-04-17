package citrus.math;

import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

class MathUtils
{
    
    public static function DistanceBetweenTwoPoints(x1 : Float, x2 : Float, y1 : Float, y2 : Float) : Float
    {
        var dx : Float = x1 - x2;
        var dy : Float = y1 - y2;
        
        return Math.sqrt(dx * dx + dy * dy);
    }
    
    public static function RotateAroundInternalPoint(object : DisplayObject, pointToRotateAround : Point, rotation : Float) : Void
    // Thanks : http://blog.open-design.be/2009/02/05/rotate-a-movieclipdisplayobject-around-a-point/
    {
        
        
        var m : Matrix = object.transform.matrix;
        
        var point : Point = pointToRotateAround;
        point = m.transformPoint(point);
        
        RotateAroundExternalPoint(object, point, rotation);
    }
    
    public static function RotateAroundExternalPoint(object : DisplayObject, pointToRotateAround : Point, rotation : Float) : Void {
        var m : Matrix = object.transform.matrix;
        
        m.translate(-pointToRotateAround.x, -pointToRotateAround.y);
        m.rotate(rotation * (Math.PI / 180));
        m.translate(pointToRotateAround.x, pointToRotateAround.y);
        
        object.transform.matrix = m;
    }
    
    /**
		 * Rotates x,y around Origin (like MathVector.rotate() )
		 * if resultPoint is define, will set resultPoint to new values, otherwise, it will return a new point.
		 * @param	p flash.geom.Point
		 * @param	a angle in radians
		 * @return	returns a new rotated point.
		 */
    public static function rotatePoint(x : Float, y : Float, a : Float, resultPoint : Point = null) : Point
    {
        var c : Float = Math.cos(a);
        var s : Float = Math.sin(a);
        if (resultPoint != null)
        {
            resultPoint.setTo(x * c + y * s, -x * s + y * c);
            return null;
        }
        else
        {
            return new Point(x * c + y * s, -x * s + y * c);
        }
    }
    
    /**
		 * Get the linear equation from two points.
		 * @return an object, m is the slope and b a constant term.
		 */
    public static function lineEquation(p0 : Point, p1 : Point) : Dynamic
    {
        var a : Float = (p1.y - p0.y) / (p1.x - p0.x);
        var b : Float = p0.y - a * p0.x;
        
        return {
            m : a,
            b : b
        };
    }
    
    /**
		 * Linear interpolation function
		 * @param	a start value
		 * @param	b end value
		 * @param	ratio interpolation amount
		 * @return
		 */
    public static function lerp(a : Float, b : Float, ratio : Float) : Float
    {
        return a + (b - a) * ratio;
    }
    
    /**
		 * Creates the axis aligned bounding box for a rotated rectangle.
		 * @param w width of the rotated rectangle
		 * @param h height of the rotated rectangle
		 * @param a angle of rotation around the topLeft point in radian
		 * @return flash.geom.Rectangle
		 */
    public static function createAABB(x : Float, y : Float, w : Float, h : Float, a : Float = 0) : Rectangle
    {
        var aabb : Rectangle = new Rectangle(x, y, w, h);
        
        if (a == 0)
        {
            return aabb;
        }
        
        var c : Float = Math.cos(a);
        var s : Float = Math.sin(a);
        var cpos : Bool;
        var spos : Bool;
        
        if (s < 0)
        {
            s = -s;spos = false;
        }
        else
        {
            spos = true;
        }
        if (c < 0)
        {
            c = -c;cpos = false;
        }
        else
        {
            cpos = true;
        }
        
        aabb.width = h * s + w * c;
        aabb.height = h * c + w * s;
        
        if (cpos)
        {
            if (spos){
                aabb.x -= h * s;
            }
            else
            {
                aabb.y -= w * s;
            }
        }
        else if (spos)
        {
            aabb.x -= w * c + h * s;
            aabb.y -= h * c;
        }
        else
        {
            aabb.x -= w * c;
            aabb.y -= w * s + h * c;
        }
        
        return aabb;
    }
    
    /**
		 * Creates the axis aligned bounding box for a rotated rectangle
		 * and offsetX , offsetY which is simply the x and y position of
		 * the aabb relative to the rotated rectangle. the rectangle and the offset values are returned through an object.
		 * such object can be re-used by passing it through the last argument.
		 * @param w width of the rotated rectangle
		 * @param h height of the rotated rectangle
		 * @param a angle of rotation around the topLeft point in radian
		 * @param aabbdata the object to store the results in.
		 * @return {rect:flash.geom.Rectangle,offsetX:Number,offsetY:Number}
		 */
    public static function createAABBData(x : Float, y : Float, w : Float, h : Float, a : Float = 0, aabbdata : Dynamic = null) : Dynamic
    {
        if (aabbdata == null)
        {
            aabbdata = {
                        offsetX : 0,
                        offsetY : 0,
                        rect : new Rectangle()
                    };
        }
        
        aabbdata.rect.setTo(x, y, w, h);
        var offX : Float = 0;
        var offY : Float = 0;
        
        if (a == 0)
        {
            aabbdata.offsetX = 0;
            aabbdata.offsetY = 0;
            return aabbdata;
        }
        
        var c : Float = Math.cos(a);
        var s : Float = Math.sin(a);
        var cpos : Bool;
        var spos : Bool;
        
        if (s < 0)
        {
            s = -s;spos = false;
        }
        else
        {
            spos = true;
        }
        if (c < 0)
        {
            c = -c;cpos = false;
        }
        else
        {
            cpos = true;
        }
        
        aabbdata.rect.width = h * s + w * c;
        aabbdata.rect.height = h * c + w * s;
        
        if (cpos)
        {
            if (spos){
                offX -= h * s;
            }
            else
            {
                offY -= w * s;
            }
        }
        else if (spos)
        {
            offX -= w * c + h * s;
            offY -= h * c;
        }
        else
        {
            offX -= w * c;
            offY -= w * s + h * c;
        }
        
        aabbdata.rect.x += aabbdata.offsetX = offX;
        aabbdata.rect.y += aabbdata.offsetY = offY;
        
        return aabbdata;
    }
    
    /**
		 * check if angle is between angle a and b
		 * thanks to http://www.xarg.org/2010/06/is-an-angle-between-two-other-angles/
		 */
    public static function angleBetween(angle : Float, a : Float, b : Float) : Bool {
        var mod : Float = Math.PI * 2;
        angle = (mod + (angle % mod)) % mod;
        a = (mod * 100 + a) % mod;
        b = (mod * 100 + b) % mod;
        if (a < b)
        {
            return a <= angle && angle <= b;
        }
        return a <= angle || angle <= b;
    }
    
    /**
		 * Checks for intersection of Segment if asSegments is true.
		 * Checks for intersection of Lines if asSegments is false.
		 * 
		 * http://keith-hair.net/blog/2008/08/04/find-intersection-point-of-two-lines-in-as3/
		 * 
		 * @param	x1 x of point 1 of segment 1
		 * @param	y1 y of point 1 of segment 1
		 * @param	x2 x of point 2 of segment 1
		 * @param	y2 y of point 2 of segment 1
		 * @param	x3 x of point 3 of segment 2
		 * @param	y3 y of point 3 of segment 2
		 * @param	x4 x of point 4 of segment 2
		 * @param	y4 y of point 4 of segment 2
		 * @param	asSegments
		 * @return the intersection point of segment 1 and 2 or null if they don't intersect.
		 */
    public static function linesIntersection(x1 : Float, y1 : Float, x2 : Float, y2 : Float, x3 : Float, y3 : Float, x4 : Float, y4 : Float, asSegments : Bool = true) : Point
    {
        var ip : Point;
        var a1 : Float;
        var a2 : Float;
        var b1 : Float;
        var b2 : Float;
        var c1 : Float;
        var c2 : Float;
        
        a1 = y2 - y1;
        b1 = x1 - x2;
        c1 = x2 * y1 - x1 * y2;
        a2 = y4 - y3;
        b2 = x3 - x4;
        c2 = x4 * y3 - x3 * y4;
        
        var denom : Float = a1 * b2 - a2 * b1;
        if (denom == 0)
        {
            return null;
        }
        
        ip = new Point();
        ip.x = (b1 * c2 - b2 * c1) / denom;
        ip.y = (a2 * c1 - a1 * c2) / denom;
        
        //---------------------------------------------------
        //Do checks to see if intersection to endpoints
        //distance is longer than actual Segments.
        //Return null if it is with any.
        //---------------------------------------------------
        if (asSegments)
        {
            if (pow2(ip.x - x2) + pow2(ip.y - y2) > pow2(x1 - x2) + pow2(y1 - y2)){
                return null;
            }
            if (pow2(ip.x - x1) + pow2(ip.y - y1) > pow2(x1 - x2) + pow2(y1 - y2)){
                return null;
            }
            if (pow2(ip.x - x4) + pow2(ip.y - y4) > pow2(x3 - x4) + pow2(y3 - y4)){
                return null;
            }
            if (pow2(ip.x - x3) + pow2(ip.y - y3) > pow2(x3 - x4) + pow2(y3 - y4)){
                return null;
            }
        }
        return ip;
    }
    
    public static function pow2(value : Float) : Float
    {
        return value * value;
    }
    
    /**
		 * return random int between min and max
		 */
    public static function randomInt(min : Int, max : Int) : Int
    {
        return Std.int(Math.floor(Math.random() * (1 + max - min)) + min);
    }
    
    public static function abs(num : Float) : Float
    {
        return (num < 0) ? -num : num;
    }
    
    //robert penner's formula for a log of variable base
    public static function logx(val : Float, base : Float = 10) : Float
    {
        return Math.log(val) / Math.log(base);
    }
    
    /**
		 * http://www.robertpenner.com/easing/
		 * t current time
		 * b start value
		 * c change in value
		 * d duration
		 */
    
    public static function easeInQuad(t : Float, b : Float, c : Float, d : Float) : Float
    {
        return c * (t /= d) * t + b;
    }
    public static function easeOutQuad(t : Float, b : Float, c : Float, d : Float) : Float
    {
        return -c * (t /= d) * (t - 2) + b;
    }
    public static function easeInCubic(t : Float, b : Float, c : Float, d : Float) : Float
    {
        return c * (t /= d) * t * t + b;
    }
    public static function easeOutCubic(t : Float, b : Float, c : Float, d : Float) : Float
    {
        return c * ((t = t / d - 1) * t * t + 1) + b;
    }
    public static function easeInQuart(t : Float, b : Float, c : Float, d : Float) : Float
    {
        return c * (t /= d) * t * t * t + b;
    }
    public static function easeOutQuart(t : Float, b : Float, c : Float, d : Float) : Float
    {
        return -c * ((t = t / d - 1) * t * t * t - 1) + b;
    }

    public function new()
    {
    }
}

