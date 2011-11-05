package com.barliesque.agal {
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3DProgramType;
	import flash.utils.ByteArray;
	
	/**
	 * An internal class that maintains instances of AGAMiniAssembler, and data relating to EasyAGAL's preparation of shader opcode.
	 * @author David Barlia
	 */
	internal class Assembler {
		
		static private var _debug:AGALMiniAssembler;
		static private var _release:AGALMiniAssembler;
		
		/// True while EasyAGAL code is being prepared as AGAL opcode.  Set by EasyBase.
		static internal var isPreparing:Boolean = false;
		
		/// Static variable for AGAL instructions to be appended by EasyAGAL classes
		static internal var code:String;
		
		/// Count of instructions appended to code
		static internal var instructionCount:int;
		
		/// Internal flag set while preparing opcode.  True for VertexShader, False for FragmentShader.
		static public var assemblingVertex:Boolean;
		
		/// Internal flag set while preparing opcode.  True for debug mode, False for release.
		static public var assemblyDebug:Boolean;
		
		/// Begin preparation of AGAL opcode for assembly
		static internal function prep(assemblingVertex:Boolean, assemblyDebug:Boolean):void {
			code = "";
			instructionCount = 0;
			Assembler.assemblingVertex = assemblingVertex;
			Assembler.assemblyDebug = assemblyDebug;
		}
		
		/// Append a line of opcode to the shader currently being prepared, and count lines
		static internal function append(code:String, count:Boolean = true):void {
			Assembler.code += code + ((code.substr(-1) == "\n") ? "" : "\n");
			if (count) instructionCount++;
		}
		
		/// Compile opcode string to a ByteArray ready to be uploaded with Program3D.
		/// NOTE: Assembler.assemblingVertex should already have been appropriately set by EasyBase.
		static public function assemble(opcode:String, verbose:Boolean = false):ByteArray {
			var type:String = (assemblingVertex ? Context3DProgramType.VERTEX : Context3DProgramType.FRAGMENT);
			if (assemblyDebug) {
				return Assembler.debug.assemble(type, opcode);
			}
			return release.assemble(type, opcode);
		}
		
		/// An AGALMiniAssembler instance with debug features on.
		static internal function get debug():AGALMiniAssembler {
			if (_debug == null) _debug = new AGALMiniAssembler(true);
			return _debug;
		}
		
		/// An AGALMiniAssembler instance with debug features off.
		static internal function get release():AGALMiniAssembler {
			if (_release == null) _release = new AGALMiniAssembler(false);
			return _release;
		}
		
		
	}
}