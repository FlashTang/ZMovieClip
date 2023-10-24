package zygame.data;

import zygame.components.data.AnimationData;

class ZMovieClipData extends AnimationData {
	// 当在不为帧指定停留时间时，将使用默认帧率，即默认停留时间为1000/fps
	public function new(curfps:Int) {
		super(curfps);
	}

	override public function addFrame(bitmapData:Dynamic, delayFrame:Int = 0, call:Void->Void = null):Void {
		var frameData:MovieClipFrameData = new MovieClipFrameData(bitmapData, delayFrame);
		frames.push(frameData);
		if (call != null)
			frameData.call = call;
		
	}
}

class MovieClipFrameData extends FrameData {
	public var startTime:Float = 0;
    public var duration:Float = 0;

	// public function new(bitmapData:Dynamic, delayFrame:Int) {
	// 	super(bitmapData, delayFrame);
	// }

    public var endTime(get,never):Float;
    function get_endTime() {
        return startTime + duration;
    }
}
