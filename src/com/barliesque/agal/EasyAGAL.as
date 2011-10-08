package com.barliesque.agal {
	
	/**
	 * An easy-reading and easy-writing alternative to bare naked AGAL.
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
	public class EasyAGAL extends EasyBase {
		
		/**
		 * @param	debug				Set to true to enable comments to be added to opcode, and opcode trace upon rejection of program upload.
		 * @param	assemblyDebug		Set to true for opcode output from AGALMiniAssembler
		 */
		public function EasyAGAL(debug:Boolean = true, assemblyDebug:Boolean = false) {
			super(debug, assemblyDebug);
		}
		
		
		/**
		 * Move:  Copy the contents of one register or attribute into another
		 * @param	dest
		 * @param	source
		 */
		static protected function mov(dest:IField, source:IField):void {
			Assembler.append("mov " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// Add:  destination = source1 + source2, componentwise
		static protected function add(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("add " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// Subtract:  destination = source1 - source2, componentwise
		static protected function sub(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("sub " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// Multiply:  destination = source1 * source2, componentwise
		static protected function mul(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("mul " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// Divide:  destination = source1 / source2, componentwise
		static protected function div(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("div " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// Reciprocal:  destination = 1/source1, componentwise
		static protected function rcp(dest:IField, source:IField):void {
			Assembler.append("rcp " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// Minimum:  destination = minimum(source1,source2), componentwise
		static protected function min(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("min " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// Maximum:  destination = maximum(source1,source2), componentwise
		static protected function max(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("max " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// Fractional:  destination = source1 - (float)floor(source), componentwise
		static protected function frc(dest:IField, source:IField):void {
			Assembler.append("frc " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// Square Root:  destination = sqrt(source), componentwise
		static protected function sqt(dest:IField, source:IField):void {
			Assembler.append("sqt " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// Reciprocal Square Root:  destination = 1/sqrt(source), componentwise
		static protected function rsq(dest:IField, source:IField):void {
			Assembler.append("rsq " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// Power:  destination = source1 to the power of source2, componentwise
		static protected function pow(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("pow " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// Logarithm:  destination = log_2(source), componentwise
		static protected function log(dest:IField, source:IField):void {
			Assembler.append("log " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// Exponential:  destination = 2^source, componentwise
		static protected function exp(dest:IField, source:IField):void {
			Assembler.append("exp " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// Normalize:  destination = normalize(source)
		static protected function nrm(dest:IField, source:IField):void {
			Assembler.append("nrm " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// Sine:  destination = sin(source), componentwise
		static protected function sin(dest:IField, source:IField):void {
			Assembler.append("sin " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// Cosine:  destination = cos(source), componentwise
		static protected function cos(dest:IField, source:IField):void {
			Assembler.append("cos " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// Absolute Value:  destination = abs(source), componentwise
		static protected function abs(dest:IField, source:IField):void {
			Assembler.append("abs " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// Negate:  destination = -source, componentwise
		static protected function neg(dest:IField, source:IField):void {
			Assembler.append("neg " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// Saturate:  destination = max(min(source,1),0), componentwise
		/// Clamp the source value to between 0 and 1
		static protected function sat(dest:IField, source:IField):void {
			Assembler.append("sat " + dest["reg"] + ", " + source["reg"]);
		}
		
		/// Set If Greater or Equal
		/// destination = (source1 >= source2) ? 1 : 0, componentwise
		static protected function sge(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("sge " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// Set If Less Than
		/// destination = (source1 <  source2) ? 1 : 0, componentwise
		static protected function slt(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("slt " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/*
		/// Set If Equal
		/// destination = (source1 == source2) ? 1 : 0, componentwise
		static protected function seq(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("seq " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/// Set If Not Equal
		/// destination = (source1 != source2) ? 1 : 0, componentwise
		static protected function sne(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("sne " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		*/
		
		/**
		 * [seq*]  *Substitute solution for the unsupported comparison opcode.  (Contains 3 instructions)
		 * destination = (source1 == source2) ? 1 : 0, componentwise
		 * @param	temp	A temporary register which will be utilized for this comparison
		 */
		static public function setIf_Equal(dest:IField, source1:IField, source2:IField, temp:IRegister):void {
			sge(dest, source1, source2);	//  Is source1 >= source2?
			sge(temp, source2, source1);	//  Is source2 >= source1?
			min(dest, dest, temp);			//  If both of the above are true, then they must be equal
		}
		
		/**
		 * [sne*]  *Substitute solution for the unsupported comparison opcode.  (Contains 3 instructions)
		 * destination = (source1 != source2) ? 1 : 0, componentwise
		 * @param	temp	A temporary register which will be utilized for this comparison
		 */
		static public function setIf_NotEqual(dest:IField, source1:IField, source2:IField, temp:IRegister):void {
			slt(dest, source1, source2);	//  Is source1 < source2?
			slt(temp, source2, source1);	//  Is source2 < source1?
			max(dest, dest, temp);			//  If either of the above are true, then they must not be equal
		}
		
		
		
		/// Cross Product
		/// Find the cross product of two 3-component vectors, and store the resulting 3-component vector in destination.
		static protected function crs(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("crs " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/** Dot Product 3
		 * Find the dot product of two 3-component vectors, and store the result in destination.
		 * destination = source1.x*source2.x + source1.y*source2.y + source1.z*source2.z
		 */
		static protected function dp3(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("dp3 " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/** Dot Product 4
		 * Find the dot product of two 4-component vectors, and store the result in destination.
		 * destination = source1.x*source2.x + source1.y*source2.y + source1.z*source2.z + source1.w*source2.w
		 */
		static protected function dp4(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("dp4 " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * Matrix multiply a 3-component vector with a 3x3 matrix, and store the resulting vector in destination.
		 * @param	dest		Destination register
		 * @param	source1		The vector to be multiplied
		 * @param	source2		The first of three consecutive registers, forming a 3x3 matrix
		 */
		static protected function m33(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("m33 " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * Matrix multiply a 4-component vector with a 4x4 matrix, and store the resulting vector in destination.
		 * @param	dest		Destination register
		 * @param	source1		The vector to be multiplied
		 * @param	source2		The first of four consecutive registers, forming a 4x4 matrix
		 */
		static protected function m44(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("m44 " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * Matrix multiply a 4-component vector with a 3x4 matrix, and store the resulting vector in destination.
		 * @param	dest		Destination register
		 * @param	source1		The vector to be multiplied
		 * @param	source2		The first of three consecutive registers, forming a 3x4 matrix
		 */
		static protected function m34(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("m34 " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * If any component of the source is less than zero, the fragment is discarded and not drawn to the frame buffer.
		 * @param	dest		The destination register must be all 0. 
		 * @param	source		A color value.
		 */
		static protected function kil(dest:IField, source:IField):void {
			Assembler.append("kil " + dest["reg"] + ", " + source["reg"]);
		}
		
		/**
		 * Sample Texture:  Get an interpolated pixel color value
		 * @param	dest		Destination register will be set to a color value
		 * @param	source1		Coordinates of the pixel to sample
		 * @param	source2		A Texture Sampler register that is linked to the texture to be sampled
		 * @param	flags		Refer to the TextureFlag class
		 */
		static protected function tex(dest:IField, source1:IField, source2:ISampler, flags:Array = null):void {
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
