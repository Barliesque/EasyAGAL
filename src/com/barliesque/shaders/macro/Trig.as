package com.barliesque.shaders.macro {
	import com.barliesque.agal.EasierAGAL;
	import com.barliesque.agal.IComponent;
	import com.barliesque.agal.IField;
	import com.barliesque.agal.IRegister;
	
	/**
	 * Macros for trigonometric functions missing from the native AGAL command set.  (More on the way!)
	 * 
	 * @author David Barlia
	 */
	public class Trig extends EasierAGAL {
		
		
		/**
		 * tan:  Find the tangent of a specified angle in radians.
		 * [3 Operations]
		 * @param	dest		Destination of the resulting value
		 * @param	source		An angle in radians
		 * @param	temp		A temporary register to be used for this calculation
		 */
		static public function tan(dest:IField, source:IField, temp:IRegister):void {
			sin(dest, source);
			cos(temp, source);
			divide(dest, dest, temp);
		}
		
		
		/**
		 * atan:  Find the arc-tangent of a specified tangent
		 * [3 Operations]
		 * @param	dest	Destination of the resulting value in radians
		 * @param	source	A component containing the input tanget value
		 * @param	one		A component containing the constant value:  1.0
		 * @param	halfPi	A component containing the constant value:  (Math.PI / 2.0)
		 */
		static public function atan(dest:IField, source:IField, one:IComponent, halfPi:IComponent):void {
			// atan(x) = (Pi / 2) * x / (1 + x)
			add(dest, source, one);
			divide(dest, source, dest);
			multiply(dest, dest, halfPi);
		}
		
		
		/**
		 * atan2:  Find the arc-tangent of a specified vector
		 * [16 Operations]
		 * @param	dest	Destination of the resulting value in radians
		 * @param	vecX	The X component of the input vector
		 * @param	vecY	The Y component of the input vector
		 * @param	zero	A component containing the constant value:  0.0
		 * @param	one		A component containing the constant value:  1.0
		 * @param	halfPi	A component containing the constant value:  (Math.PI / 2.0)
		 * @param	pi		A component containing the constant value:  Math.PI
		 * @param	temp1	A temporary register to be used for this calculation
		 * @param	temp2	A temporary register to be used for this calculation
		 */
		static public function atan2(dest:IField, vecX:IComponent, vecY:IComponent, 
									zero:IComponent, one:IComponent, halfPi:IComponent, pi:IComponent, 
									temp1:IRegister, temp2:IRegister):void {
			
			comment("atan2()");
			divide(temp1.x, vecY, vecX);	// temp1.x = vecY / vecX
			negate(temp1.y, temp1.x);		// temp1.y = -(vecY / vecX)
			
			// temp2.x = atan(x) = (Pi / 2) * x / (1 + x)
			// temp2.y = atan(y) = (Pi / 2) * y / (1 + y)
			add(temp2._("xy"), temp1._("xy"), one);
			divide(temp2._("xy"), temp1._("xy"), temp2._("xy"));
			multiply(temp2._("xy"), temp2._("xy"), halfPi);
			
			// Temp1 = Which quadrant?
			setIf_GreaterEqual(temp1.x, vecX, zero);		// temp1.x = vecX >= 0
			setIf_GreaterEqual(temp1.y, vecY, zero); 		// temp1.y = vecY >= 0
			subtract(temp1._("zw"), one, temp1._("xy"));	// temp1.z = vecX < 0
															// temp1.w = vecY < 0
			// temp1.x = vecX <  0 && vecY <  0
			// temp1.y = vecX >= 0 && vecY <  0
			// temp1.z = vecX >= 0 && vecY >= 0
			// temp1.w = vecX <  0 && vecY >= 0
			multiply(temp1._("xyzw"), temp1._("zxxz"), temp1._("wwyy"));
			
			// Temp2 = angle results for each of the four quadrants
			move(temp2.z, temp2.x);				// temp2.z = temp2.x
			subtract(temp2.w, pi, temp2.y);		// temp2.w = Pi - temp2.y
			subtract(temp2.x, temp2.x, pi);		// temp2.x = temp2.x - Pi
			negate(temp2.y, temp2.y);			// temp2.y = -temp2.y
			
			// Multiply quadrant booleans with quadrant angles
			multiply(temp1, temp1, temp2);
			// All but one product will be zero - Add them all together for final answer
			add(temp1._("xy"), temp1._("xy"), temp1._("zy"));
			add(dest, temp1.x, temp1.y);
			
			comment();
		}
		
		
	}
}