package {
	import com.barliesque.agal.EasierAGAL;
	import com.barliesque.agal.TextureFlag;
	import flash.display.BitmapData;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	
	
	/**
	 * A simple shader that accepts xyz vertex data with uv texture coordinates.
	 * @author David Barlia, david@barliesque.com
	 */
	public class TexturedRender extends EasierAGAL {
		
		private var vertexBuffer:VertexBuffer3D;
		private var indexBuffer:IndexBuffer3D;
		private var texture3D:Texture;
		
		/// x, y, z, u, v
		public const DATA32_PER_VERTEX:uint = 5;
		
		
		public function TexturedRender() {
			// Passing true here means we'll assemble the shader in debug mode
			super(true);
		}
		
		
		override protected function _vertexShader():void {
			comment("Apply a 4x4 matrix to transform vertices to clip-space");
			multiply4x4(OUTPUT, ATTRIBUTE[0], CONST[0]);
			
			comment("Pass uv coordinates to fragment shader");
			move(VARYING[0], ATTRIBUTE[1]);
		}
		
		
		override protected function _fragmentShader():void {
			comment("Use UV coordinates passed from vertex shader to sample the texture");
			sampleTexture(TEMP[1], VARYING[0], SAMPLER[0], [TextureFlag.TYPE_2D, TextureFlag.MODE_CLAMP, TextureFlag.FILTER_LINEAR]);
			move(OUTPUT, TEMP[1]);
		}
		
		
		public function setGeometry(vertices:Vector.<Number>, indices:Vector.<uint>, textureBitmap:BitmapData):void {
			// Upload vertex data
			if (vertexBuffer != null) vertexBuffer.dispose();
			vertexBuffer = context.createVertexBuffer(vertices.length / DATA32_PER_VERTEX, DATA32_PER_VERTEX);
			vertexBuffer.uploadFromVector(vertices, 0, vertices.length / DATA32_PER_VERTEX);
			
			// Upload polygon data (vertex indices)
			if (indexBuffer != null)  indexBuffer.dispose();
			indexBuffer = context.createIndexBuffer(indices.length);
			indexBuffer.uploadFromVector(indices, 0, indices.length);
			
			// Upload texture
			if (texture3D != null) texture3D.dispose();
			texture3D = context.createTexture(textureBitmap.width, textureBitmap.height, Context3DTextureFormat.BGRA, false);
			texture3D.uploadFromBitmapData(textureBitmap);
		}
		
		
		public function render(viewMatrix:Matrix3D):void {
			// Tell the 3D context that this is the current shader program to be rendered
			context.setProgram(program);
			
			// Set ATTRIBUTE Registers to point at vertex data
			context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3); // xyz
			context.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2); // uv
			
			// Set SAMPLER Register to point at our texture
			context.setTextureAt(0, texture3D);
			
			// Pass viewMatrix into constant registers
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, viewMatrix);
			
			// Render the shader!
			context.drawTriangles(indexBuffer);
		}
		
		
		override public function dispose():void {
			if (texture3D) {
				texture3D.dispose();
				texture3D = null;
			}
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


