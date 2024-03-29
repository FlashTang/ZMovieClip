import zygame.utils.load.TextureLoader.TextureAtlas;
import haxe.Json;
import openfl.display.BitmapData;
import zygame.utils.AssetsUtils;
import zygame.loader.parser.ParserBase;

/**
 * JSON格式的精灵图TextureAtlas加载器
 */
class JSONTextureAtlas extends ParserBase {
	private var _step = 0;

	private var _bitmapData:BitmapData = null;

	private var _json:Dynamic;

	override function process() {
		switch _step {
			case 0:
				// 先加载位图
				var path = this.getData().path;
				AssetsUtils.loadBitmapData(path).onComplete((b) -> {
					_bitmapData = b;
					_step = 1;
					this.finalAssets(TEXTUREATLAS, null, 0.5);
					this.process();
				});
			case 1:
				// 然后加载JSON
				var path = this.getData().json;
				AssetsUtils.loadText(path).onComplete((text) -> {
					_json = Json.parse(text);
					_step = 2;
					this.process();
				});
			case 2:
				// 然后解析精灵图
				var textureAtlas:TextureAtlas = new TextureAtlas(_bitmapData, jsonToXml(_json));
				this.finalAssets(TEXTUREATLAS, textureAtlas, 1);
		}
	}

	/**
	 * 引擎中已经支持XML格式数据，那么可以将json转换成xml格式
	 * @param json 
	 * @return Xml
	 */
	private function jsonToXml(json:Dynamic):Xml {
		var xml = Xml.createDocument();
		var root = Xml.createElement("TextureAtlas");
		xml.addChild(root);
		var frames = Reflect.fields(json.frames);
		for (key in frames) {
			var value:JSONTextureAtlasFrame = Reflect.getProperty(json.frames, key);
			var tile:Xml = Xml.createElement("frame");
			tile.set("x", Std.string(value.frame.x));
			tile.set("y", Std.string(value.frame.y));
			tile.set("width", Std.string(value.frame.w));
			tile.set("height", Std.string(value.frame.h));
			tile.set("frameX", Std.string(-value.spriteSourceSize.x));
			tile.set("frameY", Std.string(-value.spriteSourceSize.y));
			tile.set("frameWidth", Std.string(value.spriteSourceSize.w));
			tile.set("frameHeight", Std.string(value.spriteSourceSize.h));
			tile.set("name", key);
			root.addChild(tile);
			// 暂时不支持rotated
		}
		return xml;
	}
}

typedef JSONTextureAtlasFrame = {
	frame:{
		x:Float, y:Float, w:Float, h:Float
	},
	rotated:Bool,
	trimmed:Bool,
	spriteSourceSize:{
		x:Float, y:Float, w:Float, h:Float
	},
	sourceSize:{
		w:Float, h:Float
	}
}
