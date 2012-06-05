package com.barliesque.agal {
	
	/**
	 * Pluggable class for testing shader execution. <b>COMING SOON!</b>
	 * @author David Barlia
	 */
	internal class EasyTest implements ITest {
		
		// opcodes
		private static const MOV:String	= "mov";
		private static const ADD:String	= "add";
		private static const SUB:String	= "sub";
		private static const MUL:String	= "mul";
		private static const DIV:String	= "div";
		private static const RCP:String	= "rcp";
		private static const MIN:String	= "min";
		private static const MAX:String	= "max";
		private static const FRC:String	= "frc";
		private static const SQT:String	= "sqt";
		private static const RSQ:String	= "rsq";
		private static const POW:String	= "pow";
		private static const LOG:String	= "log";
		private static const EXP:String	= "exp";
		private static const NRM:String	= "nrm";
		private static const SIN:String	= "sin";
		private static const COS:String	= "cos";
		private static const CRS:String	= "crs";
		private static const DP3:String	= "dp3";
		private static const DP4:String	= "dp4";
		private static const ABS:String	= "abs";
		private static const NEG:String	= "neg";
		private static const SAT:String	= "sat";
		private static const M33:String	= "m33";
		private static const M44:String	= "m44";
		private static const M34:String	= "m34";
		private static const KIL:String	= "kil";
		private static const TEX:String	= "tex";
		private static const SGE:String	= "sge";
		private static const SLT:String	= "slt";
		private static const SGN:String	= "sgn";
		
		/*  MYSTERY OPCODES - Will they ever...?
		private static const IFZ:String	= "ifz";
		private static const INZ:String	= "inz";
		private static const IFE:String	= "ife";
		private static const INE:String	= "ine";
		private static const IFG:String	= "ifg";
		private static const IFL:String	= "ifl";
		private static const IEG:String	= "ieg";
		private static const IEL:String	= "iel";
		private static const ELS:String	= "els";
		private static const EIF:String	= "eif";
		private static const REP:String	= "rep";
		private static const ERP:String	= "erp";
		private static const BRK:String	= "brk";
		*/
		
		
		// Call <code>EasyTest.enable();</code> before attempting to use <code>EasyBase::test()</code>
		static public function enable():void {
			EasyBase.test = new EasyTest();
		}
		
		
		public function execute(opcode:String, ...params):void {
			switch(opcode) {
				
				case ADD:	add.call(null, params);		break;
				
				default:
					throw new Error("Unrecognized opcode: " + opcode);
			}
		}
		
		
		private function add(dest:IField, source1:IField, source2:IField):void {
			
		}
		
		
		
		
	}
}