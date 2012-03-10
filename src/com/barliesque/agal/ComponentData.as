package com.barliesque.agal {
	
	/**
	 * Manage the assignment of registers and components to named aliases.
	 * @author David Barlia
	 */
	internal class ComponentData {
		
		static private const COMPONENT:Object = { x:1, y:2, z:4, w:8, r:1, g:2, b:4, a:8 };
		static private const UNASSIGNED:String = "(unassigned)";
		static private const UNSET:String = "(unset)";
		
		static private var data:Object = { };
		
		static private var regName:String;
		static private var mask:uint;
		
		
		/**
		 * Erases all data associated with registers and components
		 */
		static public function clear():void {
			data = { };
		}
		
		/**
		 * Assigns a register (or subset of its components) to a named alias.  Attempting to assign an alias to a register or component that has already been assigned will cause an error to be thrown bringing the conflict to light.<br/>
		 * <b>Usage:</b>  <code>var myAlias:IRegister = assign(TEMP[0], "myAlias");</code><br/>
		 * <code>var position:IField = assign(ATTRIBUTE[0].xyz, "position");</code>
		 * @param	field	A register, component or component selection.  Sampler registers may not be assigned aliases.
		 * @param	alias	A unique string identifier.
		 * @return	Returns the value passed into the field parameter, allowing alias and variable assignment in a single statement syntax -- See example usage above.
		 */
		static public function assign(field:IField, alias:String):IField {
			setAlias(field, alias, true);
		}
		
		/**
		 * 
		 * @param	field
		 */
		static public function unassign(field:IField):void {
			setAlias(field, UNASSIGNED, false);
		}
		
		
		/**
		 * 
		 * @param	field
		 * @return	Returns true if no alias has been assigned to any of the components
		 */
		static public function isAssigned(field:IField):Boolean {
			parse(field);
			var regData:RegisterData = data[regName];
			if (regData == null) return false;
			return regData.isAssigned(mask);
		}
		
		//-------------------------------------------------------------------
		
		/// Set or clear an alias
		static private function setAlias(field:IField, alias:String, assignedCheck:Boolean):IField {
			parse(field);
			var regData:RegisterData = data[regName];
			if (regData == null) regData = data[regName] = new RegisterData();
			if (assignedCheck) {
				if (regData.isAssigned(mask)) {
					throw new Error("Assignment conflict:  [" + regName + "] is already assigned to '" + regData.getAlias(mask) );
				}
			}
			regData.setAlias(alias, mask);
			
			return field;
		}
		
		
		///  Parse register and components being specified.  Result goes into static vars:  regName & mask
		static private function parse():void {
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
}


class RegisterData {
	private var alias:Vector.<String> = <String>.[ComponentData.UNASSIGNED, ComponentData.UNASSIGNED, ComponentData.UNASSIGNED, ComponentData.UNASSIGNED];
	private var value:Array = [ComponentData.UNSET, ComponentData.UNSET, ComponentData.UNSET, ComponentData.UNSET];
	private var type:Vector.<int> = <int>.[0, 0, 0, 0];
	
	public function isAssigned(mask:uint):Boolean {
		return 	((mask | 1) && (alias[0] != ComponentData.UNASSIGNED)) ||
				((mask | 2) && (alias[1] != ComponentData.UNASSIGNED)) ||
				((mask | 4) && (alias[2] != ComponentData.UNASSIGNED)) ||
				((mask | 8) && (alias[3] != ComponentData.UNASSIGNED));
	}
	
	public function getAlias(mask:uint):String {
		if ((mask | 1) && (alias[0] != ComponentData.UNASSIGNED)) return alias[0];
		if ((mask | 2) && (alias[1] != ComponentData.UNASSIGNED)) return alias[1];
		if ((mask | 4) && (alias[2] != ComponentData.UNASSIGNED)) return alias[2];
		if ((mask | 8) && (alias[3] != ComponentData.UNASSIGNED)) return alias[3];
		return ComponentData.UNASSIGNED;
	}
	
	public function setAlias(alias:String, mask:uint):void {
		if (mask | 1) this.alias[0] = alias;
		if (mask | 2) this.alias[1] = alias;
		if (mask | 4) this.alias[2] = alias;
		if (mask | 8) this.alias[4] = alias;
	}
	
	/*
	public function toString(mask:uint = 15):String {
		
	}
	
	public function setValues(values:Array, masks:Array):void {
		
	}
	
	public function getValues(mask:uint):Array {
		
	}
	*/
	
}
