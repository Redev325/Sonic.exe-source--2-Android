package;

import openfl.display.BlendMode;
import openfl.text.TextFormat;
import openfl.display.Application;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
#if web
import js.Browser;
#end

class Main extends Sprite
{
	public static var instance:Main;
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var watermarks = true; // Whether to put Kade Engine liteartly anywhere

	#if android
	public static var path = lime.system.System.applicationStorageDirectory; // path to storage folder
	#else
	public static var path:String = "";
	#end

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		#if web
		installWebErrorHandler();
		#end

		// quick checks

		Lib.current.addChild(new Main());
	}

	#if web
	private static function installWebErrorHandler():Void
	{
		untyped Browser.window.onerror = function(message, source, lineno, colno, error)
		{
			var detail = Std.string(message);
			if (source != null && Std.string(source) != "")
				detail += "\n\n" + Std.string(source) + ":" + Std.string(lineno) + ":" + Std.string(colno);
			if (error != null)
			{
				var stack = untyped error.stack;
				if (stack != null && Std.string(stack) != "")
					detail += "\n\n" + Std.string(stack);
			}
			showWebError(detail);
			return false;
		};

		untyped Browser.window.onunhandledrejection = function(event)
		{
			var reason = untyped event.reason;
			showWebError("Unhandled promise rejection:\n\n" + Std.string(reason));
		};
	}

	private static function showWebError(message:String):Void
	{
		var old = Browser.document.getElementById("neo-web-error");
		if (old != null)
			Browser.document.body.removeChild(old);

		var panel = Browser.document.createElement("div");
		panel.id = "neo-web-error";
		panel.style.position = "fixed";
		panel.style.left = "0";
		panel.style.top = "0";
		panel.style.width = "100%";
		panel.style.height = "100%";
		panel.style.zIndex = "2147483647";
		panel.style.backgroundColor = "#090909";
		panel.style.color = "#ffdddd";
		panel.style.fontFamily = "monospace";
		panel.style.fontSize = "16px";
		panel.style.padding = "24px";
		panel.style.boxSizing = "border-box";
		panel.style.overflow = "auto";
		panel.style.whiteSpace = "pre-wrap";

		var heading = Browser.document.createElement("div");
		heading.textContent = "Sonic.EXE HTML5 startup error";
		heading.style.fontSize = "24px";
		heading.style.fontWeight = "bold";
		heading.style.marginBottom = "18px";
		panel.appendChild(heading);

		var body = Browser.document.createElement("div");
		body.textContent = message;
		panel.appendChild(body);

		Browser.document.body.appendChild(panel);
	}
	#end

	public function new()
	{
		super();
		instance = this;

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if cpp
		initialState = TitleState; //No more cache, fuck you, actaully no, actually yes, actaully no, actually yes, actaully no, actually yes, actaully no, actually yes, actually no
		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
		#else
		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
		#end
		addChild(game);

		var ourSource:String = "assets/videos/DO NOT DELETE OR GAME WILL CRASH/dontDelete.webm";

		#if desktop
		var str1:String = "WEBM SHIT"; 
		var webmHandle = new WebmHandler();
		webmHandle.source(ourSource);
		webmHandle.makePlayer();
		webmHandle.webm.name = str1;
		addChild(webmHandle.webm);
		GlobalVideo.setWebm(webmHandle);
		#end


		
		//#if !mobile
		#if !web
		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
		#end

		//#end
	}

	var game:FlxGame;

	var fpsCounter:FPS;

	public static function dumpCache() // THIS MOD WASTES 1-2 FUCKING G I G A B Y T E S OF MEMORY SO OF COURSE I COPIED KADE'S CODE FOR FUCKS SAKE
		{
			@:privateAccess
			for (key in FlxG.bitmap._cache.keys())
			{
				var obj = FlxG.bitmap._cache.get(key);
				if (obj != null)
				{
					Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
				}
			}
			Assets.cache.clear("songs");
			// */
		}

	public function toggleFPS(fpsEnabled:Bool):Void {
		if (fpsCounter != null)
			fpsCounter.visible = fpsEnabled;
	}

	public function changeFPSColor(color:FlxColor)
	{
		if (fpsCounter != null)
			fpsCounter.textColor = color;
	}

	public function setFPSCap(cap:Float)
	{
		openfl.Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		return fpsCounter != null ? fpsCounter.currentFPS : 0;
	}
}
