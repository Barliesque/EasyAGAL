package com.barliesque.agal {
        
	/**
	 * A utility function to get the register with the index following the register specified.
	 * Useful for macros that deal with Matrix functions, where a 4x4 matrix is represented by a chain of 4 registers.
	 * 
	 * @author David Barlia
	 */
	
	//public class NOT_A_CLASS {
			
			/// Get the register with the index following the register specified.
			public function nextRegister(register:IRegister):IRegister {
					var reg:Register = register as Register;
					return new Register(reg.type, reg.vertexReg, reg.fragmentReg, reg.index + 1);
			}
			
	//}
}