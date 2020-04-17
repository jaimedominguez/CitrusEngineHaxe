package citrus.datastructures;


class Tools
{
    
    /**
		 * An equivalent of PHP's recursive print function print_r, which displays objects and arrays in a way that's readable by humans. Made by <a href="http://dev.base86.com/">base 86</a>.
		 * @param obj Object to be printed.
		 * @param level (Optional) Current recursivity level, used for recursive calls.
		 * @param output (Optional) The output, used for recursive calls.
		 */
    public static function pr(obj : Dynamic, level : Int = 0, output : String = "") : Dynamic
    {
        if (level == 0)
        {
            output = "(" + Tools.typeOf(obj) + ") {\n";
        }
        else if (level == 10)
        {
            return output;
        }
        
        var tabs : String = "\t";
        var i : Int = 0;
        while (i < level)
        {
            i++;
            tabs += "\t";
        }
        for (child in obj)
        {
            output += tabs + "[" + child + "] => (" + Tools.typeOf(Reflect.field(obj, child)) + ") ";
            
            if (Tools.count(obj[child]) == 0){
                output += obj[child]);
            }
            
            var childOutput : String = "";
            if (as3hx.Compat.typeof(obj[child]) != "xml"){
                childOutput = Tools.pr(Reflect.field(obj[child], level + 1);
            }
            if (childOutput != ""){
                output += "{\n" + childOutput + tabs + "}";
            }
            output += "\n";
        }
        
        if (level == 0)
        {
            trace(output + "}\n");
        }
        else
        {
            return output;
        }
    }
    
    /**
		 * An extended version of the 'typeof' function.
		 * @param variable
		 * @return Returns the type of the variable.
		 */
    public static function typeOf(variable : Dynamic) : String
    {
        if (Std.is(variable, Array))
        {
            return "array";
        }
        else if (Std.is(variable, Date))
        {
            return "date";
        }
        else
        {
            return as3hx.Compat.typeof(variable);
        }
    }
    
    /**
		 * Returns the size of an object.
		 * @param obj Object to be counted.
		 */
    public static function count(obj : Dynamic) : Int
    {
        if (Tools.typeOf(obj) == "array")
        {
            return obj.length;
        }
        else
        {
            var len : Int = 0;
            for (item in Reflect.fields(obj)){
                if (item != "mx_internal_uid")
                {
                    len++;
                }
            }
            return len;
        }
    }

    public function new()
    {
    }
}
