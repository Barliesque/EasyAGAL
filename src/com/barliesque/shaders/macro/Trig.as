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
		 * atan:  Find the inverse (or arc-) tangent of a specified tangent
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
		 * atan2:  Find the inverse (or arc-) tangent of a specified vector
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
		
		
		/**
		 * Calculate the hyperbolic tangent of a given angle in radians
		 * [5 operations]
		 * @param	dest		Destination of the resulting value
		 * @param	source		A component containing the input angle in radians
		 * @param	one			A component containing the constant value:  1.0
		 * @param	euler		A component containing the constant value:  Math.E  (Euler's constant, or 2.71828182845904523536)
		 */
		static public function tanh(dest:IField, source:IField, one:IComponent, euler:IComponent, temp:IRegister):void {
			// tanh(x) = (pow(E, 2*x) - 1) / (pow(E, 2*x) + 1)
			add(temp, source, source);
			pow(temp, euler, temp);
			subtract(dest, temp, one);
			add(temp, temp, one);
			divide(dest, dest, temp);
		}
		
		
		/**
		 * Calculate the inverse (or arc-) hyperbolic tangent
		 * [5 operations]
		 * @param	dest		Destination of the resulting value
		 * @param	source		A component containing the input angle in radians
		 * @param	one			A component containing the constant value:  1.0
		 * @param	half		A component containing the constant value:  0.5
		 * @param	temp		A temporary register to be used for this calculation
		 */
		static public function atanh(dest:IField, source:IField, one:IComponent, half:IComponent, temp:IRegister):void {
			//  atanh(x) = 0.5 * log((1.0 + x) / (1.0 - x))
			add(temp, source, one);
			subtract(dest, source, one);
			divide(dest, temp, dest);
			log(dest, dest);
			multiply(dest, dest, half);
		}
		
		
		//-------------------------------------------------
		
		
		/**
		 * Caclulate the inverse (or arc-) cosine, to a maximum error +/-0.17 radians (2.8%)
		 * [6 operations]
		 * @param	dest		Destination of the resulting value in radians
		 * @param	source		A component containing the input cosine value
		 * @param	piDiv4p5	A component containing the constant value:  (Math.PI / 4.5)
		 * @param	piDiv3p6	A component containing the constant value:  (Math.PI / 3.6)
		 * @param	halfPi		A component containing the constant value:  (Math.PI / 2.0)
		 */
		static public function acos(dest:IField, source:IField, piDiv4p5:IComponent, piDiv3p6:IComponent, halfPi:IComponent):void {
			// acos(x) = (-(PI/4.5) * x * x - (PI/3.6)) * x + (PI/2)
			multiply(dest, piDiv4p5, source);
			multiply(dest, dest, source);
			negate(dest, dest);
			subtract(dest, dest, piDiv3p6);
			multiply(dest, dest, source);
			add(dest, dest, halfPi);
		}
		
		
		/**
		 * Calculate the hyperbolic-cosine of a given angle in radians
		 * [5 operations]
		 * @param	dest	Destination of the resulting value
		 * @param	source	A component containing the input angle in radians
		 * @param	half	A component containing the constant value:  0.5
		 * @param	euler	A component containing the constant value:  Math.E  (Euler's constant, or 2.71828182845904523536)
		 * @param	temp	A temporary register to be used for this calculation
		 */
		static public function cosh(dest:IField, source:IField, half:IComponent, euler:IComponent, temp:IRegister):void {
			// cosh(x) = (pow(E, x) + pow(E, -x)) * 0.5
			negate(temp, source);
			pow(temp, euler, temp);
			pow(dest, euler, source);
			add(dest, dest, temp);
			multiply(dest, dest, half);
		}
		
		
		/**
		 * Calculate the inverse (or arc-) hyperbolic-cosine
		 * [4 operations]
		 * @param	dest		Destination of the resulting value in radians
		 * @param	source		A component containing the input hyperbolic-cosine value
		 * @param	one			A component containing the constant value:  1.0
		 */
		static public function acosh(dest:IField, source:IField, one:IComponent):void {
			// acosh(x) = log(x + sqrt(x*x - 1))
			multiply(dest, source, source);
			subtract(dest, dest, one);
			squareRoot(dest, dest);
			log(dest, dest);
		}
		
		
		//-------------------------------------------------
		
		
		/**
		 * Calculate the inverse (or arc-) sine, to a maximum error +/-0.17 radians (2.8%)
		 * [4 operations]
		 * @param	dest		Destination of the resulting value in radians
		 * @param	source		A component containing the input sine value
		 * @param	piDiv4p5	A component containing the constant value:  (Math.PI / 4.5)
		 * @param	piDiv3p6	A component containing the constant value:  (Math.PI / 3.6)
		 */
		static public function asin(dest:IField, source:IField, piDiv4p5:IComponent, piDiv3p6:IComponent):void {
			// asin(x) = ((PI/4.5) * a * a + (PI/3.6)) * a
			multiply(dest, piDiv4p5, source);
			multiply(dest, dest, source);
			add(dest, dest, piDiv3p6);
			multiply(dest, dest, source);
		}
		
		
		/**
		 * Calculate the hyperbolic-sine of a given angle in radians
		 * [5 Operations]
		 * @param	dest		Destination of the resulting value
		 * @param	source		A component containing the input angle in radians
		 * @param	half		A component containing the constant value:  0.5
		 * @param	euler		A component containing the constant value:  Math.E  (Euler's constant, or 2.71828182845904523536)
		 */
		static public function sinh(dest:IField, source:IField, half:IComponent, euler:IComponent, temp:IRegister):void {
			// sinh(x) = (pow(E, x) - pow(E, -x)) * 0.5;
			negate(temp, source);
			pow(temp, euler, temp);
			pow(dest, euler, source);
			subtract(dest, dest, temp);
			multiply(dest, dest, half);
		}
		
		
		/**
		 * Calculate the inverse (or arc-) hyperbolic-sine
		 * [5 operations]
		 * @param	dest		Destination of the resulting value in radians
		 * @param	source		A component containing the input hyperbolic-sine value
		 * @param	one			A component containing the constant value:  1.0
		 */
		static public function asinh(dest:IField, source:IField, one:IComponent):void {
			// asinh(x) = log(x + sqrt(x * x + 1.0));
			multiply(dest, source, source);
			add(dest, dest, one);
			squareRoot(dest, dest);
			add(dest, dest, source);
			log(dest, dest);
		}
		
		
		//-------------------------------------------------
		
		
		/**
		 * cot:  Find the co-tangent of a specified angle in radians.
		 * [3 Operations]
		 * @param	dest		Destination of the resulting value
		 * @param	source		An angle in radians
		 * @param	temp		A temporary register to be used for this calculation
		 */
		static public function cotan(dest:IField, source:IField, temp:IRegister):void {
			cos(dest, source);
			sin(temp, source);
			divide(dest, dest, temp);
		}
		
		
		/**
		 * secant(x) = 1 / cos(x)
		 * [2 Operations]
		 * @param	dest		Destination of the resulting value
		 * @param	source		An angle in radians
		 */
		static public function secant(dest:IField, source:IField):void {
			cos(dest, source);
			reciprocal(dest, dest);
		}
		
		
		/**
		 * cosecant(x) = 1 / sin(x)
		 * [2 Operations]
		 * @param	dest		Destination of the resulting value
		 * @param	source		An angle in radians
		 */
		static public function cosecant(dest:IField, source:IField):void {
			sin(dest, source);
			reciprocal(dest, dest);
		}
		
		
	}
}