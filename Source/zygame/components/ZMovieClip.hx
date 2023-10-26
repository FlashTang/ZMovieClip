// =================================================================================================
//
//	Starling Framework
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================
package zygame.components;

import openfl.display.BitmapData;
import zygame.components.data.AnimationData;
import openfl.events.EventType;
import openfl.errors.Error;
import openfl.errors.IllegalOperationError;
import openfl.media.Sound;
import openfl.media.SoundTransform;
import haxe.Constraints.Function;
import openfl.errors.ArgumentError;
import openfl.Vector;

 

class ZMovieClip extends ZAnimation implements IAnimatable {
    public var starling_mc:_MovieClip;
    public function new(fps:Int,bitmaps:Array<Dynamic>) {
        super();
		var anData:AnimationData = new AnimationData(fps);
		anData.addFrames(bitmaps);
		this.dataProvider = anData;
        starling_mc = new _MovieClip(new Vector(bitmaps.length),fps,this);
        // for (fn in ["getFrameTexture","getFrameSound","setFrameSound","getFrameAction","setFrameAction","getFrameDuration","setFrameDuration"]) {
        //     Reflect.setField(this,fn,Reflect.field(starling_mc,fn));
        // }
    }

    override function play(loop:Int = 1) {
        starling_mc.loop = loop != 0;
        starling_mc.play();
    }
    public function addFrame(texture:Texture, sound:Sound = null, duration:Float = -1):Void{
        _animation.addFrame(texture.bitmapData);
        starling_mc.addFrame(texture,sound,duration);
    }
    @:deprecated public function addFrameAt(frameID:Int, texture:Texture, sound:Sound = null, duration:Float = -1):Void{
        throw new Error("addFrameAt:尚未为实现，已禁用！");
        //starling_mc.addFrameAt(frameID,texture,sound,duration);
    }
    @:deprecated public function removeFrameAt(frameID:Int):Void{
        throw new Error("removeFrameAt:尚未为实现，已禁用！");
        starling_mc.removeFrameAt(frameID);
    }
    public function getFrameTexture(frameID:Int):Dynamic{
        return dataProvider.frames[frameID];
    }
    public function setFrameTexture(frameID:Int, texture:Texture):Void{
        dataProvider.frames[frameID] = texture.bitmapData;
    }
    public function getFrameSound(frameID:Int):Sound{
        return starling_mc.getFrameSound(frameID);
    }
    public function setFrameSound(frameID:Int, sound:Sound):Void{
        starling_mc.setFrameSound(frameID,sound);
    }
    public function getFrameAction(frameID:Int):Function{
        return starling_mc.getFrameAction(frameID);
    }
    public function setFrameAction(frameID:Int, action:Function):Void{
        starling_mc.setFrameAction(frameID,action);
    }
    public function getFrameDuration(frameID:Int):Float{
        return starling_mc.getFrameDuration(frameID);
    }
    public function setFrameDuration(frameID:Int, duration:Float):Void{
        starling_mc.setFrameDuration(frameID,duration);
    }
    @:deprecated public function reverseFrames():Void{
        throw new Error("reverseFrames:尚未为实现，已禁用！");
        starling_mc.reverseFrames();
    }
    public function advanceTime(time:Float):Void{
        starling_mc.advanceTime(time);
        if(currentFrame != starling_mc.currentFrame){
            stop(starling_mc.currentFrame);
        }
    }


    public function addFrameScript(id:Int,script:Function) {
        this.setFrameAction(id,script);
    }
    public static function createAnimation(fps:Int, bitmaps:Array<Dynamic>):ZMovieClip {
        return new ZMovieClip(fps,bitmaps);
	}

    
    
}

class _MovieClip extends MovieClip {
    var zmc:ZMovieClip;
    public function new(textures:Vector<Texture>, fps:Float = 12,zmc:ZMovieClip) {
        super(textures, fps);
        this.zmc = zmc;
    }
    override function advanceTime(passedTime:Float) {
        super.advanceTime(passedTime);
        if(zmc.currentFrame != currentFrame){
            zmc.stop(currentFrame);
        }
    }

}

class DisplayObject extends EventDispatcher {
	public var parent:Dynamic;
}

class Texture {
    public var bitmapData:BitmapData;
	public function new() {
      
    }
}

interface IAnimatable{
	/** Advance the time by a number of seconds. @param time in seconds. */
	function advanceTime(time:Float):Void;
}

class ZJuggler extends Juggler{
    override public function add(object:IAnimatable):Int {
        return super.add(cast(object,ZMovieClip).starling_mc);
    }
}

/** Dispatched whenever the movie has displayed its last frame. */
@:meta(Event(name = "complete", type = "starling.events.Event"))
/** A MovieClip is a simple way to display an animation depicted by a list of textures.
 *  
 *  <p>Pass the frames of the movie in a vector of textures to the constructor. The movie clip 
 *  will have the width and height of the first frame. If you group your frames with the help 
 *  of a texture atlas (which is recommended), use the <code>getTextures</code>-method of the 
 *  atlas to receive the textures in the correct (alphabetic) order.</p> 
 *  
 *  <p>You can specify the desired framerate via the constructor. You can, however, manually 
 *  give each frame a custom duration. You can also play a sound whenever a certain frame 
 *  appears, or execute a callback (a "frame action").</p>
 *  
 *  <p>The methods <code>play</code> and <code>pause</code> control playback of the movie. You
 *  will receive an event of type <code>Event.COMPLETE</code> when the movie finished
 *  playback. If the movie is looping, the event is dispatched once per loop.</p>
 *  
 *  <p>As any animated object, a movie clip has to be added to a juggler (or have its 
 *  <code>advanceTime</code> method called regularly) to run. The movie will dispatch 
 *  an event of type "Event.COMPLETE" whenever it has displayed its last frame.</p>
 *  
 *  @see starling.textures.TextureAtlas
 */
 
