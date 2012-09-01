package com.barliesque.agal {
	
	/**
	 * An AGAL register with four component values.
	 * Use this interface when assigning variables as "aliases" to registers, or when defining parameters for a macro function.
	 * 
	 * @author David Barlia
	 */
	public interface IRegister extends IField {
		
		/** 
		 * The first of four components contained in the register.  May be accessed identically as 
		 * either "x" (for positional or vector notation) or "r" (for color notation).
		 */
		function get x():Component;
		
		/** 
		 * The second of four components contained in the register.  May be accessed identically as 
		 * either "y" (for positional or vector notation) or "g" (for color notation).
		 */
		function get y():Component;
		
		/** 
		 * The third of four components contained in the register.  May be accessed identically as 
		 * either "z" (for positional or vector notation) or "b" (for color notation).
		 */
		function get z():Component;
		
		/** 
		 * The fourth of four components contained in the register.  May be accessed identically as 
		 * either "w" (for positional or vector notation) or "a" (for color notation).
		 */
		function get w():Component;
		
		/**
		 * The first of four components contained in the register.  May be accessed identically as 
		 * either "r" (the red component in color notation), or "x" (for positional or vector notation).
		 * Color values range from 0.0 (darkest) to 1.0 (lightest), though the component may hold any numerical value.
		 */
		function get r():Component;
		
		/**
		 * The second of four components contained in the register.  May be accessed identically as 
		 * either "g" (the green component in color notation), or "y" (for positional or vector notation).
		 * Color values range from 0.0 (darkest) to 1.0 (lightest), though the component may hold any numerical value.
		 */
		function get g():Component;
		
		/**
		 * The third of four components contained in the register.  May be accessed identically as 
		 * either "b" (the blue component in color notation), or "z" (for positional or vector notation).
		 * Color values range from 0.0 (darkest) to 1.0 (lightest), though the component may hold any numerical value.
		 */
		function get b():Component;
		
		/**
		 * The fourth of four components contained in the register.  May be accessed identically as 
		 * either "a" (the alpha component in color notation), or "w" (for positional or vector notation).
		 * Color values range from 0.0 (darkest) to 1.0 (lightest), though the component may hold any numerical value.
		 */
		function get a():Component;
		
		/**
		 * A component selection of the first two components, for 2D coordinates such as texture UV.
		 */
		function get xy():ComponentSelection;
		
		/**
		 * A component selection of the last two components, for 2D coordinates such as texture UV.
		 */
		function get zw():ComponentSelection;
		
		/**
		 * A component selection of the first three components, in positional/vector notation.
		 */
		function get xyz():ComponentSelection;
		
		/**
		 * A component selection of the first three components, in color notation.
		 */
		function get rgb():ComponentSelection;
		
		/** 
		 * Specify any register component or components by string, for example: "zyx" "wwww" "gbr"
		 * The ability to specify an arbitrary arrangement of components is known as component "swizzling".  Swizzling enables us, for example, to reduce the following series of instructions:
		 * <code>	mul( TEMP[0].x, TEMP[1].z, TEMP[1].w );</code>
		 * <code>	mul( TEMP[0].y, TEMP[1].x, TEMP[1].w );</code>
		 * <code>	mul( TEMP[0].z, TEMP[1].x, TEMP[1].y );</code>
		 * <code>	mul( TEMP[0].w, TEMP[1].z, TEMP[1].y );</code>
		 * Down to this single instruction:
		 * <code>	mul( TEMP[0]._("xyzw"), TEMP[1]._("zxxz"), TEMP[1]._("wwyy") );</code>
		 * @param	xyzwrgba	A string containing a maximum of four components
		 */
		function _(xyzwrgba:String):IField;
		
	}
}