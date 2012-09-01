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
			comment(dest.code + " = tan(" + source.code + ")");
			
			sin(dest, source);
			cos(temp, source);
			divide(dest, dest, temp);
			
			comment();
		}
		
		
		/**
		 * atan:  Find the inverse (or arc-) tangent of a specified tangent
		 * [4 Operations]
		 * @param	dest	Destination of the resulting value in radians
		 * @param	source	A component containing the input tanget value
		 * @param	one		A component containing the constant value:  1.0
		 * @param	halfPi	A component containing the constant value:  (Math.PI / 2.0)
		 */
		static public function atan(dest:IField, source:IField, one:IComponent, halfPi:IComponent):void {
			comment(dest.code + " = atan(" + source.code + ")");
			
			// atan(x) = (Pi / 2) * x / (1 + abs(x))
			abs(dest, source);
			add(dest, dest, one);
			divide(dest, source, dest);
			multiply(dest, dest, halfPi);
			
			comment();
		}
		
		
		/**
		 * atan2:  Find the inverse (or arc-) tangent of a specified vector
		 * [22 Operations]
		 * @param	dest			Destination of the resulting value in radians
		 * @param	vecY			The Y component of the input vector
		 * @param	vecX			The X component of the input vector
		 * @param	temp1			A temporary register to be used for this calculation
		 * @param	temp2			A temporary register to be used for this calculation
		 * @param	quarterPi		A component containing the constant value:  (Math.PI / 4.0)
		 * @param	sixteenthPi		A component containing the constant value:  (Math.PI / 16.0)
		 * @param	tiny			A component containing the constant value:  Number.MIN_VALUE
		 */
		static public function atan2(dest:IField, vecY:IComponent, vecX:IComponent, 
										temp1:IRegister, temp2:IRegister,
										quarterPi:IComponent,  sixteenthPi:IComponent, tiny:IComponent):void {
			
			comment(dest.code + " = atan2(" + vecX.code + ", " + vecY.code + ")");
			
			move(temp2, vecX);								// [x, x, x, x]
			move(temp2.y, vecY);							// [x, y, x, x]
			subtract(temp2.zw, temp2.zw, temp2.x);			// [x, y, 0, 0]
			setIf_GreaterEqual(temp2, temp2, temp2.z);		// temp2 = { x: (vecX >= 0), y: (vecY >= 0), z: 1, w: 1 }
			
			add( temp2._("xyw"), temp2._("xyw"), temp2._("xyw"));
			subtract(temp2.xy, temp2.xy, temp2._("zz"));	// temp2 = [sgn(x), sgn(y), 1, 2]
			subtract(temp2.w, temp2.w, 	temp2.x);			// temp2.w = 2 - sgn(x)
			multiply(temp2.w, temp2.w, quarterPi);			// temp2.w = (2 - sgn(x)) * pi/4
			
			multiply(temp2.z, temp2.y, vecY);				// r = y * signY
			add(temp2.z, temp2.z, tiny);					// r = y * signY + insignificant value (to avoid divide by zero)
			
			multiply(temp1.w, temp2.x, temp2.z);			// t1w = signX * r
			subtract(temp1.w, vecX, temp1.w);				// t1w = (x - signX * r)
			multiply(temp1.y, temp2.x, vecX);				// t1y = signX * x
			add(temp1.y, temp1.y, temp2.z);					// t1y = (signX * x + r)
			divide(temp2.z, temp1.w, temp1.y);				// r = (x - signX * r) / (signX * x + r)
			
			multiply(dest, temp2.z, temp2.z);				// dest = r * r  
			multiply(dest, dest, sixteenthPi);				// dest = pi/16 * r * r  
			subtract(dest, dest, quarterPi);				// dest = (pi/16 * r * r - pi/4)  
			subtract(dest, dest, sixteenthPi);				// dest = (pi/16 * r * r - pi/4)  
			multiply(dest, dest, temp2.z);					// dest = (pi/16 * r * r - pi/4) * r  
			
			add(dest, dest, temp2.w);						// dest = (2 - sgn(x)) * pi/4 + (pi/16 * r * r - pi/4) * r  
			multiply(dest, dest, temp2.y);					// dest = ((2 - sgn(x)) * pi/4 + (pi/16 * r * r - pi/4) * r) * sgn(y)
			
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
			comment(dest.code + " = tanh(" + source.code + ")");
			
			// tanh(x) = (pow(E, 2*x) - 1) / (pow(E, 2*x) + 1)
			add(temp, source, source);
			pow(temp, euler, temp);
			subtract(dest, temp, one);
			add(temp, temp, one);
			divide(dest, dest, temp);
			
			comment();
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
			comment(dest.code + " = atanh(" + source.code + ")");
			
			//  atanh(x) = 0.5 * log((1.0 + x) / (1.0 - x))
			add(temp, source, one);
			subtract(dest, source, one);
			divide(dest, temp, dest);
			log(dest, dest);
			multiply(dest, dest, half);
			
			comment();
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
			comment(dest.code + " = acos(" + source.code + ")");
			
			// acos(x) = (-(PI/4.5) * x * x - (PI/3.6)) * x + (PI/2)
			multiply(dest, piDiv4p5, source);
			multiply(dest, dest, source);
			negate(dest, dest);
			subtract(dest, dest, piDiv3p6);
			multiply(dest, dest, source);
			add(dest, dest, halfPi);
			
			comment();
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
			comment(dest.code + " = cosh(" + source.code + ")");
			
			// cosh(x) = (pow(E, x) + pow(E, -x)) * 0.5
			negate(temp, source);
			pow(temp, euler, temp);
			pow(dest, euler, source);
			add(dest, dest, temp);
			multiply(dest, dest, half);
			
			comment();
		}
		
		
		/**
		 * Calculate the inverse (or arc-) hyperbolic-cosine
		 * [4 operations]
		 * @param	dest		Destination of the resulting value in radians
		 * @param	source		A component containing the input hyperbolic-cosine value
		 * @param	one			A component containing the constant value:  1.0
		 */
		static public function acosh(dest:IField, source:IField, one:IComponent):void {
			comment(dest.code + " = acosh(" + source.code + ")");
			
			// acosh(x) = log(x + sqrt(x*x - 1))
			multiply(dest, source, source);
			subtract(dest, dest, one);
			squareRoot(dest, dest);
			log(dest, dest);
			
			comment();
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
			comment(dest.code + " = asin(" + source.code + ")");
			
			// asin(x) = ((PI/4.5) * a * a + (PI/3.6)) * a
			multiply(dest, piDiv4p5, source);
			multiply(dest, dest, source);
			add(dest, dest, piDiv3p6);
			multiply(dest, dest, source);
			
			comment();
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
			comment(dest.code + " = sinh(" + source.code + ")");
			
			// sinh(x) = (pow(E, x) - pow(E, -x)) * 0.5;
			negate(temp, source);
			pow(temp, euler, temp);
			pow(dest, euler, source);
			subtract(dest, dest, temp);
			multiply(dest, dest, half);
			
			comment();
		}
		
		
		/**
		 * Calculate the inverse (or arc-) hyperbolic-sine
		 * [5 operations]
		 * @param	dest		Destination of the resulting value in radians
		 * @param	source		A component containing the input hyperbolic-sine value
		 * @param	one			A component containing the constant value:  1.0
		 */
		static public function asinh(dest:IField, source:IField, one:IComponent):void {
			comment(dest.code + " = asinh(" + source.code + ")");
			
			// asinh(x) = log(x + sqrt(x * x + 1.0));
			multiply(dest, source, source);
			add(dest, dest, one);
			squareRoot(dest, dest);
			add(dest, dest, source);
			log(dest, dest);
			
			comment();
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
			comment(dest.code + " = cotan(" + source.code + ")");
			
			cos(dest, source);
			sin(temp, source);
			divide(dest, dest, temp);
			
			comment();
		}
		
		
		/**
		 * secant(x) = 1 / cos(x)
		 * [2 Operations]
		 * @param	dest		Destination of the resulting value
		 * @param	source		An angle in radians
		 */
		static public function secant(dest:IField, source:IField):void {
			comment(dest.code + " = secant(" + source.code + ")");
			
			cos(dest, source);
			reciprocal(dest, dest);
			
			comment();
		}
		
		
		/**
		 * cosecant(x) = 1 / sin(x)
		 * [2 Operations]
		 * @param	dest		Destination of the resulting value
		 * @param	source		An angle in radians
		 */
		static public function cosecant(dest:IField, source:IField):void {
			comment(dest.code + " = cosecant(" + source.code + ")");
			
			sin(dest, source);
			reciprocal(dest, dest);
			
			comment();
		}
		
		
	}
}