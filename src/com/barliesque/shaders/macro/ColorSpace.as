package com.barliesque.shaders.macro {
	import com.barliesque.agal.EasierAGAL;
	import com.barliesque.agal.IComponent;
	import com.barliesque.agal.IField;
	import com.barliesque.agal.IRegister;
	import com.barliesque.agal.RegisterType;
	
	/**
	 * A collection of macros handling conversion between RGB and HSL color space, as well as additional functions to alter the range of colors of an image.
	 * @author David Barlia
	 */
	public class ColorSpace extends EasierAGAL {
		
		/**
		 * Convert an RGB color value to HSL (Hue, Saturation, Luminance) color space.
		 * [41 operations]
		 * @param	dest	Register to store resulting HSL color value
		 * @param	source	Register containing an RGB color value
		 * @param	zero	A component containing the value:  0.0
		 * @param	two		A component containing the value:  2.0
		 * @param	half	A component containing the value:  0.5
		 * @param	temp	A temporary register to be used by this operation
		 * @param	temp2	A temporary register to be used by this operation
		 * @param	temp3	A temporary register to be used by this operation
		 */
		static public function rgb2hsl(dest:IRegister, source:IRegister,
										zero:IComponent, two:IComponent, half:IComponent, 
										temp:IRegister, temp2:IRegister, temp3:IRegister):void {
			
			var hue:IComponent = dest.x;
			var sat:IComponent = dest.y;
			var lum:IComponent = dest.z;
			
			var minRGB:IComponent = temp3.x;
			var maxRGB:IComponent = temp3.y;
			var delta:IComponent = temp3.z;
			
			comment("--- RGB to HSL ---");
			
			// Find highest and lowest channel values, and delta
			min(minRGB, source.r, source.g);
			min(minRGB, minRGB, source.b);
			max(maxRGB, source.r, source.g);
			max(maxRGB, maxRGB, source.b);
			subtract(delta, maxRGB, minRGB);
			
			// Set the LUMINANCE:  (Max + Min) / 2
			add(lum, minRGB, maxRGB);
			divide(lum, lum, two);
			
			// Set the SATURATION = (lum < 0.5) ? (Delta / (Max + Min)) : (Delta / (2.0 - Max - Min))
			add(temp.x, maxRGB, minRGB);
			divide(temp.x, delta, temp.x);
			
			subtract(temp.y, two, maxRGB);
			subtract(temp.y, temp.y, minRGB);
			divide(temp.y, delta, temp.y);
			
			Utils.setByComparison(sat, lum, Utils.LESS_THAN, half, temp.x, temp.y, temp2);
			
			// Set the HUE
			setIf_Equal(temp.rgb, source.rgb, maxRGB);
			setIf_NotEqual(temp.w, temp.x, temp.y);
			min(temp.y, temp.y, temp.w);  // G can only be true if R is not also true
			setIf_NotEqual(temp.w, temp.x, temp.z);
			min(temp.z, temp.z, temp.w);  // B can only be true if R is not also true
			setIf_NotEqual(temp.w, temp.y, temp.z);
			min(temp.z, temp.z, temp.w);  // B can only be true if G is not also true
			
			// if (r is max) hue = (((g - b) / delta)) / 6.0
			// if (g is max) hue = (((b - r) / delta) + 2.0) / 6.0
			// if (b is max) hue = (((r - g) / delta) + 4.0) / 6.0
			subtract(temp2.rgb, source._("yzx"), source._("zxy"));
			divide(temp2.rgb, temp2.rgb, delta);
			// Add 2.0 and 4.0 to G and B, respectively
			move(temp2.w, zero);
			add(temp2.y, temp2.y, two);
			add(temp2.z, temp2.z, two);
			add(temp2.z, temp2.z, two);
			
			move(temp2.w, two);
			add(temp2.w, temp2.w, two);
			add(temp2.w, temp2.w, two);
			// Divide all three by 6
			divide(temp2.rgb, temp2.rgb, temp2.w);
			
			// Multiply three possible outcomes by boolean selection, and the sum is our result
			multiply(temp.rgb, temp.rgb, temp2.rgb);
			add(hue, temp.x, temp.y);
			add(hue, hue, temp.z);
			
			// Color wheel wraps around...  if (hue < 0.0) hue += 1.0
			setIf_LessThan(temp.x, hue, zero);
			add(hue, hue, temp.x);
			
			// Copy the source alpha
			move(dest.w, source.w);
		}
		
		
		/**
		 * Convert an HSL color value to RGB color space
		 * [42 operations]
		 * @param	dest		Register to store the resulting RGB color value
		 * @param	source		Register containing an HSL color value
		 * @param	zero		A component containing the value:  0.0
		 * @param	one			A component containing the value:  1.0
		 * @param	two			A component containing the value:  2.0
		 * @param	half		A component containing the value:  0.5
		 * @param	oneThird	A component containing the value:  1/3
		 * @param	oneSixth	A component containing the value:  1/6
		 * @param	twoThirds	A component containing the value:  2/3
		 * @param	temp		A temporary register to be used by this operation
		 * @param	temp2		A temporary register to be used by this operation
		 * @param	temp3		A temporary register to be used by this operation
		 * @param	temp4		A temporary register to be used by this operation
		 */
		static public function hsl2rgb(dest:IRegister, source:IRegister, 
			zero:IComponent, one:IComponent, two:IComponent, half:IComponent, oneThird:IComponent, oneSixth:IComponent, twoThirds:IComponent,
			temp:IRegister, temp2:IRegister, temp3:IRegister, temp4:IRegister):void {
			
			var hue:IComponent = source.r;
			var sat:IComponent = source.g;
			var lum:IComponent = source.b;
			
			var m1:IComponent = temp2.x;
			var m2:IComponent = temp2.y;
			var m2minusM1:IComponent = temp2.z;
			
			var hueRGB:IField = temp3.xyz;
			
			comment("--- HSL to RGB ---");
			
			// m2 = (lum < 0.5) ? (lum * (1 + sat)) : (lum + sat - (lum * sat))
			add(temp.x, one, sat);
			multiply(temp.x, temp.x, lum);
			multiply(temp.y, lum, sat);
			subtract(temp.y, sat, temp.y);
			add(temp.y, temp.y, lum);
			
			setIf_LessThan(m2, lum, half);
			multiply(temp.x, temp.x, m2);
			setIf_GreaterEqual(m2, lum, half);
			multiply(temp.y, temp.y, m2);
			add(m2, temp.x, temp.y)
			
			// m1 = (2 * lum) - m2
			multiply(m1, two, lum);
			subtract(m1, m1, m2);
			
			// m2minusM1 = (m2 - m1)
			subtract(m2minusM1, m2, m1);
			
			//(y)hue1 =        hue
			//(x)hue2 =        hue + (hue < 2/3 ? 1 : 0) - 2/3
			//(z)hue3 = max(0, hue - 1/3)
			move(temp3.y, hue);
			subtract(temp3.x, hue, twoThirds);
			setIf_LessThan(temp3.w, temp3.x, zero);
			add(temp3.x, temp3.x, temp3.w);
			subtract(temp3.z, hue, oneThird);
			max(temp3.z, temp3.z, zero);
			
			// q3 test: (hue >= 1/2 && hue < 2/3)
			setIf_GreaterEqual(dest.rgb, hueRGB, half);
			setIf_LessThan(temp.xyz, hueRGB, twoThirds);
			min(dest.rgb, dest.rgb, temp.xyz);  // AND
			// calculate q3 for all three channels
			// q3 = ((2/3) - Hue) * (M2 - M1) * 6.0 + M1
			subtract(temp.xyz, twoThirds, hueRGB);
			multiply(temp.xyz, temp.xyz, m2minusM1);
			divide(temp.xyz, temp.xyz, oneSixth);
			add(temp.xyz, temp.xyz, m1);
			// multiply by test, directly into dest.rgb
			multiply(dest.rgb, dest.rgb, temp.xyz);
			
			// calculate q1 for all three channels
			// q1 = ((M2 - M1) * 6.0 * Hue + M1)
			multiply(temp.xyz, m2minusM1, hueRGB);
			divide(temp.xyz, temp.xyz, oneSixth);
			add(temp.xyz, temp.xyz, m1);
			// multiply by test: (hue < 1/6)
			setIf_LessThan(temp4.xyz, hueRGB, oneSixth);
			multiply(temp.xyz, temp.xyz, temp4.xyz);
			// add result to dest.rgb
			add(dest.rgb, dest.rgb, temp.xyz);
			
			// q2 test: (hue >= 1/6 && hue < 1/2)
			setIf_GreaterEqual(temp4.xyz, hueRGB, oneSixth);
			setIf_LessThan(temp.xyz, hueRGB, half);
			min(temp.xyz, temp4.xyz, temp.xyz);
			// q2 = m2 for all three channels
			// multiply by test
			multiply(temp.xyz, temp.xyz, m2);
			// add result to dest.rgb
			add(dest.rgb, dest.rgb, temp.xyz);
			
			// q4 = m1 for all three channels
			// multiply by test: (hue >= 2/3)
			setIf_GreaterEqual(temp.xyz, hueRGB, twoThirds);
			multiply(temp.xyz, temp.xyz, m1);
			// add result to dest.rgb
			add(dest.rgb, dest.rgb, temp.xyz);
		}
		
		
		/**
		 * Fix pre-multiplied color values
		 * [2 operations]
		 * @param	dest	Destination register
		 * @param	source	Source register
		 */
		static public function unPreMultiply(dest:IRegister, source:IRegister):void {
			divide(dest.rgb, source.rgb, source.a);
			if (dest != source) {
				move(dest.a, source.a);
			}
		}
		
		
		/**
		 * Desaturates an RGB value to grayscale, optionally by a specified percentage.
		 * [5 to 11 operations]
		 * @param	dest		Register to store the resulting desaturated RGB color value
		 * @param	source		Register containing an RGB color value
		 * @param	temp		A temporary register to be used by this operation
		 * @param	pointOne	A component containing the value:  0.1
		 * @param	percent		(optional) A component containing a value from 0.0 (no desaturation) to 1.0 (fully desaturated)
		 * @param	one			A component containing the value:  1.0  (Required only if a percent is specified)
		 */
		static public function desaturate(dest:IRegister, source:IRegister, temp:IRegister, pointOne:IComponent, percent:IComponent = null, one:IComponent = null):void {
			
			// Set channel multipliers
			move(temp.z, pointOne);				// 10% Blue
			add(temp.x, temp.z, pointOne);
			add(temp.x, temp.x, pointOne);		// 30% Red
			add(temp.y, temp.x, temp.x);		// 60% Green
			
			// Multiply and combine
			dotProduct3(dest.rgb, source.rgb, temp.rgb);
			
			// How much to desaturate?
			if (percent) {
				if (one == null) throw new Error("Parameter 'one' is required with parameter 'percent'");
				
				// temp = (1 - percent) * source
trace(RegisterType.isConst(one), RegisterType.isConst(percent));
				if (RegisterType.isConst(one) && RegisterType.isConst(percent)) {
					move(temp.rgb, one);
					subtract(temp.rgb, temp.rgb, percent);
				} else {
					subtract(temp.rgb, one, percent);
				}
				multiply(temp.rgb, temp.rgb, source.rgb);
				// dest = (desaturated * percent) + ((1 - percent) * source)
				multiply(dest.rgb, dest.rgb, percent);
				add(dest.rgb, dest.rgb, temp.rgb);
			}
			
			// Alpha stays the same
			if (dest != source) {
				move(dest.a, source.a);
			}
		}
		
		
		/**
		 * Reduces the range of color possibilities, turning smooth gradients into flat color bands.
		 * This can be used with either RGB or HSL color values, producing different effects.
		 * Note that this is a simplified form of posterization that does not base its output pallet 
		 * on a selection of colors from the original image, like the posterize effect in Photoshop.
		 * [4 operations]
		 * @param	dest		Register to store resulting color
		 * @param	source		Register containing the original color value
		 * @param	bands		A component containing the total number of color bands (per channel)
		 * @param	temp		A temporary register to be utilized for this calculation
		 */
		static public function posterize(dest:IRegister, source:IRegister, bands:IComponent, temp:IRegister):void {
			multiply(dest.rgb, source.rgb, bands);
			fractional(temp.rgb, dest.rgb);
			subtract(dest.rgb, dest.rgb, temp.rgb);
			divide(dest.rgb, dest.rgb, bands);
		}
		
		
		/**
		 * Colorizes an RGB value with a specified tint RGB color, optionally to a specified percentage.
		 * [12 Operations]
		 * @param	dest		Register to store the reulting RGB color
		 * @param	source		Register containing the source RGB color value
		 * @param	tint		Register containing the tint RGB color value to be combined with the luminance of the original
		 * @param	temp		A temporary register to be used by this operation
		 * @param	pointOne	A component containing the value:  0.1
		 * @param	percent		(optional) A component containing a value from 0.0 (no colorization) to 1.0 (fully colorized)
		 * @param	one			A component containing the value:  1.0  (Required only if a percent is specified)
		 */
		static public function colorize(dest:IRegister, source:IRegister, tint:IRegister, temp:IRegister, pointOne:IComponent, percent:IComponent = null, one:IComponent = null):void {
			
			// Calculate the luminance of the source color
			// ...Set channel multipliers
			move(temp.b, pointOne);				// 10% Blue
			add(temp.r, temp.b, pointOne);
			add(temp.r, temp.r, pointOne);		// 30% Red
			add(temp.g, temp.r, temp.r);		// 60% Green
			// Multiply and combine to find luminance
			dotProduct3(dest.rgb, source.rgb, temp.rgb);
			
			// Multiply the luminance with the colorization color
			multiply(dest.rgb, dest.rgb, tint.rgb);
			
			// How much to colorize?
			if (percent) {
				if (one == null) throw new Error("Parameter 'one' is required with parameter 'percent'");
				
				// temp = (1 - percent) * source
				if (RegisterType.isConst(one) && RegisterType.isConst(percent)) {
					move(temp.rgb, one);
					subtract(temp.rgb, temp.rgb, percent);
				} else {
					subtract(temp.rgb, one, percent);
				}
				multiply(temp.rgb, temp.rgb, source.rgb);
				// dest = (colorized * percent) + ((1 - percent) * source)
				multiply(dest.rgb, dest.rgb, percent);
				add(dest.rgb, dest.rgb, temp.rgb);
			}
			
			// Alpha stays the same
			if (dest != source) {
				move(dest.a, source.a);
			}
		}
		
		
	}
}