package {
	import com.adobe.utils.PerspectiveMatrix3D;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	
	/**
	 * ...
	 * @author David Barlia
	 */
	public class LightingExample extends MovieClip {
		
		private var context:Context3D;
		private var stage3D:Stage3D;
		private var shader:LightedRender;
		
		[Embed(source='media/created-with.png')]
		public var createdWith:Class;
		
		[Embed(source='media/box.png')]
		public var textureClass:Class;
		
		private const CONTEXT_WIDTH:Number = 800;
		private const CONTEXT_HEIGHT:Number = 600;
		
		private var viewMatrix:Matrix3D;
		private var modelMatrix:Matrix3D;
		private var projection:PerspectiveMatrix3D;
		private var pivot:Vector3D;
		private var lightPos:Vector3D;
		private var lightColor:Vector3D;
		private var ambient:Vector3D;
		
		public function LightingExample():void {
			// Set the default stage behavior
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// Request a 3D context instance
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, contextReady, false, 0, true);
			stage3D.requestContext3D(Context3DRenderMode.AUTO);
			
			trace("Awaiting context...");
		}
	  
		
		private function contextReady(event:Event):void {
			
			stage3D.removeEventListener(Event.CONTEXT3D_CREATE, contextReady);
			
			// Get the new context
			context = stage3D.context3D;
			trace("Got context!  " + context);
			
			// Configure back buffer
			context.configureBackBuffer(CONTEXT_WIDTH, CONTEXT_HEIGHT, 2, true);
			context.setCulling(Context3DTriangleFace.BACK);
			stage3D.x = stage3D.y = 0;
			
			// Prepare vertex data:  x,y,z, nx,ny,nz, u,v  (position, normal, texture)
			var vertexData:Vector.<Number> = Vector.<Number>([
				 0.5,  0.5, -0.5,	0,0,-1,		1,0,	// 	Front
				-0.5,  0.5, -0.5,	0,0,-1,		0,0,	// 
				-0.5, -0.5, -0.5,	0,0,-1,		0,1,	// 
				 0.5, -0.5, -0.5,	0,0,-1,		1,1,	// 
				                           
				 0.5, -0.5, -0.5,	0,-1,0,		1,0,	//  Bottom
				-0.5, -0.5, -0.5,	0,-1,0,		0,0,	// 
				-0.5, -0.5,  0.5,	0,-1,0,		0,1,	// 
				 0.5, -0.5,  0.5,	0,-1,0,		1,1,	// 
				                           
				-0.5,  0.5,  0.5,	0,0,1, 		1,0,	// 	Back
				 0.5,  0.5,  0.5,	0,0,1,		0,0,	// 
				 0.5, -0.5,  0.5,	0,0,1,		0,1,	// 
				-0.5, -0.5,  0.5,	0,0,1,		1,1,	// 
				                           
				-0.5,  0.5,  0.5,	0,1,0, 		1,0,	// 	Top
				 0.5,  0.5,  0.5,	0,1,0,		0,0,	// 
				 0.5,  0.5, -0.5,	0,1,0,		0,1,	// 
				-0.5,  0.5, -0.5,	0,1,0,		1,1,	// 
				                           
				-0.5,  0.5, -0.5,	-1,0,0,		1,0,	// 	Left
				-0.5,  0.5,  0.5,	-1,0,0,		0,0,	// 
				-0.5, -0.5,  0.5,	-1,0,0,		0,1,	// 
				-0.5, -0.5, -0.5,	-1,0,0,		1,1,	// 
				                           
				 0.5,  0.5,  0.5,	1,0,0, 		1,0,	// 	Right
				 0.5,  0.5, -0.5,	1,0,0,		0,0,	// 
				 0.5, -0.5, -0.5,	1,0,0,		0,1,	// 
				 0.5, -0.5,  0.5,	1,0,0,		1,1		// 	  	
			]);
			
			
			var indexData:Vector.<uint> = Vector.<uint>([
				0, 1, 2,		0, 2, 3,		// Front face
				4, 5, 6,		4, 6, 7,        // Bottom face
				8, 9, 10,		8, 10, 11,      // Back face
				14, 13, 12,		15, 14, 12,     // Top face
				16, 17, 18,		16, 18, 19,     // Left face
				20, 21, 22,		20, 22, 23      // Right face
			]);
			
			// Prep the bitmap data to be used as a texture
			var texture:BitmapData = (new textureClass() as Bitmap).bitmapData;
			
			// Prepare a shader for rendering
			shader = new LightedRender();
			shader.upload(context);
			shader.setGeometry(vertexData, indexData, texture);
			
			// The projection defines a 3D perspective to be rendered
			projection = new PerspectiveMatrix3D();
			projection.perspectiveFieldOfViewRH(45, CONTEXT_WIDTH / CONTEXT_HEIGHT, 1, 500);
			
			// The pivot will keep track of the model's current rotation
			pivot = new Vector3D();
			
			// Prepare a matrix which we'll use to apply transformations to the model
			modelMatrix = new Matrix3D();
			modelMatrix.identity();
			modelMatrix.appendRotation(45, Vector3D.X_AXIS, pivot);
			modelMatrix.appendRotation(45, Vector3D.Y_AXIS, pivot);
			modelMatrix.appendRotation(45, Vector3D.Z_AXIS, pivot);
			
			// The view matrix will contain the concatenation of all transformations
			viewMatrix = new Matrix3D();
			
			// Prepare lighting
			lightColor = new Vector3D(0.95, 0.80, 0.55, 0.8);  // R,G,B,strength
			ambient = new Vector3D(0.00, 0.05, 0.1);
			lightPos = new Vector3D(1.0, 1.0, -4.0, 0.2);
			
			// Start rendering frames
			addEventListener(Event.ENTER_FRAME, renderFrame, false, 0, true);
			
			// Created with EasyAGAL!
			var bitmap:Bitmap = new createdWith();
			bitmap.y = CONTEXT_HEIGHT - bitmap.height;
			addChild(bitmap);
		}
		
		
		private function renderFrame(e:Event):void {
			// Clear away the old frame render
			context.clear(0.05, 0.12, 0.18);  // Dark grey background
			
			// Rotate the model matrix
			modelMatrix.appendRotation(0.4, Vector3D.X_AXIS, pivot);
			modelMatrix.appendRotation(0.3, Vector3D.Y_AXIS, pivot);
			
			// Calculate the view matrix, and run the shader program!
			viewMatrix.identity();
			viewMatrix.append(modelMatrix);
			viewMatrix.appendTranslation(0, 0, -2);
			viewMatrix.append(projection);
			viewMatrix.transpose();
			
			shader.render(viewMatrix, lightPos, lightColor, ambient);
			
			// Show the newly rendered frame on screen
			context.present();
		}
		
		
	}
}