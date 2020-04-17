package citrus.input;


class InputPhase
{
    
    /**
		 * Action started in this frame.
		 * will be advanced to BEGAN on next frame.
		 */
    public static inline var BEGIN : Int = 0;
    
    /**
		 * Action started in previous frame and hasn't changed value.
		 * will be advanced to ON on next frame.
		 */
    public static inline var BEGAN : Int = 1;
    
    /**
		 * The "stable" phase, action began, its value may have been changed by the CHANGE signal.
		 * an action with this phase can only be advanced by an OFF signal, to phase END ; otherwise it stays in the system.
		 */
    public static inline var ON : Int = 2;
    
    /**
		 * Action has been triggered OFF in the current frame.
		 * will be advanced to ENDED on next frame.
		 */
    public static inline var END : Int = 3;
    
    /**
		 * Action has been triggered OFF in the previous frame, and will be disposed of in this frame.
		 */
    public static inline var ENDED : Int = 4;

    public function new()
    {
    }
}

