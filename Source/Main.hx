package;

import openfl.Vector;
import openfl.Lib;
import zygame.components.ZMovieClip;
import zygame.components.data.AnimationData;
import zygame.components.ZAnimation;
import zygame.components.ZImage;
import zygame.components.ZBuilder;
import zygame.loader.LoaderAssets;
import zygame.utils.ZAssets;
import zygame.core.Start;

class Main extends Start {
	public function new() {
		super(1920, 1080, true);
	}

	override function onInit() {
		super.onInit();
		// 代码初始化入口
		// 创建新的加载分析器

		LoaderAssets.fileparser.push(JSONTextureAtlas);
		var assets = new ZAssets();
		assets.loadFile(new JSONTextureAtlas({
			path: "assets/run_format_JSON.png",
			json: "assets/run_format_JSON.json"
		}));
		assets.start((f) -> {
			if (f == 1) {
				// 解析成功
				var img = new ZImage();
				img.dataProvider = "run_format_JSON:run0000";
				this.addChild(img);
				img.y = 300;

				// 帧动画处理
				var animate = new ZAnimation();
				var data = new AnimationData(60);
				data.addFrames(assets.getTextureAtlas("run_format_JSON").getBitmapDataFrames("run"));
				animate.dataProvider = data;
				this.addChild(animate);
				animate.play(99999);
				animate.x = 300;
				animate.y = 300;

				animate.play(9999);
			

				var frames = assets.getTextureAtlas("run_format_JSON").getBitmapDataFrames("run");
		
				zmc = new ZMovieClip(60,frames);

				var n = 0;
				zmc.addFrameScript(Std.int(zmc.dataProvider.frames.length - 1),function () {
					if(++n % 5 == 0){
						speed = -speed;
						trace("zmc.x:",zmc.x);
					}
				});
				
				addChild(zmc);
				zmc.x = 300;
				zmc.y = 450;
				juggler.add(zmc);
				zmc.play();				
		
			}
		});
		ZBuilder.bindAssets(assets);
	}
	var juggler:ZJuggler = new ZJuggler();
	var lastTime:Float = Lib.getTimer();
	var speed:Float = 10;
	var zmc:ZMovieClip;
	override function onFrame() {
		var delta:Float = Lib.getTimer() - lastTime;
		juggler.advanceTime(delta / 1000 * 2); // 90 fps
		if(zmc != null) {
			zmc.x += speed * delta / 60;
		}
		lastTime = Lib.getTimer();
		super.onFrame();
	}
}