class MovieClip extends EventDispatcher implements IAnimatable {
	// removeFromJuggler
	private var __frames:Vector<MovieClipFrame>;
	private var __defaultFrameDuration:Float;
	private var __currentTime:Float;
	private var __currentFrameID:Int;
	private var __loop:Bool;
	private var __playing:Bool;
	private var __muted:Bool;
	private var __wasStopped:Bool;
	private var __soundTransform:SoundTransform = null;

	public var texture:Null<Texture>;

	#if commonjs
	private static function __init__() {
		untyped Object.defineProperties(MovieClip.prototype, {
			"numFrames": {get: untyped __js__("function () { return this.get_numFrames (); }")},
			"totalTime": {get: untyped __js__("function () { return this.get_totalTime (); }")},
			"currentTime": {get: untyped __js__("function () { return this.get_currentTime (); }"),
				set: untyped __js__("function (v) { return this.set_currentTime (v); }")},
			"loop": {get: untyped __js__("function () { return this.get_loop (); }"), set: untyped __js__("function (v) { return this.set_loop (v); }")},
			"muted": {get: untyped __js__("function () { return this.get_muted (); }"), set: untyped __js__("function (v) { return this.set_muted (v); }")},
			"soundTransform": {get: untyped __js__("function () { return this.get_soundTransform (); }"),
				set: untyped __js__("function (v) { return this.set_soundTransform (v); }")},
			"currentFrame": {get: untyped __js__("function () { return this.get_currentFrame (); }"),
				set: untyped __js__("function (v) { return this.set_currentFrame (v); }")},
			"fps": {get: untyped __js__("function () { return this.get_fps (); }"), set: untyped __js__("function (v) { return this.set_fps (v); }")},
			"isPlaying": {get: untyped __js__("function () { return this.get_isPlaying (); }")},
			"isComplete": {get: untyped __js__("function () { return this.get_isComplete (); }")},
		});
	}
	#end

	/** Creates a movie clip from the provided textures and with the specified default framerate.
	 * The movie will have the size of the first frame. */
	public function new(textures:Vector<Texture>, fps:Float = 12) {
		super();
		if (textures.length > 0) {
			// super(textures[0]);
			init(textures, fps);
		} else {
			throw new ArgumentError("Empty texture array");
		}
	}

	private function init(textures:Vector<Texture>, fps:Float):Void {
		if (fps <= 0)
			throw new ArgumentError("Invalid fps: " + fps);
		var numFrames:Int = textures.length;

		__defaultFrameDuration = 1.0 / fps;
		__loop = true;
		__playing = true;
		__currentTime = 0.0;
		__currentFrameID = 0;
		__wasStopped = true;
		__frames = new Vector<MovieClipFrame>();

		for (i in 0...numFrames)
			__frames[i] = new MovieClipFrame(textures[i], __defaultFrameDuration, __defaultFrameDuration * i);
	}

	// frame manipulation

	/** Adds an additional frame, optionally with a sound and a custom duration. If the 
	 * duration is omitted, the default framerate is used (as specified in the constructor). */
	public function addFrame(texture:Texture, sound:Sound = null, duration:Float = -1):Void {
		addFrameAt(numFrames, texture, sound, duration);
	}

	/** Adds a frame at a certain index, optionally with a sound and a custom duration. */
	public function addFrameAt(frameID:Int, texture:Texture, sound:Sound = null, duration:Float = -1):Void {
		if (frameID < 0 || frameID > numFrames)
			throw new ArgumentError("Invalid frame id");
		if (duration < 0)
			duration = __defaultFrameDuration;

		var frame:MovieClipFrame = new MovieClipFrame(texture, duration);
		frame.sound = sound;
		__frames.insertAt(frameID, frame);

		if (frameID == numFrames) {
			var prevStartTime:Float = frameID > 0 ? __frames[frameID - 1].startTime : 0.0;
			var prevDuration:Float = frameID > 0 ? __frames[frameID - 1].duration : 0.0;
			frame.startTime = prevStartTime + prevDuration;
		} else
			updateStartTimes();
	}

	/** Removes the frame at a certain ID. The successors will move down. */
	public function removeFrameAt(frameID:Int):Void {
		if (frameID < 0 || frameID >= numFrames)
			throw new ArgumentError("Invalid frame id");
		if (numFrames == 1)
			throw new IllegalOperationError("Movie clip must not be empty");

		__frames.removeAt(frameID);

		if (frameID != numFrames)
			updateStartTimes();
	}

	/** Returns the texture of a certain frame. */
	public function getFrameTexture(frameID:Int):Texture {
		if (frameID < 0 || frameID >= numFrames)
			throw new ArgumentError("Invalid frame id");
		return __frames[frameID].texture;
	}

	/** Sets the texture of a certain frame. */
	public function setFrameTexture(frameID:Int, texture:Texture):Void {
		if (frameID < 0 || frameID >= numFrames)
			throw new ArgumentError("Invalid frame id");
		__frames[frameID].texture = texture;
	}

	/** Returns the sound of a certain frame. */
	public function getFrameSound(frameID:Int):Sound {
		if (frameID < 0 || frameID >= numFrames)
			throw new ArgumentError("Invalid frame id");
		return __frames[frameID].sound;
	}

