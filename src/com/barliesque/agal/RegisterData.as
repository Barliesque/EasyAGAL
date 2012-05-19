package com.barliesque.agal {
	
	/**
	 * Manage the assignment of aliases to registers and their components.
	 * @author David Barlia
	 */
	internal class RegisterData {
		
		static private const COMPONENT:Object = { x:1, y:2, z:4, w:8, r:1, g:2, b:4, a:8 };
		
		static private var regName:String;
		static private var mask:uint;
		
		static public const MODE_AUTO:int = 0;
		static public const MODE_VERTEX:int = 1;
		static public const MODE_FRAGMENT:int = 2;
		
		static public var currentData:RegisterData;
		
		private var data:Object = { };
		
		public function RegisterData() {
			currentData = this;
		}
		
		/**
		 * Erase all data associated with registers and components.
		 */
		public function clear():void {
			data = { };
		}
		
		/**
		 * Clear only temporary register data
		 */
		public function clearTemp():void {
			for (var reg:String in data) {
				if (reg.charAt(1) == "t") {
					delete data[reg];
				}
			}
		}
		
		//-----------------------------------------------------------------------------
		
		/**
		 * Assigns a register (or subset of its components) to a named alias.  Attempting to assign an alias to a register or component that has already been assigned will cause an error to be thrown bringing the conflict to light.<br/>
		 * <b>Usage:</b>  <code>var myAlias:IRegister = assign(TEMP[0], "myAlias");</code><br/>
		 * <code>var position:IField = assign(TEMP[0].xyz, "position");</code>
		 * @param	field	A register, component or component selection.  Sampler registers may not be assigned aliases.
		 * @param	alias	A unique string identifier.
		 * @param	mode	Allows vertex/fragment shader mode to be specified for assignments outside the shader program functions.
		 * @return	Returns the value passed into the field parameter, allowing alias and variable assignment in a single statement syntax -- See example usage above.
		 */
		public function assign(field:IIField, alias:String, mode:int = MODE_AUTO):* {
			validateScope(mode, field);
			setAlias(field, alias, true);
			return field;
		}
		
		/**
		 * Frees a register (or subset of components) for assignment to a different alias.
		 * <b>Usage:</b>  <code>myAlias = unassign(TEMP[0].xyz);</code></br/>
		 * <code>myAlias = unassign(myAlias);</code>
		 * @param	field	A register, component or component selection.
		 * @param	mode	Allows vertex/fragment shader mode to be specified for calls made outside the shader program functions.
		 * @return	Always returns null, allowing alias assignment and variable to be cleared in a single statement syntax -- See example usage above.
		 */
		public function unassign(field:IIField, mode:int = MODE_AUTO):* {
			validateScope(mode, field);
			setAlias(field, ComponentData.UNASSIGNED, false);
			return null;
		}
		
		/// Make sure alias (un)assignment is being used correctly, and set Assembler mode if needed
		private function validateScope(mode:int, field:IIField):void {
			if (!Assembler.isPreparing) {
				// OUTSIDE shader preparation scope
				if (RegisterType.isTemp(field)) {
					throw new Error("Temporary registers may only be assigned an alias within the scope of _vertexShader() or _fragmentShader()");
				} else {
					if (mode == MODE_AUTO) throw new Error("Parameter 'mode' can not be MODE_AUTO outside the scope of _vertexShader() and _fragmentShader()");
				}
				Assembler.assemblingVertex = (mode == MODE_VERTEX);
			} else {
				// INSIDE shader preparation scope
				if (mode != MODE_AUTO) throw new Error("Parameter 'mode' must be MODE_AUTO when called within the scope of _vertexShader() and _fragmentShader()");
			}
		}
		
		//-----------------------------------------------------------------------------
		
		/**
		 * Returns the alias name assigned to a register (or subset of components)
		 * @param	field	A register, component or component selection.
		 * @return	Returns the alias assigned to a register (or subset of components)
		 */
		public function getAlias(field:IIField):String {
			parse(field);
			var regData:ComponentData = data[regName];
			if (regData == null) return ComponentData.UNASSIGNED;
			return regData.getAlias(mask);
		}
		
		/**
		 * Check to see if a register or component has been assigned as alias
		 * @param	field	A register, component or component selection.
		 * @return	Returns true if no alias has been assigned to any of the components
		 */
		public function isAssigned(field:IIField):Boolean {
			parse(field);
			var regData:ComponentData = data[regName];
			if (regData == null) return false;
			return regData.isAssigned(mask);
		}
		
		//-----------------------------------------------------------------------------
		
		/// Set or clear an alias
		private function setAlias(field:IIField, alias:String, assignedCheck:Boolean):void {
			parse(field);
			var regData:ComponentData = data[regName];
			if (regData == null) regData = data[regName] = new ComponentData();
			if (assignedCheck) {
				if (regData.isAssigned(mask) && regData.getAlias(mask) != alias) {
					throw new Error('Cannot assign alias "' + alias + '" because [' + regName + '] is already assigned to "' + regData.getAlias(mask, false) + '"');
				}
			}
			regData.setAlias(alias, mask);
		}
		
		
		///  Parse register and components being specified.  Result goes into class properties:  regName & mask
		private function parse(field:IIField):void {
			var part:Array;
			
			if (field is Register) {
				var register:Register = field as Register;
				regName = register.reg;
				mask = 15;  // Assign all four registers
			} else if (field is Component) {
				var component:Component = field as Component;
				part = String(component.reg).split(".");
				regName = part[0];
				mask = COMPONENT[part[1]];
			} else {
				var selection:ComponentSelection = field as ComponentSelection;
				part = String(selection.reg).split(".");
				regName = part[0];
				for (var i:int = 0; i < part[1].length; i++) {
					mask |= COMPONENT[String(part[1]).charAt(i)];
				}
			}
		}
		
		
		
	}
} //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


