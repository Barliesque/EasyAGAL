package {
	import com.barliesque.agal.EasierAGAL;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	
	
	/**
	 * A simple test shader that accepts xyz vertex data with rgb vertex colors.
	 * @author David Barlia, david@barliesque.com
	 */
	public class BasicRender extends EasierAGAL {
		
		private var vertexBuffer:VertexBuffer3D;
		private var indexBuffer:IndexBuffer3D;
		
		/// x, y, z, r, g, b
		public const DATA32_PER_VERTEX:uint = 6;
		
		
		public function BasicRender() {
			// Passing true here means we'll assemble the shader in debug mode
			super(true);
		}
		
		
		override protected function _vertexShader():void {
			comment("Apply a 4x4 matrix to transform vertices to clip-space");
			multiply4x4(OUTPUT, ATTRIBUTE[0], CONST[0]);
			
			comment("Pass vertex color to fragment shader");
			move(VARYING[0], ATTRIBUTE[1]);
		}
		
		
		override protected function _fragmentShader():void {
			// Output the interpolated vertex color for this pixel
			move(OUTPUT, VARYING[0]);
		}
		
		
		public function setGeometry(vertices:Vector.<Number>, indices:Vector.<uint>):void {
			// Upload vertex data
			if (vertexBuffer != null) vertexBuffer.dispose();
			vertexBuffer = context.createVertexBuffer(vertices.length / DATA32_PER_VERTEX, DATA32_PER_VERTEX);
			vertexBuffer.uploadFromVector(vertices, 0, vertices.length / DATA32_PER_VERTEX);
			
			// Upload polygon data (vertex indices)
			if (indexBuffer != null)  indexBuffer.dispose();
			indexBuffer = context.createIndexBuffer(indices.length);
			indexBuffer.uploadFromVector(indices, 0, indices.length);
		}
		
		
		public function render(viewMatrix:Matrix3D):void {
			// Tell the 3D context that this is the current shader program to be rendered
			context.setProgram(program);
			
			// Set ATTRIBUTE Registers to point at vertex data
			context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3); // xyz
			context.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3); // rgb
			
			// Pass viewMatrix into constant registers
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, viewMatrix);
			
			// Render the shader!
			context.drawTriangles(indexBuffer);
		}
		
		
		override public function dispose():void {
			if (vertexBuffer) {
				vertexBuffer.dispose();
				vertexBuffer = null;
			}
			if (indexBuffer) {
				indexBuffer.dispose();
				indexBuffer = null;
			}
			super.dispose();
		}
		
		
	}
}