	/** Sets the sound of a certain frame. The sound will be played whenever the frame 
	 * is displayed. */
	public function setFrameSound(frameID:Int, sound:Sound):Void {
		if (frameID < 0 || frameID >= numFrames)
			throw new ArgumentError("Invalid frame id");
		__frames[frameID].sound = sound;
	}

	/** Returns the method that is executed at a certain frame. */
	public function getFrameAction(frameID:Int):Function {
		if (frameID < 0 || frameID >= numFrames)
			throw new ArgumentError("Invalid frame id");
		return __frames[frameID].action;
	}

	/** Sets an action that will be executed whenever a certain frame is reached.
	 *
	 * @param frameID   The frame at which the action will be executed.
	 * @param action    A callback with two optional parameters:
	 *                  <code>function(movie:MovieClip, frameID:int):void;</code>
	 */
	public function setFrameAction(frameID:Int, action:Function):Void {
		if (frameID < 0 || frameID >= numFrames)
			throw new ArgumentError("Invalid frame id");
		__frames[frameID].action = action;
	}

	/** Returns the duration of a certain frame (in seconds). */
	public function getFrameDuration(frameID:Int):Float {
		if (frameID < 0 || frameID >= numFrames)
			throw new ArgumentError("Invalid frame id");
		return __frames[frameID].duration;
	}

	/** Sets the duration of a certain frame (in seconds). */
	public function setFrameDuration(frameID:Int, duration:Float):Void {
		if (frameID < 0 || frameID >= numFrames)
			throw new ArgumentError("Invalid frame id");
		__frames[frameID].duration = duration;
		updateStartTimes();
	}

	/** Reverses the order of all frames, making the clip run from end to start.
	 * Makes sure that the currently visible frame stays the same. */
	public function reverseFrames():Void {
		__frames.reverse();
		__currentTime = totalTime - __currentTime;
		__currentFrameID = numFrames - __currentFrameID - 1;
		updateStartTimes();
	}

	// playback methods

	/** Starts playback. Beware that the clip has to be added to a juggler, too! */
	public function play():Void {
		__playing = true;
	}

	/** Pauses playback. */
	public function pause():Void {
		__playing = false;
	}

	/** Stops playback, resetting "currentFrame" to zero. */
	public function stop():Void {
		__playing = false;
		__wasStopped = true;
		currentFrame = 0;
	}

	// helpers

	private function updateStartTimes():Void {
		var numFrames:Int = this.numFrames;
		var prevFrame:MovieClipFrame = __frames[0];
		prevFrame.startTime = 0;

		for (i in 1...numFrames) {
			__frames[i].startTime = prevFrame.startTime + prevFrame.duration;
			prevFrame = __frames[i];
		}
	}

	// IAnimatable

	/** @inheritDoc */
	public function advanceTime(passedTime:Float):Void {
		if (!__playing)
			return;

		// The tricky part in this method is that whenever a callback is executed
		// (a frame action or a 'COMPLETE' event handler), that callback might modify the clip.
		// Thus, we have to start over with the remaining time whenever that happens.

		var frame:MovieClipFrame = __frames[__currentFrameID];

		if (__wasStopped) {
			// if the clip was stopped and started again,
			// sound and action of this frame need to be repeated.

			__wasStopped = false;
			frame.playSound(__soundTransform);

			if (frame.action != null) {
				frame.executeAction(this, __currentFrameID);
				advanceTime(passedTime);
				return;
			}
		}

		if (__currentTime == totalTime) {
			if (__loop) {
				__currentTime = 0.0;
				__currentFrameID = 0;
				frame = __frames[0];
				frame.playSound(__soundTransform);
				texture = frame.texture;

				if (frame.action != null) {
					frame.executeAction(this, __currentFrameID);
					advanceTime(passedTime);
					return;
				}
			} else
				return;
		}

		var finalFrameID:Int = __frames.length - 1;
		var dispatchCompleteEvent:Bool = false;
		var frameAction:Function = null;
		var previousFrameID:Int = __currentFrameID;
		var restTimeInFrame:Float = 0;
		var changedFrame:Bool;

		while (__currentTime + passedTime >= frame.endTime) {
			changedFrame = false;
			restTimeInFrame = frame.duration - __currentTime + frame.startTime;
			passedTime -= restTimeInFrame;
			__currentTime = frame.startTime + frame.duration;

			if (__currentFrameID == finalFrameID) {
				// if (hasEventListener(Event.COMPLETE))
				if (hasEventListener(openfl.events.Event.COMPLETE)) {
					dispatchCompleteEvent = true;
				} else if (__loop) {
					__currentTime = 0;
					__currentFrameID = 0;
					changedFrame = true;
				} else
					return;
			} else {
				__currentFrameID += 1;
				changedFrame = true;
			}

			frame = __frames[__currentFrameID];
			frameAction = frame.action;

			if (changedFrame)
				frame.playSound(__soundTransform);

			if (dispatchCompleteEvent) {
				texture = frame.texture;

				dispatchEventWith(Event.COMPLETE);
				advanceTime(passedTime);
				return;
			} else if (frameAction != null) {
				texture = frame.texture;
				frame.executeAction(this, __currentFrameID);
				advanceTime(passedTime);
				return;
			}
		}

		if (previousFrameID != __currentFrameID)
			texture = __frames[__currentFrameID].texture;

		__currentTime += passedTime;
	}

	// properties

	/** The total number of frames. */
	public var numFrames(get, never):Int;

	private function get_numFrames():Int {
		return __frames.length;
	}

