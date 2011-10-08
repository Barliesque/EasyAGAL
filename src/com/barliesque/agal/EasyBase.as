package com.barliesque.agal {
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	
	/**
	 * Internal base class providing common functionality of EasyAGAL and EasierAGAL
	 * @author David Barlia
	 */
	internal class EasyBase {
		
		/// @private
		
		private var _vertexOpcode:String;
		private var _fragmentOpcode:String;
		private var _vertexInstructions:uint = 0;
		private var _fragmentInstructions:uint = 0;
		private var _program:Program3D;
		private var _context:Context3D;
		
		// Register definitions
		internal var _ATTRIBUTE:Vector.<IRegister>;
		internal var _CONST:Vector.<IRegister>;
		internal var _TEMP:Vector.<IRegister>;
		internal var _OUTPUT:Register;
		internal var _VARYING:Vector.<IRegister>;
		internal var _SAMPLER:Vector.<ISampler>;
		internal var initialized:Boolean = false;
		
		private var debug:Boolean;
		private var assemblyDebug:Boolean;
		
		//---------------------------------------------------------
		
		/**
		 * @param	debug				Set to true to enable comments to be added to opcode, and opcode trace upon rejection of program upload.
		 * @param	assemblyDebug		Set to true for opcode output from AGALMiniAssembler
		 */
		public function EasyBase(debug:Boolean = true, assemblyDebug:Boolean = false) {
			this.debug = debug;
			this.assemblyDebug = assemblyDebug;
		}
		
		
		/// To be overridden.  Write your vertex shader here.
		/// If opcode has already been assigned to 'vertexOpcode' then that code will be used, and this function will not be called.
		protected function _vertexShader():void { }
		
		/// To be overridden.  Write your fragment shader here.
		/// If opcode has already been assigned to 'fragmentOpcode' then that code will be used, and this function will not be called.
		protected function _fragmentShader():void { }
		
		//---------------------------------------------------------
		
		/// A count of the number of instructions in the vertex shader.
		/// AGAL shaders are restricted to a max of 256 instructions.
		/// If _vertexShader() has not already been called, it will be called upon access of this property.
		/// It is safe to access this property from _vertexShader() without causing an infinte loop.
		public function get vertexInstructions():uint {
			prepVertexShader();
			if (Assembler.isPreparing && Assembler.assemblingVertex) return Assembler.instructionCount;
			return _vertexInstructions;
		}
		
		/// A count of the number of instructions in the fragment shader.
		/// AGAL shaders are restricted to a max of 256 instructions.
		/// If _fragmentShader() has not already been called, it will be called upon access of this property.
		/// It is safe to access this property from _fragmentShader() without causing an infinte loop.
		public function get fragmentInstructions():uint { 
			prepFragmentShader();
			if (Assembler.isPreparing && !Assembler.assemblingVertex) return Assembler.instructionCount;
			return _fragmentInstructions;
		}
		
		/**
		 * Returns vertex shader code to be passed to AGALMiniAssembler
		 * If _vertexShader() has not already been called, it will be called now.
		 * It is safe to call this function from within _vertexShader() without causing an infinte loop.
		 * @param	lineNumbering	If true, line numbers are added to the left side to assist in locating tokens referred to by an AGAL error message
		 * @return	Returns vertex shader code to be passed to AGALMiniAssembler
		 */
		public function getVertexOpcode(lineNumbering:Boolean = false):String { 
			prepVertexShader();
			if (Assembler.isPreparing && Assembler.assemblingVertex) {
				return (lineNumbering ? addLineNumbers(Assembler.code) : Assembler.code);
			}
			return (lineNumbering ? addLineNumbers(_vertexOpcode) : _vertexOpcode);
		}
		
		/**
		 * Returns fragment shader code to be passed to AGALMiniAssembler
		 * If _fragmentShader() has not already been called, it will be called now.
		 * It is safe to call this function from within _fragmentShader() without causing an infinte loop.
		 * @param	lineNumbering	If true, line numbers are added to the left side to assist in locating tokens referred to by an AGAL error message
		 * @return	Returns fragment shader code to be passed to AGALMiniAssembler
		 */
		public function getFragmentOpcode(lineNumbering:Boolean = false):String {
			prepFragmentShader();
			if (Assembler.isPreparing && !Assembler.assemblingVertex) {
				return (lineNumbering ? addLineNumbers(Assembler.code) : Assembler.code);
			}
			return (lineNumbering ? addLineNumbers(_fragmentOpcode) : _fragmentOpcode);
		}
		
		/// The Program3D instance created by calling upload()
		public function get program():Program3D { return _program; }
		
		/// The Context3D instance the shader program has been uploaded to.  Set by calling upload().  Cleared by calling dispose().
		public function get context():Context3D { return _context; }
		
		//---------------------------------------------------------
		
		/// @private
		private function addLineNumbers(code:String):String {
			if (code == null) return "";
			var lines:Array = code.split("\n");
			var count:int = 0;
			for (var i:int = 0; i < lines.length; i++) {
				code = lines[i];
				if (code.substr(0, 1) != "/" && code.length > 0) {
					// Insert line number
					code = lines[i];
					lines[i] = (++count) + ". \t " + code;
				} else {
					if (code != "") lines[i] = "    \t " + code;
				}
			}
			// Remove doubled blank lines
			for (i = lines.length - 2; i >= 0; i--) {
				if (lines[i] == lines[i + 1] && lines[i] == "") {
					lines.splice(i + 1, 1);
				}
			}
			return lines.join("\n");
		}
		
		/// @private
		private function countTokenLines(code:String):int {
			if (code == null || code == "") return 0;
			
			var lines:Array = code.split("\n");
			var count:int = 0;
			for (var i:int = 0; i < lines.length; i++) {
				if (code.substr(0, 1) != "/" && code.length > 0) {
					// It's a line of code, so count it!
					lines[i] = (++count) + ". \t " + code;
				}
			}
			return count;
		}
		
		//---------------------------------------------------------
		
		/// Use this function to manually assign, clear or append to the vertex opcode
		protected function setVertexOpcode(opcode:String, append:Boolean = false):void {
			if (Assembler.isPreparing && Assembler.assemblingVertex) {
				if (append) {
					if (Assembler.code == null) Assembler.code = "";
					Assembler.code += opcode;
				} else {
					Assembler.code = opcode;
				}
				Assembler.instructionCount = countTokenLines(Assembler.code);
			} else {
				if (append) {
					if (_vertexOpcode == null) _vertexOpcode = "";
					_vertexOpcode += opcode;
				} else {
					_vertexOpcode = opcode;
				}
				_vertexInstructions = countTokenLines(Assembler.code);
			}
		}
		
		/// Use this function to manually assign, clear or append to the fragment opcode
		protected function setFragmentOpcode(opcode:String, append:Boolean = false):void {
			if (Assembler.isPreparing && !Assembler.assemblingVertex) {
				if (append) {
					if (Assembler.code == null) Assembler.code = "";
					Assembler.code += opcode;
				} else {
					Assembler.code = opcode;
				}
				Assembler.instructionCount = countTokenLines(Assembler.code);
			} else {
				if (append) {
					if (_fragmentOpcode == null) _fragmentOpcode = "";
					_fragmentOpcode += opcode;
				} else {
					_fragmentOpcode = opcode;
				}
				_fragmentInstructions = countTokenLines(Assembler.code);
			}
		}
		
		/// Use this function to manually assign or clear the shader program
		protected function setProgram(value:Program3D):void { _program = value; }
		
		/// Use this function to manually assign a context
		protected function setContext(context:Context3D):void { 
			if (context == null) throw new Error("Parameter 'context' can not be null.");
			_context = context; 
		}
		
		//---------------------------------------------------------
		
		/// @private  Prepare AGAL opcode to be passed to AGALMiniAssembler as the vertex program
		private function prepVertexShader():void {
			if (Assembler.isPreparing) return;  // Prevent an inifinte loop if called during prep
			Assembler.isPreparing = true;
			init();
			if (_vertexOpcode == null || _vertexOpcode == "") {
				_vertexOpcode = "";
				Assembler.prep(true, assemblyDebug);
				_vertexShader();
				_vertexOpcode += Assembler.code;
				_vertexInstructions = Assembler.instructionCount;
			}
			Assembler.isPreparing = false;
		}
		
		/// @private  Prepare AGAL opcode to be passed to AGALMiniAssembler as the fragment program
		private function prepFragmentShader():void {
			if (Assembler.isPreparing) return;  // Prevent an inifinte loop if called during prep
			Assembler.isPreparing = true;
			init();
			if (_fragmentOpcode == null || _fragmentOpcode == "") {
				_fragmentOpcode = "";
				Assembler.prep(false, assemblyDebug);
				_fragmentShader();
				_fragmentOpcode += Assembler.code;
				_fragmentInstructions = Assembler.instructionCount;
			}
			Assembler.isPreparing = false;
		}
		
		//------------------------------------------------------
		
		/**
		 * Assemble and upload the shader program.
		 * Note:  The shader will only be assembled and uploaded if the 'program' property of this instance is null.
		 * In order to reassemble and re-upload the program, dispose() should be called first.
		 * @param	context		The Context3D instance that will use this shader
		 * @return	Returns a reference to the Program3D instance
		 */
		public function upload(context:Context3D):Program3D {
			if (_program) return _program;
			_context = context;
			_program = context.createProgram();
			
			try {
				_program.upload(assembleVertex(), assembleFragment());
			} catch (err:Error) {
				if (debug) {
					trace("\nVERTEX SHADER ___________________________");
					trace(getVertexOpcode(true));
					trace("\nFRAGMENT SHADER _________________________");
					trace(getFragmentOpcode(true));
					trace("\nAGAL ERROR ______________________________");
				}
				trace(err);
			}
			
			return _program;
		}
		
		/// @private
		private function assembleVertex():ByteArray {
			prepVertexShader();
			return Assembler.assemble(_vertexOpcode);
		}
		
		/// @private
		private function assembleFragment():ByteArray {
			prepFragmentShader();
			return Assembler.assemble(_fragmentOpcode);
		}
		
		/**
		 * Release all resources, including the shader program uploaded to the GPU.
		 * Calling upload() after dispose() has been called will result in the shader being recompiled and uploaded.
		 */
		public function dispose():void {
			if (_program) _program.dispose();
			_context = null;
			_program = null;
			_vertexOpcode = null;
			_vertexInstructions = 0;
			_fragmentOpcode = null;
			_fragmentInstructions = 0;
		}
		
		//------------------------------------------------------
		
		
		/// Add a comment to the opcode.  Helpful if you want to examine the opcode constructed by EasyAGAL.
		/// Commenting is disabled when EasyBase::debug is set to false.
		static protected function comment(...remarks):void {
			// if (Assembler.assemblingDebug) {
				Assembler.append("\n", false);
				for (var i:int = 0; i < remarks.length; i++) {
					Assembler.append("// " + remarks[i], false);
				}
			// }
		}
		
		//{ REGISTERS:  Initialization and Access
		
		
		static internal const ATTRIBUTE_COUNT:int = 8;
		static internal const VCONST_COUNT:int = 128;
		static internal const FCONST_COUNT:int = 28;
		static internal const TEMP_COUNT:int = 8;
		static internal const VARYING_COUNT:int = 8;
		static internal const SAMPLER_COUNT:int = 8;
		
		
		/// @private
		private function init():void {
			if (initialized) return;
			var i:int;
			
			_ATTRIBUTE = new Vector.<IRegister>;
			for (i = 0; i < ATTRIBUTE_COUNT; i++)  _ATTRIBUTE.push(new Register("ATTRIBUTE", "va", null, i));
			_ATTRIBUTE.fixed = true;
			
			_CONST = new Vector.<IRegister>;
			for (i = 0; i < VCONST_COUNT; i++)  _CONST.push(new Register("CONST", "vc", (i < FCONST_COUNT) ? "fc" : null, i));
			_CONST.fixed = true;
			
			_TEMP = new Vector.<IRegister>;
			for (i = 0; i < TEMP_COUNT; i++)  _TEMP.push(new Register("TEMP", "vt", "ft", i));
			_TEMP.fixed = true;
			
			_VARYING = new Vector.<IRegister>;
			for (i = 0; i < VARYING_COUNT; i++)  _VARYING.push(new Register("VARYING", "v", "v", i));
			_VARYING.fixed = true;
			
			_SAMPLER = new Vector.<ISampler>;
			for (i = 0; i < SAMPLER_COUNT; i++)  _SAMPLER.push(new Sampler(i));
			_SAMPLER.fixed = true;
			
			_OUTPUT = new Register("OUTPUT", "op", "oc");
			
			initialized = true;
		}
		
		
		/**
		 * { vc[] }  Use a register component to specify the index of a CONSTANT register.
		 * Available only in vertex shaders.
		 * @param	index
		 * @return	Returns a CONST register in the format:  vc[vt0.x]  or  fc[ft3.y]
		 */
		protected function CONST_byIndex(index:IComponent):IRegister {
			return new Register("CONST", "vc[" + (index as Component).reg + "]", null);  // "fc[" + (index as Component).reg + "]"
		}
		
		/**
		 * { vc0-127 / fc0-27 }  CONSTANT REGISTERS
		 * These hold read-only values, passed as parameters from ActionScript using Context3D::setProgramConstants().
		 * There are 128 constants available to vertex shaders, but only 28 to fragment shaders.
		 */
		protected function get CONST():Vector.<IRegister> { return _CONST; }
		
		/**
		 * { vt0-7 / ft0-7 }  TEMPORARY REGISTERS
		 * These registers can be used to temporarily store the results of calculations.
		 * There are 8 temporary registers available to vertex shaders, and another 8 to pixel shaders.
		 */
		protected function get TEMP():Vector.<IRegister> { return _TEMP; }
		
		/**
		 * { va0-7 }  VERTEX ATTRIBUTE BUFFER REGISTERS
		 * These registers hold up to eight different attributes of the current vertex
		 * being processed.  Vertex Attribute registers are only available in vertex shaders.
		 * Data is passed by ActionScript using the function Context3D::setVertexBufferAt().
		 * Attributes of a vertex will probably include position, as well as UV texture values, 
		 * vertex color, vertex normal, or any other information that your shader can make use of.
		 */
		protected function get ATTRIBUTE():Vector.<IRegister> { return _ATTRIBUTE; }
		
		/**
		 * { op / oc }  OUTPUT REGISTER - Position or Color
		 * The output register is where the result of the shader must be stored.
		 * For vertex shaders, this output is the clip-space position of the vertex.
		 * For fragment shaders it is the color of the pixel.
		 * There is only one Output register for the vertex shader and one for the fragment shader.
		 */
		protected function get OUTPUT():IRegister { return _OUTPUT; }
		// For more about the clip-space coordinate system, see:  
		// http://http.developer.nvidia.com/CgTutorial/cg_tutorial_chapter04.html
		
		/**
		 * { v0-7 }  VARYING REGISTERS
		 * Used to pass data from the vertex shader to the fragment shader.
		 * When the fragment shader is run, these registers will contain interpolations
		 * of the values passed by the vertex shader for each vertex of the polygon
		 * of which the fragment is a part.
		 * There are 8 Varying registers, shared by both vector and fragment shaders.
		 */
		protected function get VARYING():Vector.<IRegister> { return _VARYING; }
		
		/**
		 * { fs0-7 }  FRAGMENT (TEXTURE) SAMPLER REGISTERS
		 * The Sampler registers are used to pick color values from textures,
		 * based on UV coordinates.  Texture images are passed from Actionscript with 
		 * the function Context3D::setTextureAt(index:uint, texture:BitmapData) where
		 * the index corresponds to the Fragment Sampler register number.
		 */
		protected function get SAMPLER():Vector.<ISampler> { return _SAMPLER; }
		
		//} -----------------------------------------------------------------		
		
	}
}
