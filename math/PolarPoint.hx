package citrus.math;


/**
	 * A simple class to create points with polar coordinates.
	 * It holds radius and angle of the point in polar coordinates and helps going back and forth to cartesian coordinates.
	 * The flash point can create a Point from polar coordinates but will lose its polar properties (radius and angle)
	 * and will only have x and y in cartesiand coordinates when set.
	 * 
	 * so in your polar coordinates world this PolarPoint class is a solution to keep your polar coordinate data
	 * and do further computation with them.
	 * 
	 * /!\ WARNING : if you are going to intensively convert to and from cartesian coordinates, you are bound to lose
	 * precision .
	 * 
	 * (may need optimisation on the conversions ?)
	 */
class PolarPoint
{
    public var cartX(get, set) : Float;
    public var cartY(get, set) : Float;
    public var r(get, set) : Float;
    public var t(get, set) : Float;

    
    //MAIN POLAR COORDINATES
    private var _r : Float = 0;  // radius  
    private var _t : Float = 0;  // theta (angle)  
    
    //CARTESIAN
    private var _cartX : Float = 0;
    private var _cartY : Float = 0;
    
    private var cartupdated : Bool = true;
    
    //-------------------------------------
    
    /**
		 * Create and return a new PolarPoint
		 * @param	r radius
		 * @param	t angle
		 * @return
		 */
    public static function fromPolar(r : Float, t : Float) : PolarPoint
    {
        return new PolarPoint(r, t);
    }
    
    /**
		 * Create and return new PolarPoint from cartesian coordinates
		 * @param	x
		 * @param	y
		 * @return
		 */
    public static function fromCartesian(x : Float, y : Float) : PolarPoint
    {
        var pc : PolarPoint = new PolarPoint(0, 0);
        pc.setFromCartesian(x, y);
        return pc;
    }
    
    //-----------------------------------
    
    /**
		 * Create a new PolarPoint from radius and angle
		 * @param	r radius
		 * @param	t angle in radian
		 */
    public function new(r : Float, t : Float)
    {
        _r = r;
        _t = t % (2 * Math.PI);
        updatecartesian();
    }
    
    /**
		 * updates cartesian coordinates from polar coordinates.
		 */
    private function updatecartesian() : Void {
        _cartX = _r * Math.cos(_t);
        _cartY = _r * Math.sin(_t);
        cartupdated = true;
    }
    
    /**
		 * cartesian position on the X axis. (converted)
		 */
   public function get_cartX() : Float
    {
        if (!cartupdated)
        {
            _cartX = _r * Math.cos(_t);
        }
        return _cartX;
    }
    
    /**
		 * cartesian position on the Y axis. (converted)
		 */
   public function get_cartY() : Float
    {
        if (!cartupdated)
        {
            _cartY = _r * Math.sin(_t);
        }
        return _cartY;
    }
    
    /**
		 * Radius.
		 */
   public function get_r() : Float
    {
        return _r;
    }
    
    /**
		 * Angle in radian.
		 */
   public function get_t() : Float
    {
        return _t;
    }
    
   public function set_r(value : Float) : Float
    {
        cartupdated = false;
        _r = value;
        return value;
    }
    
   public function set_t(value : Float) : Float
    {
        cartupdated = false;
        _t = value;
        return value;
    }
    
   public function set_cartX(value : Float) : Float
    {
        cartupdated = true;
        _cartX = value;
        return value;
    }
    
   public function set_cartY(value : Float) : Float
    {
        cartupdated = true;
        _cartY = value;
        return value;
    }
    
    /**
		 * returns a new PolarPoint with the same values
		 * @return
		 */
    public function clone() : PolarPoint
    {
        var pc : PolarPoint = new PolarPoint(this.r, this.t);
        return pc;
    }
    
    /**
		 * Add a polar point's coordinates to this point by going through the cartesian values.
		 * @param	polarPoint
		 */
    public function add(polarPoint : PolarPoint) : Void {
        setFromCartesian(cartX + polarPoint.cartX, cartY + polarPoint.cartY);
        updatecartesian();
    }
    
    /**
		 * Substract a polar point's coordinates to this point by going through the cartesian values.
		 * @param	polarPoint
		 */
    public function sub(polarPoint : PolarPoint) : Void {
        setFromCartesian(cartX - polarPoint.cartX, cartY - polarPoint.cartY);
        updatecartesian();
    }
    
    /**
		 * set the point's values
		 * @param	r radius
		 * @param	t angle in radian
		 */
    public function set(r : Float, t : Float) : Void {
        _r = r;
        _t = t;
        updatecartesian();
    }
    
    public function setFromCartesian(x : Float, y : Float) : Void {
        _r = Math.sqrt((x * x) + (y * y));
        if (x < 0)
        {
            _t = (Math.atan(y / x) - Math.PI);
        }
        else
        {
            _t = (Math.atan(y / x));
        }
    }
    
    public function toString() : String
    {
        return "x:" + cartX + " y:" + cartY + " r:" + r + " t:" + t;
    }
}