	/** The total duration of the clip in seconds. */
	public var totalTime(get, never):Float;

	private function get_totalTime():Float {
		var lastFrame:MovieClipFrame = __frames[__frames.length - 1];
		return lastFrame.startTime + lastFrame.duration;
	}

	/** The time that has passed since the clip was started (each loop starts at zero). */
	public var currentTime(get, set):Float;

	private function get_currentTime():Float {
		return __currentTime;
	}

	private function set_currentTime(value:Float):Float {
		if (value < 0 || value > totalTime)
			throw new ArgumentError("Invalid time: " + value);

		var lastFrameID:Int = __frames.length - 1;
		__currentTime = value;
		__currentFrameID = 0;

		while (__currentFrameID < lastFrameID && __frames[__currentFrameID + 1].startTime <= value)
			++__currentFrameID;

		var frame:MovieClipFrame = __frames[__currentFrameID];
		texture = frame.texture;
		return value;
	}

	/** Indicates if the clip should loop. @default true */
	public var loop(get, set):Bool;

	private function get_loop():Bool {
		return __loop;
	}

	private function set_loop(value:Bool):Bool {
		return __loop = value;
	}

	/** If enabled, no new sounds will be started during playback. Sounds that are already
	 * playing are not affected. */
	public var muted(get, set):Bool;

	private function get_muted():Bool {
		return __muted;
	}

	private function set_muted(value:Bool):Bool {
		return __muted = value;
	}

	/** The SoundTransform object used for playback of all frame sounds. @default null */
	public var soundTransform(get, set):SoundTransform;

	private function get_soundTransform():SoundTransform {
		return __soundTransform;
	}

	private function set_soundTransform(value:SoundTransform):SoundTransform {
		return __soundTransform = value;
	}

	/** The index of the frame that is currently displayed. */
	public var currentFrame(get, set):Int;

	private function get_currentFrame():Int {
		return __currentFrameID;
	}

	private function set_currentFrame(value:Int):Int {
		if (value < 0 || value >= numFrames)
			throw new ArgumentError("Invalid frame id");
		currentTime = __frames[value].startTime;
		return value;
	}

	/** The default number of frames per second. Individual frames can have different 
	 * durations. If you change the fps, the durations of all frames will be scaled 
	 * relatively to the previous value. */
	public var fps(get, set):Float;

	private function get_fps():Float {
		return 1.0 / __defaultFrameDuration;
	}

	private function set_fps(value:Float):Float {
		if (value <= 0)
			throw new ArgumentError("Invalid fps: " + value);

		var newFrameDuration:Float = 1.0 / value;
		var acceleration:Float = newFrameDuration / __defaultFrameDuration;
		__currentTime *= acceleration;
		__defaultFrameDuration = newFrameDuration;

		for (i in 0...numFrames)
			__frames[i].duration *= acceleration;

		updateStartTimes();
		return value;
	}

	/** Indicates if the clip is still playing. Returns <code>false</code> when the end 
	 * is reached. */
	public var isPlaying(get, never):Bool;

	private function get_isPlaying():Bool {
		if (__playing)
			return __loop || __currentTime < totalTime;
		else
			return false;
	}

	/** Indicates if a (non-looping) movie has come to its end. */
	public var isComplete(get, never):Bool;

	private function get_isComplete():Bool {
		return !__loop && __currentTime >= totalTime;
	}
}

private class MovieClipFrame {
	public function new(texture:Texture, duration:Float = 0.1, startTime:Float = 0) {
		this.texture = texture;
		this.duration = duration;
		this.startTime = startTime;
	}

	public var texture:Texture;
	public var sound:Sound;
	public var duration:Float;
	public var startTime:Float;
	public var action:Function;

	public function playSound(transform:SoundTransform):Void {
		if (sound != null)
			sound.play(0, 0, transform);
	}

	public function executeAction(movie:MovieClip, frameID:Int):Void {
		if (action != null) {
			#if flash
			var numArgs:Int = untyped action.length;
			#elseif neko
			var numArgs:Int = untyped ($nargs)(action);
			#elseif cpp
			var numArgs:Int = untyped action.__ArgCount();
			#else
			var numArgs:Int = 2;
			#end

			if (numArgs == 0)
				action();
			else if (numArgs == 1)
				action(movie);
			else if (numArgs == 2)
				action(movie, frameID);
			else
				throw new Error("Frame actions support zero, one or two parameters: " + "movie:MovieClip, frameID:int");
		}
	}

	public var endTime(get, never):Float;

	private function get_endTime():Float {
		return startTime + duration;
	}
}



/** The Juggler takes objects that implement IAnimatable (like Tweens) and executes them.
 * 
 *  <p>A juggler is a simple object. It does no more than saving a list of objects implementing 
 *  "IAnimatable" and advancing their time if it is told to do so (by calling its own 
 *  "advanceTime"-method). When an animation is completed, it throws it away.</p>
 *  
 *  <p>There is a default juggler available at the Starling class:</p>
 *  
 *  <pre>
 *  var juggler:Juggler = Starling.juggler;
 *  </pre>
 *  
 *  <p>You can create juggler objects yourself, just as well. That way, you can group 
 *  your game into logical components that handle their animations independently. All you have
 *  to do is call the "advanceTime" method on your custom juggler once per frame.</p>
 *  
 *  <p>Another handy feature of the juggler is the "delayCall"-method. Use it to 
 *  execute a function at a later time. Different to conventional approaches, the method
 *  will only be called when the juggler is advanced, giving you perfect control over the 
 *  call.</p>
 *  
 *  <pre>
 *  juggler.delayCall(object.removeFromParent, 1.0);
 *  juggler.delayCall(object.addChild, 2.0, theChild);
 *  juggler.delayCall(function():Void { rotation += 0.1; }, 3.0);
 *  </pre>
 * 
 *  @see Tween
 *  @see DelayedCall 
 */
