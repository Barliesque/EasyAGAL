package com.barliesque.agal {
	
	/**
	 * Marks a class as a datatype that may be passed as an opcode parameter.
	 * Use this interface when assigning variables as "aliases" to registers or register component selections, or when defining parameters for a macro function.
	 * All register types (with the exception of SAMPLER registers) with or without component selections may be passed as an IField.
	 * 
	 * @author David Barlia
	 */
	public interface IField { 
		function toString():String;
	}
	
}