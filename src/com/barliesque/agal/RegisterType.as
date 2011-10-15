package com.barliesque.agal {
	/**
	 * ...
	 * @author David Barlia
	 */
	public class RegisterType {
		
		static public const CONST:String = "CONST";
		static public const TEMP:String = "TEMP";
		static public const ATTRIBUTE:String = "ATTRIBUTE";
		static public const VARYING:String = "VARYING";
		static public const SAMPLER:String = "SAMPLER";
		static public const OUTPUT:String = "OUTPUT";
		
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
		 * @param	register	Either a register object, or a string as defined in RegisterType, e.g. RegisterType.CONST_REG = "CONST"
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
		 * @return	Returns a string constant as defined in RegisterType, e.g. RegisterType.CONST_REG = "CONST"
		 */
		static public function getType(register:*):String {
			if (register is Sampler) return SAMPLER;
			if (register is Register) return (register as Register).type;
			if (register is Component) return (register as Component).type;
			if (register is ComponentSelection) return (register as ComponentSelection).type;
			return null;
		}
		
		
	}
}