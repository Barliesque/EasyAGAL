package com.barliesque.agal {
	
	/**
	 * An easy-reading and easy-writing alternative to bare naked AGAL.
	 * Extend this class, or EasierAGAL, to write new shader programs.
	 * This class uses the same three-letter opcodes originally specified by AGAL.
	 * See the EasierAGAL class for a more verbose, easier-reading alternative.
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
	 * unalterred, wherever you may wish to distribute this library.
	 */
	public class EasyAGAL extends EasyBase {
		
		/**
		 * @param	debug				Set to true to enable basic debugging features:  alias management, comments added to opcode, opcode trace upon rejection of program upload.
		 * @param	assemblyDebug		Set to true for opcode output from AGALMiniAssembler
		 */
		public function EasyAGAL(debug:Boolean = true, assemblyDebug:Boolean = false) {
			super(debug, assemblyDebug);
		}
		
		
		/**
		 * Move:  Copy the contents of one register or attribute into another
		 * @param	dest		The destination register or component selection
		 * @param	source		The source register or component selection
		 */
		static protected function mov(dest:IField, source:IField):void {
			Assembler.append("mov " + dest["reg"] + ", " + source["reg"]);
		}
		
		/**
		 * <p>Add:  destination = source1 + source2, componentwise</p>
		 * <p>Note:  Source1 and Source2 can not both be constant registers.  
		 * In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source1		First source register or component selection
		 * @param	source2		Second source register or component selection
		 */
		static protected function add(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("add " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * <p>Subtract:  destination = source1 - source2, componentwise</p>
		 * <p>Note:  Source1 and Source2 can not both be constant registers.  
		 * In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source1		First source register or component selection
		 * @param	source2		Second source register or component selection
		 */
		static protected function sub(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("sub " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * <p>Multiply:  destination = source1 * source2, componentwise</p>
		 * <p>Note:  Source1 and Source2 can not both be constant registers.  
		 * In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source1		First source register or component selection
		 * @param	source2		Second source register or component selection
		 */
		static protected function mul(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("mul " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * <p>Divide:  destination = source1 / source2, componentwise</p>
		 * <p>Dividing by zero does not produce any error, but rather results in a numerical equivalent to infinity.</p>
		 * <p>Note:  Source1 and Source2 can not both be constant registers.  
		 * In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source1		Source register or component selection of the numerator
		 * @param	source2		Source register or component selection of the divisor
		 */
		static protected function div(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("div " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * <p>Reciprocal:  destination = 1/source, componentwise</p>
		 * <p>The reciprocal value of zero returns a numerical equivalent of infinity.</p>
		 * <p>Note:  The source can not be a constant register.  In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source		The source register or component selection
		 */
		static protected function rcp(dest:IField, source:IField):void {
			Assembler.append("rcp " + dest["reg"] + ", " + source["reg"]);
		}
		
		/**
		 * <p>Minimum:  Each component of source1 is individually compared to source2, and the corresponding 
		 * component of the destination is set to whichever is less.</p>
		 * <p>Note:  Source1 and Source2 can not both be constant registers.  
		 * In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source1		First source register or component selection
		 * @param	source2		Second source register or component selection
		 */
		static protected function min(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("min " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * <p>Maximum:  Each component of source1 is individually compared to source2, and the corresponding 
		 * component of the destination is set to whichever is greater.</p>
		 * <p>Note:  Source1 and Source2 can not both be constant registers.  
		 * In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source1		First source register or component selection
		 * @param	source2		Second source register or component selection
		 */
		static protected function max(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("max " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * <p>Fractional:  The destination is set to the fractional value of the source.  For example, if the source is 4.3, the result will be 0.3</p>
		 * <p>This operation is componentwise.</p>
		 * <p>Note:  The source can not be a constant register.  In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source		The source register or component selection
		 */
		static protected function frc(dest:IField, source:IField):void {
			Assembler.append("frc " + dest["reg"] + ", " + source["reg"]);
		}
		
		/**
		 * <p>Square Root:  destination = sqrt(source), componentwise</p>
		 * <p>Note:  The source can not be a constant register.  In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source		The source register or component selection
		 */
		static protected function sqt(dest:IField, source:IField):void {
			Assembler.append("sqt " + dest["reg"] + ", " + source["reg"]);
		}
		
		/**
		 * <p>Reciprocal Square Root:  destination = 1/sqrt(source), componentwise</p>
		 * <p>The reciprocal root of zero returns a numerical equivalent of infinity.</p>
		 * <p>Note:  The source can not be a constant register.  In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source		The source register or component selection
		 */
		static protected function rsq(dest:IField, source:IField):void {
			Assembler.append("rsq " + dest["reg"] + ", " + source["reg"]);
		}
		
		/**
		 * <p>Power:  destination = source1 to the power of source2, componentwise</p>
		 * <p>Note:  Source1 and Source2 can not both be constant registers.  
		 * In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source1		First source register or component selection
		 * @param	source2		Second source register or component selection
		 */
		static protected function pow(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("pow " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * <p>Logarithm(2):  Calculates the logarithm of the source in base 2.</p>
		 * <p>destination = log_2(source), componentwise</p>
		 * <p>Note:  The source can not be a constant register.  In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source		The source register or component selection
		 */
		static protected function log(dest:IField, source:IField):void {
			Assembler.append("log " + dest["reg"] + ", " + source["reg"]);
		}
		
		/** 
		 * <p>Exponential:  destination = 2^source, componentwise</p>
		 * <p>Note:  The source can not be a constant register.  In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source		The source register or component selection
		 */
		static protected function exp(dest:IField, source:IField):void {
			Assembler.append("exp " + dest["reg"] + ", " + source["reg"]);
		}
		
		/**
		 * <p>Normalize:  destination = normalize(source)</p>
		 * <p>Produces only a 3 component result. Destination must be masked to .xyz or less</p>
		 * <p>Note:  The source can not be a constant register.  In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination component selection.  Must be 3 components or fewer.
		 * @param	source		The source register containing a three-component vector.
		 */
		static protected function nrm(dest:IField, source:IField):void {
			Assembler.append("nrm " + dest["reg"] + ", " + source["reg"]);
		}
		
		/**
		 * <p>Sine:  destination = sin(source), componentwise</p>
		 * <p>Note:  The source can not be a constant register.  In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source		The source register or component selection containing angles in radians.
		 */
		static protected function sin(dest:IField, source:IField):void {
			Assembler.append("sin " + dest["reg"] + ", " + source["reg"]);
		}
		
		/** 
		 * <p>Cosine:  destination = cos(source), componentwise</p>
		 * <p>Note:  The source can not be a constant register.  In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source		The source register or component selection containing angles in radians.
		 */
		static protected function cos(dest:IField, source:IField):void {
			Assembler.append("cos " + dest["reg"] + ", " + source["reg"]);
		}
		
		/**
		 * <p>Absolute Value:  Results in the absolute value of the source.  Componentwise</p>
		 * <p>Note:  The source can not be a constant register.  In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source		The source register or component selection
		 */
		static protected function abs(dest:IField, source:IField):void {
			Assembler.append("abs " + dest["reg"] + ", " + source["reg"]);
		}
		
		/**
		 * <p>Negate:  destination = -source, componentwise</p>
		 * <p>Note:  The source can not be a constant register.  In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source		The source register or component selection
		 */
		static protected function neg(dest:IField, source:IField):void {
			Assembler.append("neg " + dest["reg"] + ", " + source["reg"]);
		}
		
		/**
		 * <p>Saturate:  Clamps the source value to between 0 and 1, componentwise.</p>
		 * <p>Note:  The source can not be a constant register.  In this instance, the value should be pre-calculated and passed into the shader constants from ActionScript.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source		The source register or component selection
		 */
		static protected function sat(dest:IField, source:IField):void {
			Assembler.append("sat " + dest["reg"] + ", " + source["reg"]);
		}
		
		/**
		 * <p>Set If Greater or Equal</p>
		 * <p>Each component is compared individually.  If source1 is greater than or equal 
		 * to source2, the corresponding component of the destination will be set to 1;  
		 * otherwise, it will be set to 0.</p>
		 */
		static protected function sge(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("sge " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/** 
		 * <p>Set If Less Than</p>
		 * <p>Each component is compared individually.  If source1 is less than 
		 * source2, the corresponding component of the destination will be set to 1;
		 * otherwise, it will be set to 0.</p>
		 */
		static protected function slt(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("slt " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/*
		 * <p>Sign (Component-wise)</p>
		 * <p>Extracts the sign of the source value, and sets the destination to:  
		 * -1 if source is less than zero; 0 if source equals zero; or 1 if source is greater than zero.</p>
		 * @param	dest		The destination register or component selection
		 * @param	source		The source register or component selection
		 */
		/*
		static protected function sgn(dest:IField, source:IField):void {
			Assembler.append("sgn " + dest["reg"] + ", " + source["reg"]);
		}
		*/
		
		/**
		 * <p>Set If Equal</p>
		 * <p>Each component is compared individually.  If source1 is equal to
		 * source2, the corresponding component of the destination will be set to 1;
		 * otherwise, it will be set to 0.</p>
		 * @param	dest		Register in which the result of this operation will be stored
		 * @param	source1		Value on the left side of the comparison
		 * @param	source2		Value on the right side of the comparison
		 */
		static protected function seq(dest:IField, source1:IField, source2:IField):void { //, temp:IRegister):void {
			Assembler.append("seq " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
			
			/*
			* @param	temp		A temporary register which will be utilized for this comparison
			* <p>This is a 3-instruction macro substitute for the currently unsupported [seq] opcode.</p>
			sge(dest, source1, source2);	//  Is source1 >= source2?
			sge(temp, source2, source1);	//  Is source2 >= source1?
			min(dest, dest, temp);			//  If both of the above are true, then they must be equal
			*/
		}
		
		/**
		 * <p>Set If Not Equal</p>
		 * <p>Each component is compared individually.  If source1 is not equal to
		 * source2, the corresponding component of the destination will be set to 1;
		 * otherwise, it will be set to 0.</p>
		 * @param	dest		Register in which the result of this operation will be stored
		 * @param	source1		Value on the left side of the comparison
		 * @param	source2		Value on the right side of the comparison
		 */
		static protected function sne(dest:IField, source1:IField, source2:IField):void { //, temp:IRegister):void {
			Assembler.append("sne " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
			
			/*
			* <p>This is a 3-instruction macro substitute for the currently unsupported [sne] opcode.</p>
			* @param	temp		A temporary register which will be utilized for this comparison
			slt(dest, source1, source2);	//  Is source1 < source2?
			slt(temp, source2, source1);	//  Is source2 < source1?
			max(dest, dest, temp);			//  If either of the above are true, then they must not be equal
			*/
		}
		
		
		/** 
		 * <p>Cross Product</p>
		 * <p>Find the cross product of two 3-component vectors, and store the resulting 3-component vector in destination.</p>
		 * @param	dest		The destination for the resulting three-component vector
		 * @param	source1		A three-component vector	
		 * @param	source2		A three-component vector
		 **/
		static protected function crs(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("crs " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * <p>Dot Product (3-component)</p>
		 * <p>Find the dot product of two 3-component vectors, and store the resulting value in destination.</p>
		 * <p>destination = source1.x*source2.x + source1.y*source2.y + source1.z*source2.z</p>
		 * @param	dest		The destination for the resulting single numeric value
		 * @param	source1		A three-component vector	
		 * @param	source2		A three-component vector
		 **/
		static protected function dp3(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("dp3 " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * <p>Dot Product (4-component)</p>
		 * <p>Find the dot product of two 4-component vectors, and store the resulting value in the destination.</p>
		 * <p>destination = source1.x*source2.x + source1.y*source2.y + source1.z*source2.z + source1.w*source2.w</p>
		 * @param	dest		The destination for the resulting single numeric value
		 * @param	source1		A three-component vector	
		 * @param	source2		A three-component vector
		 **/
		static protected function dp4(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("dp4 " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * Matrix multiply a 3-component vector with a 3x3 matrix, and store the resulting vector in destination.
		 * @param	dest		Destination register for the resulting 3-component vector
		 * @param	source1		A 3-component row vector to be multiplied
		 * @param	source2		The first of three consecutive registers, forming a 3x3 matrix
		 */
		static protected function m33(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("m33 " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * Matrix multiply a 4-component vector with a 4x4 matrix, and store the resulting vector in destination.
		 * @param	dest		Destination register for the resulting 4-component vector
		 * @param	source1		A 4-component row vector to be multiplied
		 * @param	source2		The first of four consecutive registers, forming a 4x4 matrix
		 */
		static protected function m44(dest:IField, source1:IField, source2:IField):void {
			Assembler.append("m44 " + dest["reg"] + ", " + source1["reg"] + ", " + source2["reg"]);
		}
		
		/**
		 * Matrix multiply a 4-component vector with a 3x4 matrix, and store the resulting vector in destination.
		 * @param	dest		Destination register for the resulting 4-component vector
		 * @param	source1		A 4-component row vector to be matrix multiplied
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
		 * @param	source1		UV Coordinates of the pixel to sample
		 * @param	source2		A Texture Sampler register that is linked to the texture to be sampled
		 * @param	flags		Refer to the TextureFlag class
		 * 
		 * @see TextureFlag
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
