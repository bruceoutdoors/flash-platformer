/* TileMapReader IS A MODIFIED VERSION OF ObjectMaker2D */
package  {
	
	import citrus.core.CitrusEngine;
	import citrus.core.CitrusObject;
	import citrus.objects.CitrusSprite;
	import citrus.utils.objectmakers.tmx.TmxLayer;
	import citrus.utils.objectmakers.tmx.TmxMap;
	import citrus.utils.objectmakers.tmx.TmxObject;
	import citrus.utils.objectmakers.tmx.TmxObjectGroup;
	import citrus.utils.objectmakers.tmx.TmxTileSet;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	/**
	 * The ObjectMaker is a factory utility class for quickly and easily batch-creating a bunch of CitrusObjects.
	 * Usually the ObjectMaker is used if you laid out your level in a level editor or an XML file.
	 * Pass in your layout object (SWF, XML, or whatever else is supported in the future) to the appropriate method,
	 * and the method will return an array of created CitrusObjects.
	 *
	 * <p>The methods within the ObjectMaker should be called according to what kind of layout file that was created
	 * by your level editor.</p>
	 */
	public class TileMapReader {
		
		public function TileMapReader() {
		}
		
		/**
		 * The Citrus Engine supports <a href="http://www.mapeditor.org/">the Tiled Map Editor</a>.
		 * <p>It supports different layers, objects creation and Tilesets.</p>
		 *
		 * <p>You can add properties inside layers (group, parallax...), they are processed as Citrus Sprite.</p>
		 * <p>Polygons are supported but must be drawn clockwise in TiledMap editor to work correctly.</p>
		 * 
		 * <p>For the objects, you can add their name and don't forget their types : package name + class name.
		 * It also supports properties.</p>
		 * @param levelXML the TMX provided by the Tiled Map Editor software, convert it into an xml before.
		 * @param images an array of bitmap used by tileSets. The name of the bitmap must correspond to the tileSet image source name.
		 * @param addToCurrentState Automatically adds all CitrusObjects that get created to the current state.
		 * @return An array of <code>CitrusObject</code> with all objects created.
		 * @see CitrusObject
		 */
		public static function Read(levelXML:XML, images:Array, addToCurrentState:Boolean = true):Array {
			var objects:Array = [];
			var map:TmxMap = new TmxMap(levelXML);
			
			for each(var layer:Object in map.layers_ordered) {
				if (layer is TmxLayer) {
					addTiledLayer(map, layer as TmxLayer, images, objects);
				}else if (layer is TmxObjectGroup) {
					addTiledObjectgroup(layer as TmxObjectGroup, objects);
				}else {
					throw new Error('Found layer type not supported.');
				}
			}		
			
			const ce:CitrusEngine = CitrusEngine.getInstance();
			if (addToCurrentState) {
				for each (var object:CitrusObject in objects) {
					ce.state.add(object);
				}
			}
			
			return objects;
		}
		
		static private function addTiledLayer(map:TmxMap, layer:TmxLayer, images:Array, objects:Array):void {
			// Bits on the far end of the 32-bit global tile ID are used for tile flags
			const FLIPPED_DIAGONALLY_FLAG:uint = 0x20000000;
			const FLIPPED_VERTICALLY_FLAG:uint = 0x40000000;
			const FLIPPED_HORIZONTALLY_FLAG:uint = 0x80000000;
			const FLIPPED_FLAGS_MASK:uint = ~(FLIPPED_HORIZONTALLY_FLAG | FLIPPED_VERTICALLY_FLAG | FLIPPED_DIAGONALLY_FLAG);
			const _90degInRad:Number = Math.PI * 0.5;
			
			var params:Object;
			
			var bmp:Bitmap;
			var useBmpSmoothing:Boolean;
			
			const tileRect:Rectangle = new Rectangle;
			tileRect.width = map.tileWidth;
			tileRect.height = map.tileHeight;
			
			const mapTiles:Array = layer.tileGIDs;
			const rows:uint = mapTiles.length;
			var columns:uint;
			
			const flipMatrix:Matrix = new Matrix;
			const flipBmp:BitmapData = new BitmapData(map.tileWidth, map.tileHeight, true, 0);
			const flipBmpRect:Rectangle = new Rectangle(0, 0, map.tileWidth, map.tileHeight);
			
			const tileDestInLayer:Point = new Point;
			var pathSplit:Array;
			var tilesetImageName:String;
			
			const layerBmp:BitmapData = new BitmapData(map.width * map.tileWidth, map.height * map.tileHeight, true, 0);
			
			for each (var tileSet:TmxTileSet in map.tileSets) {
				
				pathSplit = tileSet.imageSource.split("/");
				tilesetImageName = pathSplit[pathSplit.length - 1];
				
				for each (var image:Bitmap in images) {
					
					var flag:Boolean = false;
					
					if (tilesetImageName == image.name) {
						flag = true;
						bmp = image;
						break;
					}
				}
				
				if (!flag || bmp == null) {
					throw new Error("ObjectMaker didn't find an image name corresponding to the tileset imagesource name: " + tileSet.imageSource + ", add its name to your bitmap.");
				}
				
				useBmpSmoothing ||= bmp.smoothing;
				
				tileSet.image = bmp.bitmapData;
				
				for (var layerRow:uint = 0; layerRow < rows; ++layerRow) {
					
					columns = mapTiles[layerRow].length;
					
					for (var layerColumn:uint = 0; layerColumn < columns; ++layerColumn) {
						
						var tileGID:uint = mapTiles[layerRow][layerColumn];
						
						// Read out the flags
						var flipped_horizontally:Boolean = (tileGID & FLIPPED_HORIZONTALLY_FLAG) != 0;
						var flipped_vertically:Boolean = (tileGID & FLIPPED_VERTICALLY_FLAG) != 0;
						var flipped_diagonally:Boolean = (tileGID & FLIPPED_DIAGONALLY_FLAG) != 0;
						
						// Clear the flags
						tileGID &= FLIPPED_FLAGS_MASK;
						
						if (tileGID != 0) {
							
							var tilemapRow:int = (tileGID - 1) / tileSet.numCols;
							var tilemapCol:int = (tileGID - 1) % tileSet.numCols;
							
							tileRect.x = tilemapCol * map.tileWidth;
							tileRect.y = tilemapRow * map.tileHeight;
							
							tileDestInLayer.x = layerColumn * map.tileWidth;
							tileDestInLayer.y = layerRow * map.tileHeight;

							// Handle flipped tiles
							if (flipped_diagonally || flipped_horizontally || flipped_vertically) {
								
								// We will flip the tilemap image using the center of the current tile
								var tileCenterX:Number = tileRect.x + tileRect.width * 0.5;
								var tileCenterY:Number = tileRect.y + tileRect.height * 0.5;
								
								flipMatrix.identity();
								flipMatrix.translate(-tileCenterX, -tileCenterY);
								
								if (flipped_diagonally) {
									if (flipped_horizontally) {
										flipMatrix.rotate(_90degInRad);
										if (flipped_vertically) {
											flipMatrix.scale(1, -1);
										}
									} else {
										flipMatrix.rotate(-_90degInRad);
										if (!flipped_vertically) {
											flipMatrix.scale(1, -1);
										}
									}
								} else {
									if (flipped_horizontally) {
										flipMatrix.scale(-1, 1);
									}
									
									if (flipped_vertically) {
										flipMatrix.scale(1, -1);
									}
								}
								
								flipMatrix.translate(tileCenterX, tileCenterY);
								flipMatrix.translate(-tileRect.x, -tileRect.y);
								
								// clear the buffer and draw
								flipBmp.fillRect(flipBmpRect, 0);
								flipBmp.draw(bmp.bitmapData, flipMatrix, null, null, flipBmpRect);
								
								layerBmp.copyPixels(flipBmp, flipBmpRect, tileDestInLayer);
							} else {
								layerBmp.copyPixels(bmp.bitmapData, tileRect, tileDestInLayer);
							}
						}
					}
				}
			}
			
			var img:Image = new Image(Texture.fromBitmap(new Bitmap(layerBmp)));
			img.smoothing = TextureSmoothing.NONE;
			
			params = {};
			params.view = img;
			
			flipBmp.dispose();
			
			for (var param:String in layer.properties) {
				params[param] = layer.properties[param];
			}
			
			objects.push(new CitrusSprite(layer.name, params));
		}
		
		static private function addTiledObjectgroup(group:TmxObjectGroup, objects:Array):void {
			var objectClass:Class;
			var object:CitrusObject;
			var params:Object;
			
			for each (var objectTmx:TmxObject in group.objects) {
				
				objectClass = getDefinitionByName(objectTmx.type) as Class;
				
				params = {};
				
				for (var param:String in objectTmx.custom) {
					params[param] = objectTmx.custom[param];
				}
				
				params.x = objectTmx.x + objectTmx.width * 0.5;
				params.y = objectTmx.y + objectTmx.height * 0.5;
				params.width = objectTmx.width;
				params.height = objectTmx.height;
				params.rotation = objectTmx.rotation;
				
				// Polygon/Polyline support
				if (objectTmx.points != null) {
					params.points = objectTmx.points;
				}
				
				object = new objectClass(objectTmx.name, params);
				objects.push(object);
			}
		}
	}
}