class ComponentData {
	
	/// No alias has been assigned to this component
	static public const UNASSIGNED:String = "(unassigned)";
	
	/// Multiple aliases are assigned to the components of this register (or some are assigned and some are unassigned)
	static public const UNSET:String = "(unset)";
	
	/// This component was last accessed in vector format
	static public const TYPE_XYZW:int = 1;
	/// This component was last accessed in color format
	static public const TYPE_RGBA:int = -1;
	/// This component has not yet been specifically selected
	static public const TYPE_DEFAULT:int = 0
	
	private var alias:Array = [UNASSIGNED, UNASSIGNED, UNASSIGNED, UNASSIGNED];
	private var value:Array; // = [UNSET, UNSET, UNSET, UNSET];
	private var type:Vector.<int>; // = Vector.<int>([0, 0, 0, 0]);
	
	
	public function isAssigned(mask:uint):Boolean {
		return 	((mask & 1) && (alias[0] != UNASSIGNED)) ||
				((mask & 2) && (alias[1] != UNASSIGNED)) ||
				((mask & 4) && (alias[2] != UNASSIGNED)) ||
				((mask & 8) && (alias[3] != UNASSIGNED));
	}
	
	public function getAlias(mask:uint, inclUnassigned:Boolean = true):String {
		// Return all aliases found for selected component(s)
		var ret:Array = [];
		if ((mask & 1) && (ret.indexOf(alias[0]) < 0) && (inclUnassigned || alias[0] != UNASSIGNED)) ret.push(alias[0]);
		if ((mask & 2) && (ret.indexOf(alias[1]) < 0) && (inclUnassigned || alias[1] != UNASSIGNED)) ret.push(alias[1]);
		if ((mask & 4) && (ret.indexOf(alias[2]) < 0) && (inclUnassigned || alias[2] != UNASSIGNED)) ret.push(alias[2]);
		if ((mask & 8) && (ret.indexOf(alias[3]) < 0) && (inclUnassigned || alias[3] != UNASSIGNED)) ret.push(alias[3]);
		return ret.join(", ");
	}
	
	public function setAlias(alias:String, mask:uint):void {
		if (mask & 1) this.alias[0] = alias;
		if (mask & 2) this.alias[1] = alias;
		if (mask & 4) this.alias[2] = alias;
		if (mask & 8) this.alias[3] = alias;
	}
	
	/* DEBUG TESTING - Coming Soon
	public function valueString(mask:uint = 15):String { }
	public function setValues(values:Array, masks:Array, type:int):void { }
	public function getValues(mask:uint, type:int):Array { }
	*/
	
}
