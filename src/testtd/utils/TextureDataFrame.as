package testtd.utils
{
	import flash.geom.Point;
	
	import starling.textures.Texture;
	
	public class TextureDataFrame
	{
		public var data:Texture;
		public var origin:Point;
		
		/**
		 * 	Object for storing texture data to help in placing asset in coordinate system.
		 * 	<br><b>param data: texture
		 * 	<br>param origin: texture's origin coordinates
		 */
		public function TextureDataFrame(data:Texture, origin:Point)
		{
			this.data = data;
			this.origin = origin;
		}
	}
}

