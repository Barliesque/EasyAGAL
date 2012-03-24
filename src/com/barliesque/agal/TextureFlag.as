package com.barliesque.agal {
	
	/**
	 * Defines constants for the various flags that may be specified when sampling a texture.
	 * 
	 * @author David Barlia
	 */
	public class TextureFlag {
		
		// TODO:  Improve documentation of all texture flags
		
		/*  Images in this texture all are 2-dimensional. They have width and height, but no depth. */
		static public const TYPE_2D:String 				= "2d";
		
		/*  Images in this texture all are 3-dimensional. They have width, height, and depth. */
		static public const TYPE_3D:String 				= "3d";
		
		/*  There are exactly 6 distinct sets of 2D images, all of the same size. They act as 6 faces of a cube. */
		static public const TYPE_CUBE:String 			= "cube";
		
		
		static public const MIP_NEAREST:String 			= "mipnearest";
		static public const MIP_LINEAR:String 			= "miplinear";
		static public const MIP_NONE:String 			= "mipnone";
		static public const MIP_NO:String 				= "nomip";
		
		static public const FILTER_NEAREST:String 		= "nearest";
		static public const FILTER_LINEAR:String 		= "linear";
		
		/*  NOT SUPPORTED BY STAGE3D
		static public const SPECIAL_CENTROID:String 	= "centroid";
		static public const SPECIAL_SINGLE:String 		= "single";
		static public const SPECIAL_DEPTH:String 		= "depth";
		*/
		
		static public const MODE_REPEAT:String 			= "repeat";
		static public const MODE_WRAP:String 			= "wrap";
		static public const MODE_CLAMP:String 			= "clamp";
		
	}
}
