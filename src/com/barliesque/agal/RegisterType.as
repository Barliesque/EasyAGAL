package com.barliesque.agal {
	
	/**
	 * A class that defines the names of registers available to AGAL, as well as some useful utility functions.
	 * @author David Barlia
	 */
	public class RegisterType {
		
		/** The EasyAGAL name for vertex and fragment Constant registers, [vc0 - vc127] and [fc0 - fc27] respectively. */
		static public const CONST:String = "CONST";
		
		/** The EasyAGAL name for vertex and fragment Temporary registers, [vt0 - 7] and [ft0 - 7] respectively. */
		static public const TEMP:String = "TEMP";
		
		/** The EasyAGAL name for vertex Attribute registers, [va0 - 7] */
		static public const ATTRIBUTE:String = "ATTRIBUTE";
		
		/** The EasyAGAL name for Varying registers, [v0 - 7] */
		static public const VARYING:String = "VARYING";
		
		/** The EasyAGAL name for fragment Sampler registers, [fs0 - 7] */
		static public const SAMPLER:String = "SAMPLER";
		
		/** The EasyAGAL name for vertex and fragment Output registers, [op] and [oc] respectively. */
		static public const OUTPUT:String = "OUTPUT";
		
		/** @private */
		static internal const ATTRIBUTE_COUNT:int = 8;
		static internal const VCONST_COUNT:int = 128;
		static internal const FCONST_COUNT:int = 28;
		static internal const TEMP_COUNT:int = 8;
		static internal const VARYING_COUNT:int = 8;
		static internal const SAMPLER_COUNT:int = 8;
		static internal const OUTPUT_COUNT:int = 1;
		static private const COUNT_VERTEX:Object = {CONST: VCONST_COUNT, TEMP: TEMP_COUNT, ATTRIBUTE: ATTRIBUTE_COUNT, VARYING: VARYING_COUNT, SAMPLER: 0, OUTPUT: OUTPUT_COUNT };
		static private const COUNT_FRAGMENT:Object = {CONST: FCONST_COUNT, TEMP: TEMP_COUNT, ATTRIBUTE: 0, VARYING: VARYING_COUNT, SAMPLER: SAMPLER_COUNT, OUTPUT: OUTPUT_COUNT };
		
		
		/**
		 * Find the total number of registers of the specified type that are available.
		 * @param	register	Either a register object, or a string as defined in RegisterType, e.g. RegisterType.CONST = "CONST"
		 */
		static public function getCount(register:*):int {
			var type:String = (register is String) ? register : getType(register);
			if (Assembler.assemblingVertex) {
				return COUNT_VERTEX[type];
			} else {
				return COUNT_FRAGMENT[type];
			}
		}
		
		
		/**
		 * Find the register type of a specified component or register.
		 * @param	field	Any register or component selection
		 * @return	Returns a string constant as defined in RegisterType, e.g. RegisterType.CONST = "CONST"
		 */
		static public function getType(register:*):String {
			if (register is Sampler) return SAMPLER;
			if (register is Register) return (register as Register).type;
			if (register is Component) return (register as Component).type;
			if (register is ComponentSelection) return (register as ComponentSelection).type;
			return null;
		}
		
		
		/**
		 * Returns true if the specified parameter is a constant register.
		 * @param	field	Any register or component selection
		 * @return	Returns true if the specified parameter is a constant register.
		 */
		static public function isConst(field:*):Boolean {
			return getType(field) == CONST;
		}
		
		
		/**
		 * Returns true if the specified parameter is a temporary register.
		 * @param	field	Any register or component selection
		 * @return	Returns true if the specified parameter is a temporary register.
		 */
		static public function isTemp(field:*):Boolean {
			return getType(field) == TEMP;
		}
		
		
		/**
		 * Returns true if the specified parameter is a register that is read only.
		 * @param	field	Any register or component selection
		 * @return	Returns true if the specified parameter is a register that is read only.
		 */
		static public function isReadOnly(field:*):Boolean {
			switch (getType(field)) {
				case ATTRIBUTE:	return true;
				case CONST:		return true;
				case TEMP:		return false;
				case VARYING:	return false;
				case OUTPUT:	return false;
				case SAMPLER:	return true;
				default:		throw new Error("Parameter is not a recognized AGAL register");
			}
			return null;
		}
		
		
	}
}