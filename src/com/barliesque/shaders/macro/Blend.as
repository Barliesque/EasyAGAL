package com.barliesque.shaders.macro {
	import com.barliesque.agal.EasierAGAL;
	import com.barliesque.agal.IComponent;
	import com.barliesque.agal.IField;
	import com.barliesque.agal.IRegister;
	
	/**
	 * A library of macros to handle blend modes found in Photoshop, Gimp and others.
	 * Alpha is not evaluated.
	 * 
	 * @author David Barlia
	 */
	public class Blend extends EasierAGAL {
		
		/**
		 * Darken results in the darkest value, for each channel
		 * dest = min(baseColor, blendColor)
		 * Commutative - layer order does not matter.
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 */
		static public function darken(dest:IRegister, baseColor:IRegister, blendColor:IRegister):void {
			min(dest.rgb, blendColor.rgb, baseColor.rgb);
		}
		
		
		/**
		 * Multiply blending multiplies the color values of the upper layer with those of the base layer, resulting in a darker color.
		 * Multiplying any color with pure white, leaves the color unchanged.
		 * Commutative - layer order does not matter.
		 * dest = baseColor × blendColor
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 */
		static public function multiply(dest:IRegister, baseColor:IRegister, blendColor:IRegister):void {
			EasierAGAL.multiply(dest.rgb, blendColor.rgb, baseColor.rgb);
		}
		
		
		/**
		 * Color Burn:
		 * Non-commutative - layer order matters.
		 * dest = (baseColor - 1.0 + blendColor) / blendColor
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 */
		static public function colorBurn(dest:IRegister, baseColor:IRegister, blendColor:IRegister):void {
			setIf_GreaterEqual(dest, dest, dest);
			EasierAGAL.subtract(dest, baseColor, dest);
			add(dest, dest, blendColor);
			EasierAGAL.divide(dest, dest, blendColor);
		}
		
		
		/**
		 * Linear Burn
		 * dest = (baseColor + blendColor - 1.0)
		 * Commutative - layer order does not matter.
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 */
		static public function linearBurn(dest:IRegister, baseColor:IRegister, blendColor:IRegister):void {
			setIf_GreaterEqual(dest, blendColor, blendColor);  // set to 1
			EasierAGAL.subtract(dest, baseColor, dest);
			EasierAGAL.add(dest, dest, blendColor);
		}
		
		
		//----------------------------------------------
		
		
		/**
		 * Lighten.
		 * Commutative - layer order does not matter.
		 * dest = max(baseColor, blendColor)  Componentwise.
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 */
		static public function lighten(dest:IRegister, baseColor:IRegister, blendColor:IRegister):void {
			max(dest, baseColor, blendColor);
		}
		
		
		/**
		 * Screen
		 * Commutative - layer order does not matter.
		 * dest = blendColor + baseColor - (blendColor * baseColor)
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 */
		static public function screen(dest:IRegister, baseColor:IRegister, blendColor:IRegister):void {
			EasierAGAL.multiply(dest.rgb, blendColor.rgb, baseColor.rgb);
			EasierAGAL.subtract(dest.rgb, blendColor.rgb, dest.rgb);
			EasierAGAL.add(dest.rgb, dest.rgb, baseColor.rgb);
		}
		
		
		/**
		 * Color Dodge:
		 * Non-commutative - layer order matters.
		 * dest = baseColor / (1 - blendColor)
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 */
		static public function colorDodge(dest:IRegister, baseColor:IRegister, blendColor:IRegister):void {
			setIf_GreaterEqual(dest, dest, dest);
			EasierAGAL.subtract(dest, dest, blendColor);
			EasierAGAL.divide(dest, baseColor, dest);
		}
		
		
		/**
		 * Linear Dodge.  Also called additive blend, as the colors are simply added together.
		 * dest = baseColor + blendColor
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 */
		static public function linearDodge(dest:IRegister, baseColor:IRegister, blendColor:IRegister):void {
			add(dest, blendColor, baseColor);
		}
		
		
		//-----------------------------------------------------------
		
		
		/**
		 * Overlay blending combines multiply and screen to mix the colors, while preserving the highlights and shadows of the base color.
		 * Non-commutative - layer order matters.
		 * Overlay is the same as Hard Light commuted.
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 * @param	one					A component containing the value:  1.0
		 * @param	half				A component containing the value:  0.5
		 * @param	temp				A register temporarily utilized for this calculation
		 * @param	temp2				A register temporarily utilized for this calculation
		 */
		static public function overlay(dest:IRegister, baseColor:IRegister, blendColor:IRegister, one:IComponent, half:IComponent, temp:IRegister, temp2:IRegister, temp3:IRegister):void {
			
			// High:  temp = 1 - ((1 - blend) * (1 - base) * 2)
			EasierAGAL.subtract(temp.rgb, one, blendColor.rgb);
			EasierAGAL.subtract(dest.rgb, one, baseColor.rgb);
			EasierAGAL.multiply(temp.rgb, temp.rgb, dest.rgb);
			add(temp.rgb, temp.rgb, temp.rgb);
			EasierAGAL.subtract(temp.rgb, one, temp.rgb);
			
			// Low:  temp2 = 2 * base * blend
			EasierAGAL.multiply(temp2.rgb, blendColor.rgb, baseColor.rgb);
			add(temp2.rgb, temp2.rgb, temp2.rgb);
			
			// High or Low?
			Utils.setByComparison(dest.rgb, baseColor.rgb, Utils.GREATER_OR_EQUAL, half, temp.rgb, temp2.rgb, temp3);
		}
		
		
		// dest = ( Base - 2*Base*Blend + 2*Blend ) * Base
		
		/**
		 * Soft-Light blending both darkens and lightens, depending on the blend color. 
		 * If the blend color is lighter than 50%, the result is lightened as if it were dodged. 
		 * If the blend color is darker than 50% gray, the image is darkened as if it were burned in. 
		 * 
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 */
		static public function softLight(dest:IRegister, baseColor:IRegister, blendColor:IRegister):void {
			EasierAGAL.add(dest.rgb, baseColor.rgb, baseColor.rgb);
			EasierAGAL.multiply(dest.rgb, dest.rgb, blendColor.rgb);
			EasierAGAL.subtract(dest.rgb, baseColor.rgb, dest.rgb);
			EasierAGAL.add(dest.rgb, dest.rgb, blendColor.rgb);
			EasierAGAL.add(dest.rgb, dest.rgb, blendColor.rgb);
			EasierAGAL.multiply(dest.rgb, dest.rgb, baseColor.rgb);
		}
		
		
		/**
		 * Hardlight blending combines multiply and screen to mix the colors, while preserving the highlights and shadows of the base color.
		 * Non-commutative - layer order matters.
		 * Hard Light is the same as Overlay commuted.
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 * @param	one					A component containing the value:  1.0
		 * @param	half				A component containing the value:  0.5
		 * @param	temp				A register temporarily utilized for this calculation
		 * @param	temp2				A register temporarily utilized for this calculation
		 */
		static public function hardLight(dest:IRegister, baseColor:IRegister, blendColor:IRegister, one:IComponent, half:IComponent, temp:IRegister, temp2:IRegister, temp3:IRegister):void {
			// Call overlay, swapping the base and blend colors
			overlay(dest, blendColor, baseColor, one, half, temp, temp2, temp3);
		}
		
		
		
		/**
		 * Vivid Light:  A combination of color burn and color dodge.
		 * Non-commutative.  [14 instructions]
		 *     burn = burn = (baseColor - 1.0 + blendColor×2) / blendColor×2
		 *     dodge = dodge = baseColor / (1 - (blendColor×2 - 1))
		 *     (Blend < ½) ? burn : dodge
		 * 
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 * @param	one					A component containing the value:  1.0
		 * @param	half				A component containing the value:  0.5
		 * @param	temp				A register temporarily utilized for this calculation
		 */
		static public function vividLight(dest:IRegister, baseColor:IRegister, blendColor:IRegister, one:IComponent, half:IComponent, temp:IRegister, temp2:IRegister, temp3:IRegister):void {
			var burn:IField = temp.rgb;
			var dodge:IField = temp2.rgb;
			
			// Color Dodge:   dodge = baseColor / (1 - (blendColor×2 - 1))
			EasierAGAL.add(temp3, blendColor, blendColor);
			EasierAGAL.subtract(temp3, temp3, one);
			EasierAGAL.subtract(dodge, one, temp3);
			EasierAGAL.divide(dodge, baseColor, dodge);
			
			// Color Burn:    burn = (baseColor - 1.0 + blendColor×2) / blendColor×2
			EasierAGAL.add(temp3, blendColor, blendColor);
			EasierAGAL.subtract(burn, baseColor, one);
			EasierAGAL.add(burn, burn, temp3);
			EasierAGAL.divide(burn, burn, temp3);
			
			// Burn or Dodge?
			Utils.setByComparison(dest, blendColor, Utils.LESS_THAN, half, burn, dodge, temp3);
		}
		
		
		/**
		 * Linear Light.  Also known as Mod2x, ideal for blending textures with pre-rendered lightmaps.
		 * Combines the effects of linear burn and linear dodge
		 * Non-commutative - Layer order matters.
		 * dest = (Base + Blend×2 - 1)
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 * @param	one					A component containing the value:  1.0
		 */
		static public function linearLight(dest:IRegister, baseColor:IRegister, blendColor:IRegister, one:IComponent):void {
			EasierAGAL.subtract(dest, baseColor, one);
			EasierAGAL.add(dest, dest, blendColor);
			EasierAGAL.add(dest, dest, blendColor);
		}
		
		
		/**
		* Pin Light:
		* Non-commutative - Layer order matters.
		* A combination of darken and lighten.
		* dest = (Blend > ½) ? max(Base,2×Blend-1) : min(Base,2×Blend)
		* @param	dest				Register to store resulting RGB color.
		* @param	blendColor			The RGB color of the pixel on top.
		* @param	baseColor			The RGB color of the pixel underneath.
		* @param	one					A component containing the value:  1.0
		* @param	half				A component containing the value:  0.5
		* @param	temp				A register temporarily utilized for this calculation
		* @param	temp2				A register temporarily utilized for this calculation
		* @param	temp3				A register temporarily utilized for this calculation
		 */
		static public function pinLight(dest:IRegister, baseColor:IRegister, blendColor:IRegister, one:IComponent, half:IComponent, temp:IRegister, temp2:IRegister, temp3:IRegister):void {
			
			var darken:IField = temp.rgb;
			var lighten:IField = temp2.rgb;
			
			// darken = min(base, 2*Blend);
			EasierAGAL.add(temp3, blendColor, blendColor);
			EasierAGAL.min(darken, baseColor, temp3);
			
			// lighten = max(base, 2*Blend-1)
			EasierAGAL.subtract(temp3, temp3, one);
			EasierAGAL.max(lighten, temp3, baseColor);
			
			Utils.setByComparison(dest, blendColor, Utils.LESS_THAN, half, darken, lighten, temp3);
		}
		
		
		/**
		 * Hard Mix.
		 * Channels are set strictly to 0.0 or 1.0, by rounding off a vivid light blend.
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 * @param	one					A component containing the value:  1.0
		 */
		static public function hardMix(dest:IRegister, baseColor:IRegister, blendColor:IRegister, one:IComponent):void {
			// Yes, hard mix can be simplified down to just two instructions!
			EasierAGAL.subtract(dest.rgb, one, blendColor);
			setIf_LessThan(dest.rgb, dest.rgb, baseColor.rgb);
		}
		
		
		//------------------------
		
		
		/**
		 * Difference
		 * dest = abs( Base - Blend )
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 */
		static public function difference(dest:IRegister, baseColor:IRegister, blendColor:IRegister):void {
			EasierAGAL.subtract(dest, baseColor, blendColor);
			abs(dest, dest);
		}
		
		
		/**
		 * Exclusion
		 * dest = (-2 × Base × Blend) + Blend + Base
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 */
		static public function exclusion(dest:IRegister, baseColor:IRegister, blendColor:IRegister):void {
			EasierAGAL.multiply(dest, blendColor, baseColor);
			EasierAGAL.add(dest, dest, dest);
			EasierAGAL.subtract(dest, blendColor, dest);
			EasierAGAL.add(dest, dest, baseColor);
		}
		
		
		/**
		 * Subtract.  (Base - Blend)
		 * The blend color can only darken the base color.
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 */
		static public function subtract(dest:IRegister, baseColor:IRegister, blendColor:IRegister):void {
			EasierAGAL.subtract(dest.rgb, baseColor.rgb, blendColor.rgb);
		}
		
		/**
		 * Divide.  (Base / Blend)
		 * The blend color can only brighten the base color.
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 */
		static public function divide(dest:IRegister, baseColor:IRegister, blendColor:IRegister):void {
			EasierAGAL.divide(dest, baseColor, blendColor);
		}
		
		//---------------------------------------
		
		/**
		 * Average blending returns the average of the two colors.
		 * dest = (blend + base) / 2
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 * @param	half				A component containing the value:  0.5
		 */
		static public function average(dest:IRegister, baseColor:IRegister, blendColor:IRegister, half:IComponent):void {
			add(dest, blendColor, baseColor);
			EasierAGAL.multiply(dest.rgb, dest.rgb, half);
		}
		
		
		/**
		 * Non-commutative - Layer order matters.
		 * dest = (base * base / (1.0 - blend))
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 * @param	one					A component containing the value:  1.0
		 * @param	temp				A register temporarily utilized for this calculation
		 */
		static public function reflect(dest:IRegister, baseColor:IRegister, blendColor:IRegister, one:IComponent, temp:IRegister):void {
			EasierAGAL.multiply(dest, baseColor, baseColor);
			EasierAGAL.subtract(temp, one, blendColor);
			EasierAGAL.divide(dest, dest, temp);
		}
		
		/**
		 * Glow blend.  Similar to Vivid Light, but requires only 3 instructions compared to Vivid Light's 14 instructions.
		 * Reflect mode commuted.
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 * @param	one					A component containing the value:  1.0
		 * @param	temp				A register temporarily utilized for this calculation
		 */
		static public function glow(dest:IRegister, baseColor:IRegister, blendColor:IRegister, one:IComponent, temp:IRegister):void {
			reflect(dest, baseColor, blendColor, one, temp);
		}
		
		/**
		 * Negation blend.
		 * Commutative - Layer order does not matter.
		 * dest = 1.0 - abs(1.0 - base - blend)
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 * @param	one					A component containing the value:  1.0
		 */
		static public function negation(dest:IRegister, baseColor:IRegister, blendColor:IRegister, one:IComponent):void {
			EasierAGAL.subtract(dest, one, baseColor);
			EasierAGAL.subtract(dest, dest, blendColor);
			EasierAGAL.abs(dest, dest);
			EasierAGAL.subtract(dest, one, dest);
		}
		
		/**
		 * Phoenix blend.
		 * Commutative - Layer order does not matter.
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 * @param	temp				A register temporarily utilized for this calculation
		 */
		static public function phoenix(dest:IRegister, baseColor:IRegister, blendColor:IRegister, temp:IRegister):void {
			// dest = min(A,B) - max(A,B) + 1.0
			min(dest, blendColor, baseColor);
			max(temp, blendColor, baseColor);
			EasierAGAL.subtract(dest, dest, temp);
			Utils.setOne(temp);
			EasierAGAL.add(dest, dest, temp);
		}
		
		//---------------------------------------
		
		/**
		 * Grain Extract blend mode, as found in Gimp.
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 * @param	half				A component containing the value:  0.5
		 */
		static public function grainExtract(dest:IRegister, baseColor:IRegister, blendColor:IRegister, half:IComponent):void {
			EasierAGAL.subtract(dest, baseColor, blendColor);
			EasierAGAL.add(dest, dest, half);
		}
		
		/**
		 * Grain Merge blend mode, as found in Gimp.
		 * @param	dest				Register to store resulting RGB color.
		 * @param	blendColor			The RGB color of the pixel on top.
		 * @param	baseColor			The RGB color of the pixel underneath.
		 * @param	half				A component containing the value:  0.5
		 */
		static public function grainMerge(dest:IRegister, baseColor:IRegister, blendColor:IRegister, half:IComponent):void {
			EasierAGAL.add(dest, baseColor, blendColor);
			EasierAGAL.subtract(dest, dest, half);
		}
		
		//---------------------------------------
		
	}
}
