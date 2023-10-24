package zygame.components;

import openfl.errors.ArgumentError;
import openfl.errors.Error;
import zygame.components.data.AnimationData;
import zygame.components.data.AnimationData.FrameData;
import zygame.data.ZMovieClipData;
import openfl.media.Sound;

class ZMovieClip extends ZAnimation {
	public var numFrames(get, never):UInt;

	inline function get_numFrames() {
		return @:privateAccess _dataProvider.frames.length;
	}

	public function new() {
		super();
	}

	private var inited:Bool = false;

	override private function set_dataProvider(data:Dynamic):Dynamic {
		_dataProvider = data;
		if (!inited) {
			init(0.0 + cast(_dataProvider, AnimationData).fps.fps);
			inited = true;
		}
		return data;
	}

	// override private function get_dataProvider():Dynamic {
	// 	return this.dataProvider;
	// }

	private var _defaultFrameDuration:Float;
	private var _currentFrameID:Int;

	private function init(fps:Float) {
		_defaultFrameDuration = 1.0 / fps;
		_currentFrameID = 0;

		currentTime = 0.0;

		for (i => frame in getFrames()) {
			frame.duration = _defaultFrameDuration;
			frame.startTime = _defaultFrameDuration * i;
		}
	}

	public var totalTime(get, never):Float;

	function get_totalTime():Float {
		var lastFrame:MovieClipFrameData = getFrames()[getFrames().length - 1];
		return lastFrame.startTime + lastFrame.duration;
	}

	function getFrames():Array<MovieClipFrameData> {
		return @:privateAccess this._dataProvider.frames;
	}

	@:isVar public var currentTime(get, set):Float;

	function get_currentTime() {
		return this.currentTime;
	}

	function set_currentTime(value) {
		if (value < 0 || value > totalTime)
			throw new ArgumentError("无效的时间进度: " + value);
		var lastFrameID:Int = numFrames - 1;
		this.currentTime = value;
		_currentFrameID = 0;
		while (_currentFrameID < lastFrameID && getFrames()[_currentFrameID + 1].startTime <= value) {
			++_currentFrameID;
		}
		currentFrame = _currentFrameID;
		return this.currentTime;
	}

	public static function createMovieClip(fps:Int, bitmaps:Array<Dynamic>):ZMovieClip {
		var zmc:ZMovieClip = new ZMovieClip();
		var zmcData:ZMovieClipData = new ZMovieClipData(fps);
		zmcData.addFrames(bitmaps);
		zmc.dataProvider = zmcData;
		return zmc;
	}

	public function advanceTime(passedTime:Float):Void {

		currentTime = currentTime + 0.1;

		if(currentTime > totalTime){
			currentTime = 0;
		}

	}

	public function updateStartTimes() {}

	override public function onFrame():Void {
		// 覆盖，什么都不做";
	}
}
