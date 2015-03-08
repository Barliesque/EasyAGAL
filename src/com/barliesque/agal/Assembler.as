package com.barliesque.agal {
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3DProgramType;
	import flash.utils.ByteArray;
	
	/**
	 * An internal class that maintains instances of AGAMiniAssembler, and data relating to EasyAGAL's preparation of shader opcode.
	 * @author David Barlia
	 */
	internal class Assembler {
		private var realAssembler:AGALMiniAssembler;
	
		/// True while EasyAGAL code is being prepared as AGAL opcode.  Set by EasyBase.
		internal var isPreparing:Boolean = false;
		
		/// AGAL instructions to be appended by EasyAGAL classes
		internal var code:String;
		
		/// Count of instructions appended to code
		internal var instructionCount:int;
		
		/// True for VertexShader, False for FragmentShader.
		public var assemblingVertex:Boolean;
		
		/// True for debug mode, False for release.
		public var assemblyDebug:Boolean;
		
		/// Begin preparation of AGAL opcode for assembly
		public function Assembler(assemblingVertex:Boolean, assemblyDebug:Boolean):void {
			code = "";
			instructionCount = 0;
			this.assemblingVertex = assemblingVertex;
			this.assemblyDebug = assemblyDebug;
			realAssembler=new AGALMiniAssembler(assemblyDebug);
		}
		
		/// Append a line of opcode to the shader currently being prepared, and count lines
		internal function append(code:String, count:Boolean = true):void {
			this.code += code + ((code.substr(-1) == "\n") ? "" : "\n");
			if (count) instructionCount++;
		}
		
		/// Compile opcode string to a ByteArray ready to be uploaded with Program3D.
		/// NOTE: Assembler.assemblingVertex should already have been appropriately set by EasyBase.
		public function assemble(opcode:String, verbose:Boolean = false):ByteArray {
			var type:String = (assemblingVertex ? Context3DProgramType.VERTEX : Context3DProgramType.FRAGMENT);
			realAssembler.assemble(type, opcode);
		}
	}
}