class Juggler implements IAnimatable {
	private var __objects:Vector<IAnimatable>;
	private var __objectIDs:Map<IAnimatable, UInt>;
	private var __elapsedTime:Float;
	private var __timeScale:Float;

	private static var sCurrentObjectID:UInt = 0;
	private static var sTweenInstanceFields:Array<String>;

	#if commonjs
	private static function __init__() {
		untyped Object.defineProperties(Juggler.prototype, {
			"elapsedTime": {get: untyped __js__("function () { return this.get_elapsedTime (); }")},
			"timeScale": {get: untyped __js__("function () { return this.get_timeScale (); }"),
				set: untyped __js__("function (v) { return this.set_timeScale (v); }")},
			"objects": {get: untyped __js__("function () { return this.get_objects (); }")},
		});
	}
	#end

	/** Create an empty juggler. */
	public function new() {
		__elapsedTime = 0;
		__timeScale = 1.0;
		__objects = new Vector<IAnimatable>();
		__objectIDs = new Map();
	}

	/** Adds an object to the juggler.
	 *
	 *  @return Unique numeric identifier for the animation. This identifier may be used
	 *          to remove the object via <code>removeByID()</code>.
	 */
	public function add(object:IAnimatable):UInt {
		return addWithID(object, getNextID());
	}

	public function addWithID(object:IAnimatable, objectID:UInt):UInt {
		if (object != null && !__objectIDs.exists(object)) {
			var dispatcher:EventDispatcher = #if (haxe_ver < 4.2) Std.is #else Std.isOfType #end (object, EventDispatcher) ? cast object : null;
			if (dispatcher != null)
				dispatcher.addEventListener(Event.REMOVE_FROM_JUGGLER, onRemove);

			__objects[__objects.length] = object;
			__objectIDs[object] = objectID;

			return objectID;
		} else
			return 0;
	}

	/** Determines if an object has been added to the juggler. */
	public function contains(object:IAnimatable):Bool {
		return __objectIDs.exists(object);
	}

	/** Removes an object from the juggler.
	 *
	 *  @return The (now meaningless) unique numeric identifier for the animation, or zero
	 *          if the object was not found.
	 */
	public function remove(object:IAnimatable):UInt {
		var objectID:UInt = 0;

		if (object != null && __objectIDs.exists(object)) {
			var dispatcher:EventDispatcher = #if (haxe_ver < 4.2) Std.is #else Std.isOfType #end (object, EventDispatcher) ? cast object : null;
			if (dispatcher != null)
				dispatcher.removeEventListener(Event.REMOVE_FROM_JUGGLER, onRemove);

			var index:Int = __objects.indexOf(object);
			__objects[index] = null;

			objectID = __objectIDs[object];
			__objectIDs.remove(object);
		}

		return objectID;
	}

	/** Removes an object from the juggler, identified by the unique numeric identifier you
	 *  received when adding it.
	 *
	 *  <p>It's not uncommon that an animatable object is added to a juggler repeatedly,
	 *  e.g. when using an object-pool. Thus, when using the <code>remove</code> method,
	 *  you might accidentally remove an object that has changed its context. By using
	 *  <code>removeByID</code> instead, you can be sure to avoid that, since the objectID
	 *  will always be unique.</p>
	 *
	 *  @return if successful, the passed objectID; if the object was not found, zero.
	 */
	public function removeByID(objectID:UInt):UInt {
		var object:IAnimatable;
		var i = __objects.length - 1;
		while (i >= 0) {
			object = __objects[i];

			if (object != null && __objectIDs[object] == objectID) {
				remove(object);
				return objectID;
			}

			--i;
		}

		return 0;
	}

	/** Removes all objects at once. */
	public function purge():Void {
		// the object vector is not purged right away, because if this method is called
		// from an 'advanceTime' call, this would make the loop crash. Instead, the
		// vector is filled with 'null' values. They will be cleaned up on the next call
		// to 'advanceTime'.

		var object:IAnimatable, dispatcher:EventDispatcher;
		var i:Int = __objects.length - 1;
		while (i >= 0) {
			object = __objects[i];
			if (object != null) {
				dispatcher = #if (haxe_ver < 4.2) Std.is #else Std.isOfType #end (object, EventDispatcher) ? cast object : null;
				if (dispatcher != null)
					dispatcher.removeEventListener(Event.REMOVE_FROM_JUGGLER, onRemove);
				__objects[i] = null;
				__objectIDs.remove(object);
			}
			--i;
		}
	}

	/** Advances all objects by a certain time (in seconds). */
	public function advanceTime(time:Float):Void {
		var numObjects:Int = __objects.length;
		var currentIndex:Int = 0;
		var i:Int = 0;

		__elapsedTime += time;
		time *= __timeScale;

		if (numObjects == 0 || time == 0)
			return;

		// there is a high probability that the "advanceTime" function modifies the list
		// of animatables. we must not process new objects right now (they will be processed
		// in the next frame), and we need to clean up any empty slots in the list.

		var object:IAnimatable;
		while (i < numObjects) {
			object = __objects[i];
			if (object != null) {
				// shift objects into empty slots along the way
				if (currentIndex != i) {
					__objects[currentIndex] = object;
					__objects[i] = null;
				}

				object.advanceTime(time);
				++currentIndex;
			}
			++i;
		}

		if (currentIndex != i) {
			numObjects = __objects.length; // count might have changed!

			while (i < numObjects)
				__objects[currentIndex++] = __objects[i++];

			__objects.length = currentIndex;
		}
	}

