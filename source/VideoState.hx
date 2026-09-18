package;

import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSubState;

#if !web
import extension.webview.WebView;
#end

#if web
import js.Browser;
import js.html.Event;
import js.html.VideoElement;
#end

using StringTools;

class VideoState extends MusicBeatState
{
	public static var androidPath:String = 'file:///android_asset/';

	public var nextState:FlxState;

	var text:FlxText;

	#if web
	var video:VideoElement;
	var videoSource:String;
	#end

	public function new(source:String, toTrans:FlxState)
	{
		super();

		text = new FlxText(0, 0, 0, "toque para continuar", 48);
		text.screenCenter();
		text.alpha = 0;
		add(text);

		nextState = toTrans;

		#if web
		videoSource = source + '.webm';

		video = cast Browser.document.createElement("video");
		video.src = videoSource;
		video.autoplay = true;
		video.controls = false;
		video.loop = false;
		video.muted = false;
		video.setAttribute("playsinline", "");
		video.style.position = "fixed";
		video.style.left = "0";
		video.style.top = "0";
		video.style.width = "100%";
		video.style.height = "100%";
		video.style.objectFit = "contain";
		video.style.backgroundColor = "#000000";
		video.style.zIndex = "99999";
		video.style.opacity = "0";
		video.style.transition = "opacity 180ms ease";

		Browser.document.body.appendChild(video);

		video.onended = function(_:Event)
		{
			onClose();
		};

		video.onerror = function(_:Event)
		{
			onClose();
		};

		video.play();

		Browser.window.setTimeout(function(_)
		{
			if (video != null)
				video.style.opacity = "1";
		}, 0);
		#else
		WebView.onClose = onClose;
		WebView.onURLChanging = onURLChanging;

		WebView.open(androidPath + source + '.html', false, null, ['http://exitme(.*)']);
		#end
	}

	public override function update(dt:Float)
	{
		#if web
		if (video != null && video.paused && controls.ACCEPT)
			video.play();
		#end

		#if !web
		onClose(); // Keep the original behavior for the non-web builds.
		#end

		super.update(dt);
	}

	function onClose()
	{
		text.alpha = 0;
		trace('close!');
		trace(nextState);

		#if web
		if (video != null)
		{
			video.onended = null;
			video.onerror = null;
			if (video.parentNode != null)
				Browser.document.body.removeChild(video);
			video = null;
		}
		#end

		FlxG.switchState(nextState);
	}

	#if !web
	function onURLChanging(url:String)
	{
		text.alpha = 1;
		if (url == 'http://exitme(.*)')
			onClose();
		trace("WebView is about to open: " + url);
	}
	#end

	override public function destroy()
	{
		#if web
		if (video != null)
		{
			video.onended = null;
			video.onerror = null;
			if (video.parentNode != null)
				Browser.document.body.removeChild(video);
			video = null;
		}
		#end

		super.destroy();
	}
}
