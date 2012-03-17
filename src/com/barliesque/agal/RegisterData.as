package com.barliesque.agal {
	
	/**
	 * Manage the assignment of aliases to registers and their components.
	 * @author David Barlia
	 */
	internal class RegisterData {
		
		static private const COMPONENT:Object = { x:1, y:2, z:4, w:8, r:1, g:2, b:4, a:8 };
		
		static private var data:Object = { };
		
		static private var regName:String;
		static private var mask:uint;
		
		static public const MODE_AUTO:int = 0;
		static public const MODE_VERTEX:int = 1;
		static public const MODE_FRAGMENT:int = 2;
		
		
		/**
		 * Erases all data associated with registers and components.
		 * @param	tempOnly	If true, only the temporary registers are cleared.
		 */
		static public function clear(tempOnly:Boolean = false):void {
			if (tempOnly) {
				for (var reg:String in data) {
					if (reg.charAt(1) == "t") delete data[reg];
				}
			} else {
				data = { };
			}
		}
		
		
		/**
		 * Assigns a register (or subset of its components) to a named alias.  Attempting to assign an alias to a register or component that has already been assigned will cause an error to be thrown bringing the conflict to light.<br/>
		 * <b>Usage:</b>  <code>var myAlias:IRegister = assign(TEMP[0], "myAlias");</code><br/>
		 * <code>var position:IField = assign(TEMP[0].xyz, "position");</code>
		 * @param	field	A register, component or component selection.  Sampler registers may not be assigned aliases.
		 * @param	alias	A unique string identifier.
		 * @param	mode	Allows vertex/fragment shader mode to be specified for assignments outside the shader program functions.
		 * @return	Returns the value passed into the field parameter, allowing alias and variable assignment in a single statement syntax -- See example usage above.
		 */
		static public function assign(field:IField, alias:String, mode:int = MODE_AUTO):* {
			var origValue:Boolean = Assembler.assemblingVertex;
			
			if (mode == MODE_AUTO) {
				if (!Assembler.isPreparing) {
					if (!isVarying(field)) throw new Error("When called outside the scope of _vertexShader() or _fragmentShader() only VARYING registers may be assigned.");
				}
			} else {
				Assembler.assemblingVertex = (mode == MODE_VERTEX);
			}
			setAlias(field, alias, true);
			Assembler.assemblingVertex = origValue;
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
		static public function unassign(field:IField, mode:int = MODE_AUTO):* {
			var origValue:Boolean = Assembler.assemblingVertex;
			if (mode == MODE_AUTO) {
				if (!Assembler.isPreparing) {
					if (!isVarying(field)) throw new Error("When called outside the scope of _vertexShader() or _fragmentShader() only VARYING registers may be (un)assigned.");
				}
			} else {
				Assembler.assemblingVertex = (mode == MODE_VERTEX);
			}
			
			setAlias(field, ComponentData.UNASSIGNED, false);
			return null;
		}
		
		
		/**
		 * Returns the alias name assigned to a register (or subset of components)
		 * @param	field	A register, component or component selection.
		 * @return	Returns the alias assigned to a register (or subset of components)
		 */
		static public function getAlias(field:IField):String {
			parse(field);
			var regData:ComponentData = data[regName];
			return regData.getAlias(mask);
		}
		
		
		/**
		 * 
		 * @param	field
		 * @return	Returns true if no alias has been assigned to any of the components
		 */
		static public function isAssigned(field:IField):Boolean {
			parse(field);
			var regData:ComponentData = data[regName];
			if (regData == null) return false;
			return regData.isAssigned(mask);
		}
		
		
		//-------------------------------------------------------------------
		
		
		/// Set or clear an alias
		static private function setAlias(field:IField, alias:String, assignedCheck:Boolean):void {
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
		static private function parse(field:IField):void {
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
		
		///  Returns true only if the specified parameter is a VARYING register (or selection)
		static private function isVarying(field:IField):Boolean {
			var name:String;
			if (field is Register) {
				name = (field as Register).reg;
			} else if (field is Component) {
				name = (field as Component).reg;
			} else {
				name = (field as ComponentSelection).reg;
			}
			if (name.charAt(0) != "v") return false;
			if (name.charCodeAt(1) < String("0").charCodeAt(0)) return false;
			if (name.charCodeAt(1) > String("9").charCodeAt(0)) return false;
			return true;
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
