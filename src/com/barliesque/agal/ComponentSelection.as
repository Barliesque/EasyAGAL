package com.barliesque.agal {
	/**
	 * A class allowing an arbitrary selection of register components to be passed as a parameter
	 * 
	 * @author David Barlia
	 */
	internal class ComponentSelection implements IField {
		
		private var _register:String;
		private var _type:String;
		
		public function ComponentSelection(register:Register, prop:String) {
			_register = register.reg + ((prop.length > 0) ? ("." + prop) : "");
			_type = register.type;
			
			// Validate components
			if (prop.length > 4) throw new Error("Illegal component selection: " + _register);  // Catches something like this:  CONST[0]._("rgbar")
			for (var i:int = 0; i < prop.length; i++ ) {
				if (!Component.valid(prop.substr(i,1))) throw new Error("Illegal component selection: " + _register);  // Catches something like this:  CONST[0]._("foo")
			}
		}
		
		public function toString():String {
			return '[ComponentSelection name="' + _register + '" alias="' + RegisterData.getAlias(this) + '"]';
		}
		
		
		/// @private
		internal function get reg():String { 
			return _register;
		}
		
		/// @private
		internal function get type():String { 
			return _type;
		}
		
	}
}