	private function onRemove(event:Event):Void {
		var objectID:UInt = remove(cast(event.target, IAnimatable));

		if (objectID != 0) {
			// var tween:Tween = #if (haxe_ver < 4.2) Std.is #else Std.isOfType #end(event.target, Tween) ? cast event.target : null;
			// if (tween != null && tween.isComplete)
			//     addWithID(tween.nextTween, objectID);
		}
	}

	private static function getNextID():UInt {
		return ++sCurrentObjectID;
	}

	/** The total life time of the juggler (in seconds). */
	public var elapsedTime(get, never):Float;

	private function get_elapsedTime():Float {
		return __elapsedTime;
	}

	/** The scale at which the time is passing. This can be used for slow motion or time laps
	 *  effects. Values below '1' will make all animations run slower, values above '1' faster.
	 *  @default 1.0 */
	public var timeScale(get, set):Float;

	private function get_timeScale():Float {
		return __timeScale;
	}

	private function set_timeScale(value:Float):Float {
		return __timeScale = value;
	}

	/** The actual vector that contains all objects that are currently being animated. */
	private var objects(get, never):Vector<IAnimatable>;

	private function get_objects():Vector<IAnimatable> {
		return __objects;
	}
}

/** Event objects are passed as parameters to event listeners when an event occurs.  
 *  This is Starling's version of the Flash Event class. 
 *
 *  <p>EventDispatchers create instances of this class and send them to registered listeners. 
 *  An event object contains information that characterizes an event, most importantly the 
 *  event type and if the event bubbles. The target of an event is the object that 
 *  dispatched it.</p>
 * 
 *  <p>For some event types, this information is sufficient; other events may need additional 
 *  information to be carried to the listener. In that case, you can subclass "Event" and add 
 *  properties with all the information you require. The "EnterFrameEvent" is an example for 
 *  this practice; it adds a property about the time that has passed since the last frame.</p>
 * 
 *  <p>Furthermore, the event class contains methods that can stop the event from being 
 *  processed by other listeners - either completely or at the next bubble stage.</p>
 * 
 *  @see EventDispatcher
 */
class Event {
	/** Event type for a display object that is added to a parent. */
	public static inline var ADDED:String = "added";

	/** Event type for a display object that is added to the stage */
	public static inline var ADDED_TO_STAGE:String = "addedToStage";

	/** Event type for a display object that is entering a new frame. */
	public static inline var ENTER_FRAME:String = "enterFrame";

	/** Event type for a display object that is removed from its parent. */
	public static inline var REMOVED:String = "removed";

	/** Event type for a display object that is removed from the stage. */
	public static inline var REMOVED_FROM_STAGE:String = "removedFromStage";

	/** Event type for a triggered button. */
	public static inline var TRIGGERED:String = "triggered";

	/** Event type for a resized Flash Player. */
	public static inline var RESIZE:String = "resize";

	/** Event type that may be used whenever something finishes. */
	public static inline var COMPLETE:String = "complete";

	/** Event type for a (re)created stage3D rendering context. */
	public static inline var CONTEXT3D_CREATE:String = "context3DCreate";

	/** Event type that is dispatched by the Starling instance directly before rendering. */
	public static inline var RENDER:String = "render";

	/** Event type for a frame that is skipped because the display list did not change.
	 *  Dispatched instead of the <code>RENDER</code> event. */
	public static inline var SKIP_FRAME:String = "skipFrame";

	/** Event type that indicates that the root DisplayObject has been created. */
	public static inline var ROOT_CREATED:String = "rootCreated";

	/** Event type for an animated object that requests to be removed from the juggler. */
	public static inline var REMOVE_FROM_JUGGLER:String = "removeFromJuggler";

	/** Event type that is dispatched by the AssetManager after a context loss. */
	public static inline var TEXTURES_RESTORED:String = "texturesRestored";

	/** Event type that is dispatched by the AssetManager when a file/url cannot be loaded. */
	public static inline var IO_ERROR:String = "ioError";

	/** Event type that is dispatched by the AssetManager when a file/url cannot be loaded. */
	public static inline var SECURITY_ERROR:String = "securityError";

	/** Event type that is dispatched by the AssetManager when an xml or json file couldn't
	 * be parsed. */
	public static inline var PARSE_ERROR:String = "parseError";

	/** Event type that is dispatched by the Starling instance when it encounters a problem
	 * from which it cannot recover, e.g. a lost device context. */
	public static inline var FATAL_ERROR:String = "fatalError";

	/** An event type to be utilized in custom events. Not used by Starling right now. */
	public static inline var CHANGE:String = "change";

	/** An event type to be utilized in custom events. Not used by Starling right now. */
	public static inline var CANCEL:String = "cancel";

	/** An event type to be utilized in custom events. Not used by Starling right now. */
	public static inline var SCROLL:String = "scroll";

	/** An event type to be utilized in custom events. Not used by Starling right now. */
	public static inline var OPEN:String = "open";

	/** An event type to be utilized in custom events. Not used by Starling right now. */
	public static inline var CLOSE:String = "close";

	/** An event type to be utilized in custom events. Not used by Starling right now. */
	public static inline var SELECT:String = "select";

	/** An event type to be utilized in custom events. Not used by Starling right now. */
	public static inline var READY:String = "ready";

