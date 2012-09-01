package com.barliesque.agal {
	
	/**
	 * A class allowing a single register component to be passed as a parameter
	 * 
	 * @author David Barlia
	 */
	internal class Component implements IComponent {
		
		private var _register:String;
		private var _type:String;
		
		public function Component(register:Register, prop:String) {
			_register = register.reg + "." + prop;  // ComponentSelection.xyzwOnly(prop)
			_type = register.type;
			
			if (!valid(prop)) throw new Error("Illegal component selection: " + _register);  // Catches something like this:  CONST[0]._("q")
		}
		
		public function toString():String {
			if (!Assembler.isPreparing) return '[Component]';
			if (RegisterData.currentData == null) return '[Component name="' + _register + '"]';
			return '[Component code="' + _register + '" alias="' + alias + '"]';
		}
		
		public function get code():String {
			return _register;
		}
		
		public function get alias():String {
			if (RegisterData.currentData == null) return null;
			return RegisterData.currentData.getAlias(this);
		}
		
		/// @private
		internal function get reg():String { 
			return _register;
		}
		
		/// @private
		internal function get type():String { 
			return _type;
		}
		
		/// @private
		static public function valid(prop:String):Boolean {
			switch(prop) {
				case "x":	case "y":	case "z":	case "w":	
				case "r":	case "g":	case "b":	case "a":
					return true;
			}
			return false;
		}
		
	}
}