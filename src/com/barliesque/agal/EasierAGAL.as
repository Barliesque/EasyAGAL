package com.barliesque.agal {
	
	/**
	* An easier-reading and easier-writing alternative to bare naked AGAL.
	* This variation on EasyAGAL uses full-word method names for improved readability.
	* 
	* @author David Barlia, david@barliesque.com
	* 
	* This project is licensed under the Apache Open Source License, ver.2
	* http://www.apache.org/licenses/LICENSE-2.0.html
	* 
	* Basically, it's yours to code with for all your Molehill needs, on projects
	* personal or commercial, so long as the source itself is not sold as your own work.
	* If you're overcome with a need to give me credit, I will not be offended, but
	* no such act is required.  If you come up with improvements, I ask that you 
	* drop me an update.  In any case, this header should stay where it is, 
	* unalterred, wherever you may wish to spread it.
	*/
	public class EasierAGAL extends EasyBase {
		
		/**
		 * @param	debug				Set to true to enable comments to be added to opcode, and opcode trace upon rejection of program upload.
		 * @param	assemblyDebug		Set to true for opcode output from AGALMiniAssembler
		 */
		public function EasierAGAL(debug:Boolean = true, assemblyDebug:Boolean = false) {
			super(debug, assemblyDebug);
		}
		
		
		/**
		 * [mov]  Copy the contents of one register or attribute into another
		 * @param	dest
		 * @param	source
		 */
		static protected function move(dest:IField, source:IField):void {
			Assembler.append("mov " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// [add]  destination = source1 + source2, componentwise
		static protected function add(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("add " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// [sub]  destination = source1 - source2, componentwise
		static protected function subtract(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("sub " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// [mul]  destination = source1 * source2, componentwise
		static protected function multiply(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("mul " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// [div]  destination = source1 / source2, componentwise
		static protected function divide(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("div " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// [rcp]  destination = 1/source1, componentwise
		static protected function reciprocal(dest:IField, source:IField):void {
			Assembler.append("rcp " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// [min]  destination = minimum(source1,source2), componentwise
		static protected function min(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("min " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// [max]  destination = maximum(source1,source2), componentwise
		static protected function max(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("max " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// [frc]  destination = source1 - (float)floor(source), componentwise
		static protected function fractional(dest:IField, source:IField):void {
			Assembler.append("frc " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// [sqt]  destination = sqrt(source), componentwise
		static protected function squareRoot(dest:IField, source:IField):void {
			Assembler.append("sqt " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// [rsq]  destination = 1/sqrt(source), componentwise
		static protected function reciprocalRoot(dest:IField, source:IField):void {
			Assembler.append("rsq " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// [pow]  destination = source1 to the power of source2, componentwise
		static protected function pow(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("pow " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// [log]  destination = log_2(source), componentwise
		static protected function log(dest:IField, source:IField):void {
			Assembler.append("log " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// [exp]  destination = 2^source, componentwise
		static protected function exp(dest:IField, source:IField):void {
			Assembler.append("exp " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// [nrm]  destination = normalize(source)
		static protected function normalize(dest:IField, source:IField):void {
			Assembler.append("nrm " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// [sin]  destination = sin(source), componentwise
		static protected function sin(dest:IField, source:IField):void {
			Assembler.append("sin " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// [cos]  destination = cos(source), componentwise
		static protected function cos(dest:IField, source:IField):void {
			Assembler.append("cos " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// [abs]  destination = abs(source), componentwise
		static protected function abs(dest:IField, source:IField):void {
			Assembler.append("abs " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// [neg]  destination = -source, componentwise
		static protected function negate(dest:IField, source:IField):void {
			Assembler.append("neg " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// [sat]  destination = max(min(source,1),0), componentwise
		/// Clamp the source value to between 0 and 1
		static protected function saturate(dest:IField, source:IField):void {
			Assembler.append("sat " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// [sge]  destination = (source1 >= source2) ? 1 : 0, componentwise
		static protected function setIf_GreaterEqual(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("sge " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// [slt]  destination = (source1 <  source2) ? 1 : 0, componentwise
		static protected function setIf_LessThan(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("slt " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/*
		/// [seq]  destination = (source1 == source2) ? 1 : 0, componentwise
		static protected function setIf_Equal(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("seq " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// [sne]  destination = (source1 != source2) ? 1 : 0, componentwise
		static protected function setIf_NotEqual(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("sne " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		*/
		
		/**
		 * [seq*]  *Substitute solution for the unsupported comparison opcode.  (Contains 3 instructions)
		 * destination = (source1 == source2) ? 1 : 0, componentwise
		 * @param	temp	A temporary register which will be utilized for this comparison
		 */
		static public function setIf_Equal(dest:IField, source1:IField, source2:IField, temp:IRegister):void {
			setIf_GreaterEqual(dest, source1, source2);	//  Is source1 >= source2?
			setIf_GreaterEqual(temp, source2, source1);	//  Is source2 >= source1?
			min(dest, dest, temp);						//  If both of the above are true, then they must be equal
		}
		
		/**
		 * [sne*]  *Substitute solution for the unsupported comparison opcode.  (Contains 3 instructions)
		 * destination = (source1 != source2) ? 1 : 0, componentwise
		 * @param	temp	A temporary register which will be utilized for this comparison
		 */
		static public function setIf_NotEqual(dest:IField, source1:IField, source2:IField, temp:IRegister):void {
			setIf_LessThan(dest, source1, source2);	//  Is source1 < source2?
			setIf_LessThan(temp, source2, source1);	//  Is source2 < source1?
			max(dest, dest, temp);					//  If either of the above are true, then they must not be equal
		}
		
		
		/// [crs]  Find the cross product of two 3-component vectors, and store the resulting 3-component vector in destination.
		static protected function crossProduct(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("crs " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/** [dp3]  Find the dot product of two 3-component vectors, and store the result in destination.
		* destination = source1.x*source2.x + source1.y*source2.y + source1.z*source2.z
		*/
		static protected function dotProduct3(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("dp3 " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/** [dp4]  Find the dot product of two 4-component vectors, and store the result in destination.
		* destination = source1.x*source2.x + source1.y*source2.y + source1.z*source2.z + source1.w*source2.w
		*/
		static protected function dotProduct4(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("dp4 " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * [m33]  Matrix multiply a 3-component vector with a 3x3 matrix, and store the resulting vector in destination.
		 * @param	dest		Destination register
		 * @param	source1		The vector to be multiplied
		 * @param	source2		The first of three consecutive registers, forming a 3x3 matrix
		 */
		static protected function multiply3x3(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("m33 " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * [m44]  Matrix multiply a 4-component vector with a 4x4 matrix, and store the resulting vector in destination.
		 * @param	dest		Destination register
		 * @param	source1		The vector to be multiplied
		 * @param	source2		The first of four consecutive registers, forming a 4x4 matrix
		 */
		static protected function multiply4x4(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("m44 " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * [m34]  Matrix multiply a 4-component vector with a 3x4 matrix, and store the resulting vector in destination.
		 * @param	dest		Destination register
		 * @param	source1		The vector to be multiplied
		 * @param	source2		The first of three consecutive registers, forming a 3x4 matrix
		 */
		static protected function multiply3x4(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("m34 " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * [kil]  If any component of the source is less than zero, the fragment is discarded and not drawn to the frame buffer.
		 * @param	dest		The destination register must be all 0. 
		 * @param	source		A color value.
		 */
		static protected function killFragment(dest:IField, source:IField):void {
			Assembler.append("kil " + dest["reg"] + ", " + source["reg"]);
		}
		
		/**
		 * [tex]  Get an interpolated pixel color value
		 * @param	dest		Destination register will be set to a color value
		 * @param	source1		Coordinates of the pixel to sample
		 * @param	source2		A Texture Sampler register that is linked to the texture to be sampled
		 * @param	flags		Refer to the TextureFlag class
		 */
		static protected function sampleTexture(dest:IField, source1:IField, source2:ISampler, flags:Array = null):void {
			if (Assembler.assemblingVertex) throw new Error("sampleTexture() is only available in vertex shaders.");
			var code:String = "tex " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"];
			if (flags) {
				code += " <";
				for each (var flag:String in flags) {
					code += flag + ",";
				}
				code = code.substr(0, code.length - 1) + ">";
			}
			Assembler.append(code);
		}
		
	}
}