	/** An event type to be utilized in custom events. Not used by Starling right now. */
	public static inline var UPDATE:String = "update";

	private static var sEventPool:Vector<Event> = new Vector<Event>();

	/** Creates an event object that can be passed to listeners. */
	public function new(type:String, bubbles:Bool = false, data:Dynamic = null) {
		this.type = type;
		this.bubbles = bubbles;
		this.data = data;
	}

	/** Prevents listeners at the next bubble stage from receiving the event. */
	public function stopPropagation():Void {
		this.stopsPropagation = true;
	}

	/** Prevents any other listeners from receiving the event. */
	public function stopImmediatePropagation():Void {
		this.stopsPropagation = this.stopsImmediatePropagation = true;
	}

	/** Returns a description of the event, containing type and bubble information. */
	public function toString():String {
		return format("[{0} type=\"{1}\" bubbles={2}]", [Type.getClassName(Type.getClass(this)).split("::").pop(), type, bubbles]);
	}

	public static function format(format:String, args:Array<Dynamic>):String {
		// TODO: add number formatting options

		for (i in 0...args.length) {
			var r:EReg = new EReg("\\{" + i + "\\}", "g");
			format = r.replace(format, Std.string(args[i]));
		}

		return format;
	}

	/** Indicates if event will bubble. */
	public var bubbles(default, null):Bool;

	/** The object that dispatched the event. */
	public var target(default, null):EventDispatcher;

	/** The object the event is currently bubbling at. */
	public var currentTarget(default, null):EventDispatcher;

	/** A string that identifies the event. */
	public var type(default, null):String;

	/** Arbitrary data that is attached to the event. */
	public var data(default, null):Dynamic;

	// properties for public use

	/** @private */
	@:allow(starling) private function setTarget(value:EventDispatcher):Void {
		target = value;
	}

	/** @private */
	@:allow(starling) private function setCurrentTarget(value:EventDispatcher):Void {
		currentTarget = value;
	}

	/** @private */
	@:allow(starling) private function setData(value:Dynamic):Void {
		data = value;
	}

	/** @private */
	@:allow(starling) private var stopsPropagation(default, null):Bool;

	/** @private */
	@:allow(starling) private var stopsImmediatePropagation(default, null):Bool;

	// event pooling

	/** @private */
	@:allow(starling) private static function fromPool(type:String, bubbles:Bool = false, data:Dynamic = null):Event {
		if (sEventPool.length != 0)
			return sEventPool.pop().reset(type, bubbles, data);
		else
			return new Event(type, bubbles, data);
	}

	/** @private */
	@:allow(starling) private static function toPool(event:Event):Void {
		event.data = event.target = event.currentTarget = null;
		sEventPool[sEventPool.length] = event; // avoiding 'push'
	}

	/** @private */
	@:allow(starling) private function reset(type:String, bubbles:Bool = false, data:Dynamic = null):Event {
		this.type = type;
		this.bubbles = bubbles;
		this.data = data;
		this.target = this.currentTarget = null;
		this.stopsPropagation = this.stopsImmediatePropagation = false;
		return this;
	}
}


/** The EventDispatcher class is the base class for all classes that dispatch events. 
 *  This is the Starling version of the Flash class with the same name. 
 *  
 *  <p>The event mechanism is a key feature of Starling's architecture. Objects can communicate 
 *  with each other through events. Compared the the Flash event system, Starling's event system
 *  was simplified. The main difference is that Starling events have no "Capture" phase.
 *  They are simply dispatched at the target and may optionally bubble up. They cannot move 
 *  in the opposite direction.</p>  
 *  
 *  <p>As in the conventional Flash classes, display objects inherit from EventDispatcher 
 *  and can thus dispatch events. Beware, though, that the Starling event classes are 
 *  <em>not compatible with Flash events:</em> Starling display objects dispatch 
 *  Starling events, which will bubble along Starling display objects - but they cannot 
 *  dispatch Flash events or bubble along Flash display objects.</p>
 *  
 *  @see Event
 *  @see starling.display.DisplayObject DisplayObject
 */
class EventDispatcher {
	private var __eventListeners:Map<String, Vector<Function>>;
	private var __eventStack:Vector<String> = new Vector<String>();

	/** Helper object. */
	private static var sBubbleChains:Array<Vector<EventDispatcher>> = new Array<Vector<EventDispatcher>>();

	/** Creates an EventDispatcher. */
	public function new() {}

	/** Registers an event listener at a certain object. */
	public function addEventListener(type:String, listener:Function):Void {
		// Original Starling makes a change here from Vector.<Function> to Array and adds the following comment:
		// "The listeners are stored inside an Array instead of a Vector as a workaround
		// to a strange String allocation taking place in the AOT compiler.
		// See: https://tracker.adobe.com/#/view/AIR-4115729"
		// Could that AOT complier bug apply to Haxe too, when using the flash target? Should we switch from Vector<Dynamic> to Array<Dynamic>?
		// For now I left things as they where

		if (listener == null)
			throw new ArgumentError("null listener added");

		if (__eventListeners == null)
			__eventListeners = new Map<String, Vector<Function>>();

		var listeners:Vector<Function> = __eventListeners[type];
		if (listeners == null) {
			__eventListeners[type] = new Vector<Function>();
			__eventListeners[type].push(listener);
		} else {
			for (i in 0...listeners.length) {
				if (Reflect.compareMethods(listeners[i], listener)) // check for duplicates
					return;
			}
			listeners[listeners.length] = listener; // avoid 'push'
		}
	}

