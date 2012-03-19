package com.barliesque.agal {
	
	/**
	 * Specialized register, for sampling textures
	 * 
	 * @author David Barlia
	 */
	internal class Sampler implements ISampler {
		
		private var _index:int;
		
		public function Sampler(index:int) {
			_index = index;
		}
		
		public function toString():String {
			return '[Sampler name="fs' + _index + '" alias="' + RegisterData.currentData.getAlias(this) + '"]';
		}
		
		internal function get reg():String { 
			if (Assembler.assemblingVertex) throw new Error("SAMPLER registers not available in Vertex Shaders");
			return "fs" + _index;
		}
		
		internal function get index():int { return _index; }
		
	}
}