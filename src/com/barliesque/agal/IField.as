package com.barliesque.agal {
	
	/**
	 * Marks a class as a datatype that may be passed as an opcode parameter.
	 * Use this interface when assigning variables as "aliases" to registers or register component selections, or when defining parameters for a macro function.
	 * All register types (with the exception of SAMPLER registers) with or without component selections may be passed as an IField.
	 * 
	 * @author David Barlia
	 */
	public interface IField extends IIField { 
		
		/** @return Returns a string representation of the register or component selection. */
		function toString():String;
		
		/** The agal code representation of this register or component selection. (Read-only) */
		function get code():String;
		
		/** A name used to reserve this register or component selection. (Read-only) */
		function get alias():String;
	}
	
}