	/** Removes an event listener from the object. */
	public function removeEventListener(type:String, listener:Function):Void {
		if (__eventListeners != null) {
			var listeners:Vector<Function> = __eventListeners[type];
			var numListeners:Int = listeners != null ? listeners.length : 0;

			if (numListeners > 0) {
				// we must not modify the original vector, but work on a copy.
				// (see comment in 'invokeEvent')

				var index:Int = listeners.indexOf(listener);

				if (index != -1) {
					if (__eventStack.indexOf(type) == -1) {
						listeners.removeAt(index);
					} else {
						var restListeners:Vector<Function> = listeners.slice(0, index);

						for (i in index + 1...numListeners)
							restListeners[i - 1] = listeners[i];

						__eventListeners[type] = restListeners;
					}
				}
			}
		}
	}

	/** Removes all event listeners with a certain type, or all of them if type is null. 
	 * Be careful when removing all event listeners: you never know who else was listening. */
	public function removeEventListeners(type:String = null):Void {
		if (type != null && __eventListeners != null)
			__eventListeners.remove(type);
		else
			__eventListeners = null;
	}

	/** Dispatches an event to all objects that have registered listeners for its type. 
	 * If an event with enabled 'bubble' property is dispatched to a display object, it will 
	 * travel up along the line of parents, until it either hits the root object or someone
	 * stops its propagation manually. */
	public function dispatchEvent(event:Event):Void {
		var bubbles:Bool = event.bubbles;

		if (!bubbles && (__eventListeners == null || !(__eventListeners.exists(event.type))))
			return; // no need to do anything

		// we save the current target and restore it later;
		// this allows users to re-dispatch events without creating a clone.

		var previousTarget:EventDispatcher = event.target;
		@:privateAccess event.setTarget(this);

		if (bubbles && #if (haxe_ver < 4.2) Std.is #else Std.isOfType #end (this, DisplayObject))
			__bubbleEvent(event);
		else
			__invokeEvent(event);

		if (previousTarget != null)
			@:privateAccess event.setTarget(previousTarget);
	}

	/** @private
	 * Invokes an event on the current object. This method does not do any bubbling, nor
	 * does it back-up and restore the previous target on the event. The 'dispatchEvent' 
	 * method uses this method internally. */
	@:allow(starling) private function __invokeEvent(event:Event):Bool {
		var listeners:Vector<Function> = __eventListeners != null ? __eventListeners[event.type] : null;
		var numListeners:Int = listeners == null ? 0 : listeners.length;

		if (numListeners != 0) {
			@:privateAccess event.setCurrentTarget(this);
			__eventStack[__eventStack.length] = event.type;

			// we can enumerate directly over the vector, because:
			// when somebody modifies the list while we're looping, "addEventListener" is not
			// problematic, and "removeEventListener" will create a new Vector, anyway.

			for (i in 0...numListeners) {
				var listener:Function = listeners[i];
				if (listener == null)
					continue;

				#if flash
				var numArgs:Int = untyped listener.length;
				#elseif neko
				var numArgs:Int = untyped ($nargs)(listener);
				#elseif cpp
				var numArgs:Int = untyped listener.__ArgCount();
				#elseif html5
				var numArgs:Int = untyped listener.length;
				#else
				var numArgs:Int = 2;
				#end

				if (numArgs == 0)
					listener();
				else if (numArgs == 1)
					listener(event);
				else
					listener(event, event.data);

				if (@:privateAccess event.stopsImmediatePropagation) {
					__eventStack.pop();
					return true;
				}
			}

			__eventStack.pop();

			return @:privateAccess event.stopsPropagation;
		} else {
			return false;
		}
	}

	/** @private */
	private function __bubbleEvent(event:Event):Void {
		// we determine the bubble chain before starting to invoke the listeners.
		// that way, changes done by the listeners won't affect the bubble chain.

		var chain:Vector<EventDispatcher>;
		var element:DisplayObject = cast(this, DisplayObject);
		var length:Int = 1;

		if (sBubbleChains.length > 0) {
			chain = sBubbleChains.pop();
			chain[0] = element;
		} else {
			chain = new Vector<EventDispatcher>();
			chain.push(element);
		}

		while ((element = @:privateAccess element.parent) != null)
			chain[length++] = element;

		for (i in 0...length) {
			if (chain[i] == null)
				continue;
			var stopPropagation:Bool = chain[i].__invokeEvent(event);
			if (stopPropagation)
				break;
		}

		chain.length = 0;
		sBubbleChains[sBubbleChains.length] = chain; // avoid 'push'
	}

	/** Dispatches an event with the given parameters to all objects that have registered 
	 * listeners for the given type. The method uses an internal pool of event objects to 
	 * avoid allocations. */
	public function dispatchEventWith(type:String, bubbles:Bool = false, data:Dynamic = null):Void {
		if (bubbles || hasEventListener(type)) {
			var event:Event = @:privateAccess Event.fromPool(type, bubbles, data);
			dispatchEvent(event);
			@:privateAccess Event.toPool(event);
		}
	}

	/** If called with one argument, figures out if there are any listeners registered for
	 * the given event type. If called with two arguments, also determines if a specific
	 * listener is registered. */
	public function hasEventListener(type:String, listener:Dynamic = null):Bool {
		var listeners:Vector<Function> = __eventListeners != null ? __eventListeners[type] : null;
		if (listeners == null)
			return false;
		else {
			if (listener != null)
				return listeners.indexOf(listener) != -1;
			else
				return listeners.length != 0;
		}
	}
}
