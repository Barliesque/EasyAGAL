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
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author David Barlia
	 */
	public class Example02 extends MovieClip {
		
		private var context:Context3D;
		private var stage3D:Stage3D;
		private var shader:TexturedRender;
		
		[Embed(source='media/blue-star.png')]
		public var textureClass:Class;
		
		private const CONTEXT_WIDTH:Number = 600;
		private const CONTEXT_HEIGHT:Number = 600;
		
		private const DEGS_TO_RADIANS:Number = Math.PI / 180;
		
		
		public function Example02():void {
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
			trace("Got context!");
			
			// Get the new context
			context = stage3D.context3D;
			
			// Configure back buffer
			context.configureBackBuffer(CONTEXT_WIDTH, CONTEXT_HEIGHT, 2, true);
			stage3D.x = stage3D.y = 0;
			
			// Prepare vertex data
			var vertexData:Vector.<Number> = Vector.<Number>([
				-0.5, -0.5,	0,		0.0, 0.0,		//<- 1st vertex x,y,z, u,v
				-0.5, 0.5,	0,		0.0, 1.0,		//<- 2nd vertex x,y,z, u,v
				0.5,  0.5,	0,		1.0, 1.0,		//<- 3rd vertex x,y,z, u,v
				0.5, -0.5,	0,		1.0, 0.0		//<- 4th vertex x,y,z, u,v
				]);
			
			// Connect the vertices into triangles (in counter-clockwise order)
			var indexData:Vector.<uint> = Vector.<uint>([
				0, 1, 2,	// <-- 1st Triangle
				0, 2, 3		// <-- 2nd Triangle
			]);
			
			// Prep the bitmap data to be used as a texture
			var texture:BitmapData = (new textureClass() as Bitmap).bitmapData;
			
			// Prepare a shader for rendering
			shader = new TexturedRender();
			shader.upload(context);
			shader.setGeometry(vertexData, indexData, texture);
			
			// ...and start rendering frames!
			addEventListener(Event.ENTER_FRAME, renderFrame, false, 0, true);
		}
		
		
		private function renderFrame(e:Event):void {
			// Clear away the old frame render
			context.clear();
			
			// Calculate the view matrix, and run the shader program!
			shader.render(makeViewMatrix());
			
			// Show the newly rendered frame on screen
			context.present();
		}
		
		
		public function makeViewMatrix():Matrix3D {
			var aspect:Number = CONTEXT_WIDTH / CONTEXT_HEIGHT;
			var zNear:Number = 0.01;
			var zFar:Number = 1000;
			var fov:Number = 45 * DEGS_TO_RADIANS;
			
			var view:PerspectiveMatrix3D = new PerspectiveMatrix3D();
			view.perspectiveFieldOfViewLH(fov, aspect, zNear, zFar);
			
			var m:Matrix3D = new Matrix3D();
			m.appendRotation(getTimer()/30, Vector3D.Z_AXIS);
			m.appendTranslation(0, 0, 2);
			m.append(view);
			
			return m;
		}
		
	}
}