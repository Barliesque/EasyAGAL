package com.barliesque.agal {
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	
	/**
	 * Internal base class providing common functionality of EasyAGAL and EasierAGAL
	 * @author David Barlia
	 */
	internal class EasyBase {
		
		private var _vertexOpcode:String;
		private var _fragmentOpcode:String;
		private var _vertexInstructions:uint = 0;
		private var _fragmentInstructions:uint = 0;
		private var _program:Program3D;
		private var _context:Context3D;
		
		// Register definitions
		static private var _VARYING:Vector.<IRegister> = initVarying();
		static private var _ATTRIBUTE:Vector.<IRegister> = initAttribute();
		static private var _CONST:Vector.<IRegister> = initConst();
		static private var _TEMP:Vector.<IRegister> = initTemp();
		static private var _SAMPLER:Vector.<ISampler> = initSampler();
		static private var _OUTPUT:Register = initOutput();
		
		private var debug:Boolean;
		private var assemblyDebug:Boolean;
		
		private var registerData:RegisterData;
		
		static internal var test:ITest;
		
		//---------------------------------------------------------
		
		/**
		 * @param	debug				Set to true to enable basic debugging features:  alias management, comments added to opcode, opcode trace upon rejection of program upload.
		 * @param	assemblyDebug		Set to true for opcode output from AGALMiniAssembler
		 */
		public function EasyBase(debug:Boolean = true, assemblyDebug:Boolean = false) {
			this.debug = debug;
			this.assemblyDebug = assemblyDebug;
			if (debug) registerData = new RegisterData();
		}
		
		
		/**
		 * <p>To be overridden.  Write your vertex shader here.</p>
		 * <p>This function is called internally when the shader program needs to be prepared and assembled.
		 * By extending and using the functions found in either EasyAGAL or EasierAGAL, both of which extend this class, 
		 * write your Vertex Shader program within this function.</p>
		 * <p>Note: If opcode has already been assigned to 'vertexOpcode' then that code will be used, and this function will not be called.</p>
		 * @see #setVertexOpcode()
		 */
		protected function _vertexShader():void { }
		
		/**
		 * <p>To be overridden.  Write your fragment shader here.</p>
		 * <p>This function is called internally when the shader program needs to be prepared and assembled.
		 * By extending and using the functions found in either EasyAGAL or EasierAGAL, both of which extend this class, 
		 * write your Fragment Shader program within this function.</p>
		 * <p>Note: If opcode has already been assigned to 'fragmentOpcode' then that code will be used, and this function will not be called.</p>
		 * @see #setFragmentOpcode()
		 */
		protected function _fragmentShader():void { }
		
		//---------------------------------------------------------
		
		/**
		 * <p>A count of the number of instructions in the vertex shader.</p>
		 * <p>AGAL shaders are restricted to a max of 200 instructions.
		 * If _vertexShader() has not already been called, it will be called upon access of this property.
		 * It is safe to access this property from _vertexShader() without causing an infinite loop.</p>
		 * @see #_vertexShader()
		 */
		public function get vertexInstructions():uint {
			prepVertexShader();
			if (Assembler.isPreparing && Assembler.assemblingVertex) return Assembler.instructionCount;
			return _vertexInstructions;
		}
		
		/**
		 * <p>A count of the number of instructions in the fragment shader.</p>
		 * <p>AGAL shaders are restricted to a max of 200 instructions.
		 * If _fragmentShader() has not already been called, it will be called upon access of this property.
		 * It is safe to access this property from _fragmentShader() without causing an infinite loop.</p>
		 * @see #_fragmentShader()
		 */
		public function get fragmentInstructions():uint { 
			prepFragmentShader();
			if (Assembler.isPreparing && !Assembler.assemblingVertex) return Assembler.instructionCount;
			return _fragmentInstructions;
		}
		
		/**
		 * <p>Returns vertex shader code to be passed to AGALMiniAssembler.</p>
		 * <p>If _vertexShader() has not already been called, it will be called now.
		 * It is safe to call this function from within _vertexShader() without causing an infinite loop.</p>
		 * @param	lineNumbering	If true, line numbers are added to assist in locating tokens referred to by an AGAL error message
		 * @param	formatAS3		If true, the result will be formatted as AS3 code that can be used in place of EasyAGAL instructions for faster processing.
		 * @return	Returns vertex shader code to be passed to AGALMiniAssembler
		 * @see #_vertexShader()
		 * @see #setFragmentOpcode()
		 */
		public function getVertexOpcode(lineNumbering:Boolean = false, formatAS3:Boolean = false):String { 
			prepVertexShader();
			if (Assembler.isPreparing && Assembler.assemblingVertex) {
				return ((lineNumbering || formatAS3) ? formatOpcode(Assembler.code, lineNumbering, formatAS3) : Assembler.code);
			}
			return ((lineNumbering || formatAS3) ? formatOpcode(_vertexOpcode, lineNumbering, formatAS3) : _vertexOpcode);
		}
		
		/**
		 * <p>Returns fragment shader code to be passed to AGALMiniAssembler.</p>
		 * <p>If _fragmentShader() has not already been called, it will be called now.
		 * It is safe to call this function from within _fragmentShader() without causing an infinite loop.</p>
		 * @param	lineNumbering	If true, line numbers are added to the left side to assist in locating tokens referred to by an AGAL error message
		 * @param	formatAS3		If true, the result will be formatted as AS3 code that can be used in place of EasyAGAL instructions for faster processing.
		 * @return	Returns fragment shader code to be passed to AGALMiniAssembler
		 * @see #_fragmentShader()
		 * @see #setFragmentOpcode()
		 */
		public function getFragmentOpcode(lineNumbering:Boolean = false, formatAS3:Boolean = false):String {
			prepFragmentShader();
			if (Assembler.isPreparing && !Assembler.assemblingVertex) {
				return ((lineNumbering || formatAS3) ? formatOpcode(Assembler.code, lineNumbering, formatAS3) : Assembler.code);
			}
			return ((lineNumbering || formatAS3) ? formatOpcode(_fragmentOpcode, lineNumbering, formatAS3) : _fragmentOpcode);
		}
		
		//-------------------------------------------------------
		
		/**
		 * <p>Assigns a register (or subset of its components) to a named alias.
		 * Aliases can only be assigned within the scope of <i>_fragmentShader()</i> or <i>_vertexShader()</i>.
		 * Attempting to assign an alias to a register or component that has already been assigned
		 * will cause an error to be thrown, bringing the conflict to light.  Use <i>unassign()</i> before reassigning TEMP registers to different aliases.</p>
		 * <p>Note:  All alias management is disabled when <i>EasyBase::debug</i> is false.  (See EasyAGAL/EasierAGAL constructors)
		 * 
		 * <b>Usage:</b>  <code>var myAlias:IRegister = assign(TEMP[0], "myAlias");</code><br/>
		 * <code>var position:IField = assign(TEMP[0].xyz, "position");</code>
		 * @param	field	A register, component or component selection.  Sampler registers may not be assigned aliases.
		 * @param	alias	A unique string identifier.
		 * @return	Returns the value passed into the field parameter, allowing alias and variable assignment in a single statement syntax -- See example usage above.
		 * @see #unassign()
		 */
		protected function assign(field:IIField, alias:String):* {
			if (!debug) return field;
			if (!Assembler.isPreparing) throw new Error("Aliases can only be assigned within the scope of _fragmentShader() or _vertexShader().");
			//if (registerData == null) registerData = new RegisterData();
			return registerData.assign(field, alias);
		}
		
		
		/**
		 * <p>Frees a register (or subset of components) for assignment to a different alias.</p>
		 * <p>Note:  All alias management is disabled when EasyBase::debug is false.  (See EasyAGAL/EasierAGAL constructors)
		 * 
		 * <b>Usage:</b>  <code>myAlias = unassign(TEMP[0].xyz);</code></br/>
		 * <code>myAlias = unassign(myAlias);</code>
		 * @param	field	A register, component or component selection.
		 * @return	Always returns null, allowing alias assignment and variable to be cleared in a single statement syntax -- See example usage above.
		 * @see #assign()
		 */
		protected function unassign(field:IIField):* {
			if (!debug) return field;
			if (!Assembler.isPreparing) throw new Error("Aliases can only be (un)assigned within the scope of _fragmentShader() or _vertexShader().");
			//if (registerData == null) registerData = new RegisterData();
			return registerData.unassign(field);
		}
		
		
		//-------------------------------------------------------
		
		
		/** The Program3D instance created by calling upload()  */
		public function get program():Program3D { return _program; }
		
		/** The Context3D instance the shader program has been uploaded to.  Set by calling upload().  Cleared by calling dispose(). */
		public function get context():Context3D { return _context; }
		
		//---------------------------------------------------------
		
		/** @private  Format opcode for debugging, or output as AS3 code.  */
		private function formatOpcode(code:String, lineNumbering:Boolean, formatAS3:Boolean):String {
			if (code == null || code == "") return "";
			if (!lineNumbering && !formatAS3) return code;
			
			var lines:Array = code.split("\n");
			var count:int = 0;
			
			var i:int;
			
			if (formatAS3) {
				for (i = 0; i < lines.length; i++) {
					if (lines[i].substr(0, 1) == "/") {
						// Remark line - indent, but don't add to code string
						lines[i] = "\t" + lines[i];
					} else if (lines[i].length == 0) {
						// Blank line - leave as is
					} else {
						// Code line - indent and wrap with quotes
						lines[i] = "\t\"" + lines[i] + ((i < lines.length - 2) ? "\\n\" +" : "\"");
						if (lineNumbering) {
							// Add line number as a comment
							for (var s:int = 48 - lines[i].length; s > 0; s--) lines[i] = lines[i] + " ";
							lines[i] = lines[i] + "    // " + (++count) + ".";
						}
					}
				}
			} else {
				for (i = 0; i < lines.length; i++) {
					// If we're not formatting as AS3, then we must at least be adding line numbers
					if (lines[i].substr(0, 1) != "/" && lines[i].length > 0) {
						// Code line - Insert line number
						lines[i] = (++count) + ". \t " + lines[i];
					} else {
						// Remark or Blank - Just indent
						if (lines[i] != "") lines[i] = "    \t " + lines[i];
					}
				}
			}
			
			// Wrap string code into a statement
			if (formatAS3) {
				lines.unshift(Assembler.assemblingVertex ? "setVertexOpcode(" : "setFragmentOpcode(");
				lines.push(");");
			}
			
			return lines.join("\n");
		}
		
		
		/** @private */
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
		
		/**
		 * <p>Use this function to manually assign, clear or append to the vertex opcode</p>
		 * <p>Note:  Unless debug is true (set by EasyAGAL/EasierAGAL constructor) the opcode count will not be updated.</p>
		 * @param	opcode		A string to be assigned or appended to the vertex opcode.
		 * @param	append		True to append to the existing opcode, false to replace it.  (Default is false)
		 * @see #getVertexOpcode()
		 * @see #_vertexShader()
		 */
		protected function setVertexOpcode(opcode:String, append:Boolean = false):void {
			if (Assembler.isPreparing && Assembler.assemblingVertex) {
				if (append) {
					if (Assembler.code == null) Assembler.code = "";
					Assembler.code += opcode;
				} else {
					Assembler.code = opcode;
				}
				if (debug) Assembler.instructionCount = countTokenLines(Assembler.code);
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
		
		/**
		 * <p>Use this function to manually assign, clear or append to the fragment opcode</p>
		 * <p>Note:  Unless debug is true (set by EasyAGAL/EasierAGAL constructor) the opcode count will not be updated.</p>
		 * @param	opcode		A string to be assigned or appended to the fragment opcode.
		 * @param	append		True to append to the existing opcode, false to replace it.  (Default is false)
		 * @see #getFragmentOpcode()
		 * @see #_fragmentShader()
		 */
		protected function setFragmentOpcode(opcode:String, append:Boolean = false):void {
			if (Assembler.isPreparing && !Assembler.assemblingVertex) {
				if (append) {
					if (Assembler.code == null) Assembler.code = "";
					Assembler.code += opcode;
				} else {
					Assembler.code = opcode;
				}
				if (debug) Assembler.instructionCount = countTokenLines(Assembler.code);
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
		
		/** Use this function to manually assign or clear the shader program. */
		protected function setProgram(value:Program3D):void { _program = value; }
		
		/** Use this function to manually assign a context. */
		protected function setContext(context:Context3D):void { 
			if (context == null) throw new Error("Parameter 'context' can not be null.");
			_context = context; 
		}
		
		//---------------------------------------------------------
		
		/** @private  Prepare AGAL opcode to be passed to AGALMiniAssembler as the vertex program */
		private function prepVertexShader():void {
			if (Assembler.isPreparing) return;  // Prevent an inifinte loop if called during prep
			Assembler.isPreparing = true;
			if (_vertexOpcode == null || _vertexOpcode == "") {
				_vertexOpcode = "";
				Assembler.prep(true, assemblyDebug);
				if (debug) registerData.clearTemp();  // Clear temporary register data
				_vertexShader();
				_vertexOpcode += Assembler.code;
				_vertexInstructions = Assembler.instructionCount;
			}
			Assembler.isPreparing = false;
		}
		
		/** @private  Prepare AGAL opcode to be passed to AGALMiniAssembler as the fragment program */
		private function prepFragmentShader():void {
			if (Assembler.isPreparing) return;  // Prevent an inifinte loop if called during prep
			Assembler.isPreparing = true;
			if (_fragmentOpcode == null || _fragmentOpcode == "") {
				_fragmentOpcode = "";
				Assembler.prep(false, assemblyDebug);
				if (debug) registerData.clearTemp();  // Clear temporary register data
				_fragmentShader();
				_fragmentOpcode += Assembler.code;
				_fragmentInstructions = Assembler.instructionCount;
			}
			Assembler.isPreparing = false;
		}
		
		//------------------------------------------------------
		
		/**
		 * <p>Assemble and upload the shader program.</p>
		 * <p>Note:  The shader will only be assembled and uploaded if the 'program' property of this instance is null.
		 * In order to reassemble and re-upload the program, dispose() should be called first.</p>
		 * @param	context		The Context3D instance that will use this shader
		 * @return	Returns a reference to the Program3D instance
		 * @see #dispose()
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
				trace(err.getStackTrace());
			}
			
			return _program;
		}
		
		
		/** @private */
		private function assembleVertex():ByteArray {
			prepVertexShader();
			return Assembler.assemble(_vertexOpcode);
		}
		
		/** @private */
		private function assembleFragment():ByteArray {
			prepFragmentShader();
			return Assembler.assemble(_fragmentOpcode);
		}
		
		/**
		 * Releases all resources, including the shader program uploaded to the GPU.
		 * Calling upload() after dispose() has been called will result in the shader being recompiled and uploaded.
		 * @see #upload()
		 */
		public function dispose():void {
			if (_program) _program.dispose();
			_context = null;
			_program = null;
			_vertexOpcode = null;
			_vertexInstructions = 0;
			_fragmentOpcode = null;
			_fragmentInstructions = 0;
			registerData = null;
			test = null;
		}
		
		//------------------------------------------------------
		
		
		/**
		 * Add a comment to the opcode.  Helpful if you want to examine the opcode constructed by EasyAGAL.
		 * Commenting is disabled when EasyBase::debug is set to false.
		 * @param	remarks 	Comments to be included with the opcode.  Multiple remarks will appear as multi-line comments.
		 */
		static protected function comment(...remarks):void {
			// if (EasyBase.debugging) {
				Assembler.append("\n", false);
				for (var i:int = 0; i < remarks.length; i++) {
					Assembler.append("// " + remarks[i], false);
				}
			// }
		}
		
		//{ REGISTERS:  Initialization
		
		/** @private */
		static private function initVarying():Vector.<IRegister> {
			var register:Vector.<IRegister> = new Vector.<IRegister>;
			for (var i:int = 0; i < RegisterType.VARYING_COUNT; i++)  register.push(new Register(RegisterType.VARYING, "v", "v", i));
			register.fixed = true;
			return register;
		}
		
		/** @private */
		static private function initAttribute():Vector.<IRegister> {
			var register:Vector.<IRegister> = new Vector.<IRegister>;
			for (var i:int = 0; i < RegisterType.ATTRIBUTE_COUNT; i++)  register.push(new Register(RegisterType.ATTRIBUTE, "va", null, i));
			register.fixed = true;
			return register;
		}
		
		/** @private */
		static private function initConst():Vector.<IRegister> {
			var register:Vector.<IRegister> = new Vector.<IRegister>;
			for (var i:int = 0; i < RegisterType.VCONST_COUNT; i++)  register.push(new Register(RegisterType.CONST, "vc", (i < RegisterType.FCONST_COUNT) ? "fc" : null, i));
			register.fixed = true;
			return register;
		}
		
		/** @private */
		static private function initTemp():Vector.<IRegister> {
			var register:Vector.<IRegister> = new Vector.<IRegister>;
			for (var i:int = 0; i < RegisterType.TEMP_COUNT; i++)  register.push(new Register(RegisterType.TEMP, "vt", "ft", i));
			register.fixed = true;
			return register;
		}
		
		/** @private */
		static private function initSampler():Vector.<ISampler> {
			var register:Vector.<ISampler> = new Vector.<ISampler>;
			for (var i:int = 0; i < RegisterType.SAMPLER_COUNT; i++)  register.push(new Sampler(i));
			register.fixed = true;
			return register;
		}
		
		/** @private */
		static private function initOutput():Register {
			return new Register(RegisterType.OUTPUT, "op", "oc");
		}
		
		//} -----------------------------------------------------------------		
		
		//{ REGISTERS:  Access
		
		/**
		 * { vc[] }  Use a component value to specify a CONSTANT register by its index.
		 * Available only in vertex shaders.
		 * @param	index
		 * @return	Returns a CONST register in relative format, e.g. "vc[vt0.x]"
		 */
		protected function CONST_byIndex(index:IComponent):IRegister {
			RegisterData.currentData = registerData;
			return new Register("CONST", "vc[" + (index as Component).reg + "]", null);
		}
		
		
		/**
		 * <p>{ vc0-127 / fc0-27 }  CONSTANT REGISTERS</p>
		 * <p>These hold read-only values, passed as parameters from ActionScript using Context3D::setProgramConstants().
		 * There are 128 constants available to vertex shaders, but only 28 to fragment shaders.</p>
		 * <p>Constant registers may not be used as the sole input of a calculation.  
		 * You can not, for instance, add two Constant registers together.  There are two alternatives:</p>
		 * <p>1) Pre-calculate and pass the resulting value in another Constant register.  (Usually preferred)</p>
		 * <p>2) Move one Constant register's value to a Temp register, and then perform the calculation.</p>
		 */
		protected function get CONST():Vector.<IRegister> {
			RegisterData.currentData = registerData;
			return _CONST;
		}
		
		/**
		 * <p>{ vt0-7 / ft0-7 }  TEMPORARY REGISTERS</p>
		 * <p>These registers are where most operations are carried out.  The Temp registers are read and write enabled, 
		 * and allow you to temporarily store the results of calculations.
		 * There are 8 temporary registers available to vertex shaders, and another 8 to pixel shaders.</p>
		 */
		protected function get TEMP():Vector.<IRegister> {
			RegisterData.currentData = registerData;
			return _TEMP;
		}
		
		/**
		 * <p>{ va0-7 }  VERTEX ATTRIBUTE BUFFER REGISTERS</p>
		 * <p>These registers hold up to eight different attributes of the current vertex
		 * being processed.  Vertex Attribute registers are only available in vertex shaders.
		 * Data is passed by ActionScript using the function Context3D::setVertexBufferAt().
		 * Attributes of a vertex will probably include position, as well as UV texture values, 
		 * vertex color, vertex normal, or any other information that your shader can make use of.</p>
		 */
		protected function get ATTRIBUTE():Vector.<IRegister> {
			RegisterData.currentData = registerData;
			return _ATTRIBUTE;
		}
		
		/**
		 * <p>{ op / oc }  OUTPUT REGISTER - Position or Color</p>
		 * <p>The output register is where the result of the shader must be stored.
		 * For vertex shaders, this output is the clip-space position of the vertex.
		 * For fragment shaders it is the color of the pixel.
		 * There is only one Output register for the vertex shader and one for the fragment shader.
		 * The Output register is write-only.</p>
		 * <p>For more about the clip-space coordinate system, see:  http://http.developer.nvidia.com/CgTutorial/cg_tutorial_chapter04.html</p>
		 */
		protected function get OUTPUT():IRegister { 
			RegisterData.currentData = registerData;
			return _OUTPUT;
		}
		
		/**
		 * <p>{ v0-7 }  VARYING REGISTERS</p>
		 * <p>Used to pass data from the vertex shader to the fragment shader.
		 * When the fragment shader is run, these registers will contain interpolations
		 * of the values passed by the vertex shader for each vertex of the polygon
		 * of which the fragment is a part.
		 * There are 8 Varying registers, shared by both vector and fragment shaders.</p>
		 */
		protected function get VARYING():Vector.<IRegister> { 
			RegisterData.currentData = registerData;
			return _VARYING;
		}
		
		/**
		 * <p>{ fs0-7 }  FRAGMENT (TEXTURE) SAMPLER REGISTERS</p>
		 * <p>The Sampler registers are used to pick color values from textures,
		 * based on UV coordinates.  Texture images are passed from Actionscript with 
		 * the function Context3D::setTextureAt(index:uint, texture:BitmapData) where
		 * the index corresponds to the Fragment Sampler register number.</p>
		 */
		protected function get SAMPLER():Vector.<ISampler> {
			RegisterData.currentData = registerData;
			return _SAMPLER;
		}
		
		//} -----------------------------------------------------------------		
		
	}
}
