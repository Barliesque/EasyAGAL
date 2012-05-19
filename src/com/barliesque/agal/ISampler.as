package com.barliesque.agal {
	
	/**
	 * Marks a register class as being a SAMPLER register.
	 * Use this interface when assigning variables as "aliases" to texture sampler registers, or when defining parameters for a macro function.
	 * Note that SAMPLER registers do not support component selection.
	 * 
	 * @author David Barlia
	 */
	public interface ISampler extends IIField {
		function toString():String;
	}
	
}