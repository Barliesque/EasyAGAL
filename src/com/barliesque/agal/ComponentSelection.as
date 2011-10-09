package com.barliesque.agal {
	/**
	 * A class allowing an arbitrary selection of register components to be passed as a parameter
	 * 
	 * @author David Barlia
	 */
	internal class ComponentSelection implements IField {
		
		private var _register:String;
		
		public function ComponentSelection(register:Register, prop:String) {
			_register = register.reg + ((prop.length > 0) ? ("." + xyzwOnly(prop)) : "");
			
			// Validate components
			//if (Assembler.assemblingDebug) {
				if (prop.length > 4) throw new Error("Illegal component selection: " + _register);  // This is possible:  CONST[0]._("rgbar")
				for (var i:int = 0; i < prop.length; i++ ) {
					if (!Component.valid(prop.substr(i,1))) throw new Error("Illegal component selection: " + _register);  // This is possible:  CONST[0]._("foo")
				}
			//}
		}
		
		/// @private
		internal function get reg():String { 
			return _register;
		}
		
		
		/**
		 * This is a workaround for a bug in AGALMiniAssembler that mishandles rgba component accessors.
		 * @param	components		Component accessors, guaranteed lowercase in Register.as
		 * @return	
		 */
		static internal function xyzwOnly(components:String):String {
			
			var output:String = "";
			for (var i:int = 0; i < components.length; i++) {
				var input:String = components.substr(i, 1);
				switch (input) {
					case "r":	output += "x";  	break;
					case "g":	output += "y";  	break;
					case "b":	output += "z";  	break;
					case "a":	output += "w";  	break;
					default:	output += input;	break;
				}
			}
			return output;
		}
		
	}
}