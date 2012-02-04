package com.barliesque.shaders.macro {
	import com.barliesque.agal.EasierAGAL;
	import com.barliesque.agal.IComponent;
	import com.barliesque.agal.IField;
	import com.barliesque.agal.IRegister;
	
	/**
	 * A collection of macros to support blending HSL (Hue / Saturation / Lumination) color values.
	 * @author David Barlia
	 */
	public class BlendHSL extends EasierAGAL {
		
		
		/**
		  * Hue blend - The hue of the blend color is combine with the saturation and luminance of the base color.
		  * Use ColorSpace.rgb2hsl() to convert RGB colors for use with this macro, 
		  * then ColorSpace.hsl2rgb() to convert the result back to RGB.
		  * @param	dest				Register to store resulting HSL color.
		  * @param	hslBlendColor		The HSL color of the pixel on top.
		  * @param	hslBaseColor		The HSL color of the pixel underneath.
		  */
		static public function hue(dest:IRegister, hslBaseColor:IRegister, hslBlendColor:IRegister):void {
			// TODO: Optimize by only rgb2hsl converting the components that will be used!
			move(dest, hslBaseColor);
			move(dest.r, hslBlendColor.r);
		}
		
		
		/**
		 * Saturation blend - The saturation of the blend color is combined with the hue and luminance of the base color.
		 * Use ColorSpace.rgb2hsl() to convert RGB colors for use with this macro, 
		 * then ColorSpace.hsl2rgb() to convert the result back to RGB.
		 * @param	dest				Register to store resulting HSL color.
		 * @param	hslBlendColor		The HSL color of the pixel on top.
		 * @param	hslBaseColor		The HSL color of the pixel underneath.
		 */
		static public function saturation(dest:IRegister, hslBaseColor:IRegister, hslBlendColor:IRegister):void {
			// TODO: Optimize by only rgb2hsl converting the components that will be used!
			move(dest, hslBaseColor);
			move(dest.g, hslBlendColor.g);
		}
		
		
		/**
		 * Color blend - The hue and saturation of the blend color are combined with the luminosity of the base color.
		 * Use ColorSpace.rgb2hsl() to convert RGB colors for use with this macro, 
		 * then ColorSpace.hsl2rgb() to convert the result back to RGB.
		 * @param	dest				Register to store resulting HSL color.
		 * @param	hslBlendColor		The HSL color of the pixel on top.
		 * @param	hslBaseColor		The HSL color of the pixel underneath.
		 */
		static public function color(dest:IRegister, hslBaseColor:IRegister, hslBlendColor:IRegister):void {
			// TODO: Optimize by only rgb2hsl converting the components that will be used!
			move(dest, hslBaseColor);
			move(dest._("rg"), hslBlendColor._("rg"));
		}
		
		
		/**
		 * Luminosity blend - The luminance of the blend color is combined with the hue and saturation of the base color.
		 * Use ColorSpace.rgb2hsl() to convert RGB colors for use with this macro, 
		 * then ColorSpace.hsl2rgb() to convert the result back to RGB.
		 * @param	dest				Register to store resulting HSL color.
		 * @param	hslBlendColor		The HSL color of the pixel on top.
		 * @param	hslBaseColor		The HSL color of the pixel underneath.
		 */
		static public function luminosity(dest:IRegister, hslBaseColor:IRegister, hslBlendColor:IRegister):void {
			// TODO: Optimize by only rgb2hsl converting the components that will be used!
			move(dest, hslBaseColor);
			move(dest.b, hslBlendColor.b);
		}
		
		//------------------------------------------
		
		/**
		 * Lighter Color - Selects the color with the brightest luminance.
		 * Use ColorSpace.rgb2hsl() to convert RGB colors for use with this macro, 
		 * then ColorSpace.hsl2rgb() to convert the result back to RGB.
		 * @param	dest				Register to store resulting HSL color.
		 * @param	hslBlendColor		The HSL color of the pixel on top.
		 * @param	hslBaseColor		The HSL color of the pixel underneath.
		 */
		static public function lighterColor(dest:IRegister, hslBaseColor:IRegister, hslBlendColor:IRegister, temp:IRegister):void {
			Utils.setByComparison(dest, hslBaseColor.b, Utils.GREATER_THAN, hslBlendColor.b, hslBaseColor, hslBlendColor, temp);
			move(dest.a, hslBaseColor.a);
		}
		
		
		/**
		 * Darker Color - Selects the color with the darkest luminance.
		 * Use ColorSpace.rgb2hsl() to convert RGB colors for use with this macro, 
		 * then ColorSpace.hsl2rgb() to convert the result back to RGB.
		 * @param	dest				Register to store resulting HSL color.
		 * @param	hslBlendColor		The HSL color of the pixel on top.
		 * @param	hslBaseColor		The HSL color of the pixel underneath.
		 * @param	temp				A temporary register that will be utilized for this operation
		 */
		static public function darkerColor(dest:IRegister, hslBaseColor:IRegister, hslBlendColor:IRegister, temp:IRegister):void {
			Utils.setByComparison(dest.rgb, hslBaseColor.b, Utils.LESS_THAN, hslBlendColor.b, hslBaseColor, hslBlendColor, temp);
			move(dest.a, hslBaseColor.a);
		}
		
		
		
		
	}
}