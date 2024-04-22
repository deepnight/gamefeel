/**
	"App" class takes care of all the top-level stuff in the whole application. Any other Process, including Game instance, should be a child of App.
**/

class App extends dn.Process {
	public static var ME : App;

	/** 2D scene **/
	public var scene(default,null) : h2d.Scene;

	/** Used to create "ControllerAccess" instances that will grant controller usage (keyboard or gamepad) **/
	public var controller : Controller<GameAction>;

	/** Controller Access created for Main & Boot **/
	public var ca : ControllerAccess<GameAction>;

	/** If TRUE, game is paused, and a Contrast filter is applied **/
	public var screenshotMode(default,null) = false;

	public var options : Options;

	public function new(s:h2d.Scene) {
		super();
		ME = this;
		scene = s;
        createRoot(scene);
		options = new Options();

		hxd.Window.getInstance().addEventTarget(onWindowEvent);

		initEngine();
		initAssets();
		initController();

		// Create console (open with [²] key)
		new ui.Console(Assets.fontPixelMono, scene); // init debug console

		// Optional screen that shows a "Click to start/continue" message when the game client looses focus
		if( dn.heaps.GameFocusHelper.isUseful() )
			new dn.heaps.GameFocusHelper(scene, Assets.fontPixel);

		#if debug
		Console.ME.enableStats();
		#end

		startGame();
	}


	function onWindowEvent(ev:hxd.Event) {
		switch ev.kind {
			case EPush:
			case ERelease:
			case EMove:
			case EOver: onMouseEnter(ev);
			case EOut: onMouseLeave(ev);
			case EWheel:
			case EFocus: onWindowFocus(ev);
			case EFocusLost: onWindowBlur(ev);
			case EKeyDown:
			case EKeyUp:
			case EReleaseOutside:
			case ETextInput:
			case ECheck:
		}
	}

	function onMouseEnter(e:hxd.Event) {}
	function onMouseLeave(e:hxd.Event) {}
	function onWindowFocus(e:hxd.Event) {}
	function onWindowBlur(e:hxd.Event) {}


	#if hl
	public static function onCrash(err:Dynamic) {
		var title = L.untranslated("Fatal error");
		var msg = L.untranslated('I\'m really sorry but the game crashed! Error: ${Std.string(err)}');
		var flags : haxe.EnumFlags<hl.UI.DialogFlags> = new haxe.EnumFlags();
		flags.set(IsError);

		var log = [ Std.string(err) ];
		try {
			log.push("BUILD: "+Const.BUILD_INFO);
			log.push("EXCEPTION:");
			log.push( haxe.CallStack.toString( haxe.CallStack.exceptionStack() ) );

			log.push("CALL:");
			log.push( haxe.CallStack.toString( haxe.CallStack.callStack() ) );

			sys.io.File.saveContent("crash.log", log.join("\n"));
			hl.UI.dialog(title, msg, flags);
		}
		catch(_) {
			sys.io.File.saveContent("crash2.log", log.join("\n"));
			hl.UI.dialog(title, msg, flags);
		}

		hxd.System.exit();
	}
	#end


	/** Start game process **/
	public function startGame() {
		if( Game.exists() ) {
			// Kill previous game instance first
			Game.ME.destroy();
			dn.Process.updateAll(1); // ensure all garbage collection is done
			_createGameInstance();
			hxd.Timer.skip();
		}
		else {
			// Fresh start
			delayer.addF( ()->{
				_createGameInstance();
				hxd.Timer.skip();
			}, 1 );
		}
	}

	final function _createGameInstance() {
		new Game();
	}


	public function anyInputHasFocus() {
		return Console.ME.isActive() || cd.has("consoleRecentlyActive");
	}


	/**
		Set "screenshot" mode.
		If enabled, the game will be adapted to be more suitable for screenshots: more color contrast, no UI etc.
	**/
	public function setScreenshotMode(v:Bool) {
		screenshotMode = v;

		Console.ME.runCommand("cls");
		if( screenshotMode ) {
			var f = new h2d.filter.ColorMatrix();
			f.matrix.colorContrast(0.2);
			root.filter = f;
			if( Game.exists() ) {
				Game.ME.hud.root.visible = false;
				Game.ME.pause();
			}
		}
		else {
			if( Game.exists() ) {
				Game.ME.hud.root.visible = true;
				Game.ME.resume();
			}
			root.filter = null;
		}
	}

	/** Toggle current game pause state **/
	public inline function toggleGamePause() setGamePause( !isGamePaused() );

	/** Return TRUE if current game is paused **/
	public inline function isGamePaused() return Game.exists() && Game.ME.isPaused();

	/** Set current game pause state **/
	public function setGamePause(pauseState:Bool) {
		if( Game.exists() )
			if( pauseState )
				Game.ME.pause();
			else
				Game.ME.resume();
	}


	/**
		Initialize low-level engine stuff, before anything else
	**/
	function initEngine() {
		// Engine settings
		engine.backgroundColor = 0xff<<24 | 0x111133;
        #if( hl && !debug )
        engine.fullScreen = true;
        #end

		#if( hl && !debug)
		hl.UI.closeConsole();
		hl.Api.setErrorHandler( onCrash );
		#end

		// Heaps resource management
		#if( hl && debug )
			hxd.Res.initLocal();
			hxd.res.Resource.LIVE_UPDATE = true;
        #else
      		hxd.Res.initEmbed();
        #end

		// Sound manager (force manager init on startup to avoid a freeze on first sound playback)
		hxd.snd.Manager.get();
		hxd.Timer.skip(); // needed to ignore heavy Sound manager init frame

		// Framerate
		hxd.Timer.smoothFactor = 0.4;
		hxd.Timer.wantedFPS = Const.FPS;
		dn.Process.FIXED_UPDATE_FPS = Const.FIXED_UPDATE_FPS;
	}


	/**
		Init app assets
	**/
	function initAssets() {
		// Init game assets
		Assets.init();

		// Init lang data
		Lang.init("en");
	}


	/** Init game controller and default key bindings **/
	function initController() {
		controller = dn.heaps.input.Controller.createFromAbstractEnum(GameAction);
		ca = controller.createAccess();
		ca.lockCondition = ()->return destroyed || anyInputHasFocus();

		initControllerBindings();
	}

	public function initControllerBindings() {
		controller.removeBindings();

		// Gamepad bindings
		controller.bindPadLStick4(GA_MoveLeft, GA_MoveRight, GA_MoveUp, GA_MoveDown);
		controller.bindPad(GA_Jump, A);
		controller.bindPad(GA_Dash, B);
		controller.bindPad(GA_Shoot, [X,Y,RT,LT,RB,LB]);
		controller.bindPad(GA_Restart, SELECT);
		controller.bindPad(GA_Pause, START);
		controller.bindPad(GA_MoveLeft, DPAD_LEFT);
		controller.bindPad(GA_MoveRight, DPAD_RIGHT);
		controller.bindPad(GA_MoveUp, DPAD_UP);
		controller.bindPad(GA_MoveDown, DPAD_DOWN);

		controller.bindPad(GA_MenuUp, [DPAD_UP, LSTICK_UP]);
		controller.bindPad(GA_MenuDown, [DPAD_DOWN, LSTICK_DOWN]);
		controller.bindPad(GA_MenuLeft, [DPAD_LEFT, LSTICK_LEFT]);
		controller.bindPad(GA_MenuRight, [DPAD_RIGHT, LSTICK_RIGHT]);
		controller.bindPad(GA_MenuOk, [A, X]);
		controller.bindPad(GA_MenuCancel, B);

		// Keyboard bindings
		controller.bindKeyboard(GA_MoveLeft, [K.LEFT, K.Q, K.A]);
		controller.bindKeyboard(GA_MoveRight, [K.RIGHT, K.D]);
		controller.bindKeyboard(GA_MoveUp, [K.UP, K.Z, K.W]);
		controller.bindKeyboard(GA_MoveDown, [K.DOWN, K.S]);
		controller.bindKeyboard(GA_Jump, [K.SPACE,K.UP]);
		controller.bindKeyboard(GA_Dash, [K.SHIFT,K.CTRL]);
		controller.bindKeyboard(GA_Shoot, [K.F]);
		controller.bindKeyboard(GA_Restart, K.R);
		controller.bindKeyboard(GA_ScreenshotMode, K.F9);
		controller.bindKeyboard(GA_Pause, K.P);
		controller.bindKeyboard(GA_Pause, K.PAUSE_BREAK);

		controller.bindKeyboard(GA_MenuUp, [K.UP, K.Z, K.W]);
		controller.bindKeyboard(GA_MenuDown, [K.DOWN, K.S]);
		controller.bindKeyboard(GA_MenuLeft, [K.LEFT, K.Q, K.A]);
		controller.bindKeyboard(GA_MenuRight, [K.RIGHT, K.D]);
		controller.bindKeyboard(GA_MenuOk, [K.SPACE, K.ENTER, K.F]);
		controller.bindKeyboard(GA_MenuCancel, K.ESCAPE);

		// Debug controls
		#if debug
		controller.bindPad(GA_DebugTurbo, LT);
		controller.bindPad(GA_DebugSlowMo, LB);
		controller.bindPad(GA_DebugDroneZoomIn, RSTICK_UP);
		controller.bindPad(GA_DebugDroneZoomOut, RSTICK_DOWN);

		controller.bindKeyboard(GA_DebugDroneZoomIn, K.PGUP);
		controller.bindKeyboard(GA_DebugDroneZoomOut, K.PGDOWN);
		controller.bindKeyboard(GA_DebugTurbo, [K.END, K.NUMPAD_ADD]);
		controller.bindKeyboard(GA_DebugSlowMo, [K.HOME, K.NUMPAD_SUB]);
		controller.bindPadCombo(GA_ToggleDebugDrone, [LSTICK_PUSH, RSTICK_PUSH]);
		controller.bindKeyboardCombo(GA_ToggleDebugDrone, [K.CTRL,K.SHIFT, K.D]);
		controller.bindKeyboardCombo(GA_OpenConsoleFlags, [[K.QWERTY_TILDE], [K.QWERTY_QUOTE], ["²".code], [K.CTRL,K.SHIFT, K.F]]);
		#end
	}


	/** Return TRUE if an App instance exists **/
	public static inline function exists() return ME!=null && !ME.destroyed;

	/** Close & exit the app **/
	public function exit() {
		destroy();
	}

	override function onDispose() {
		super.onDispose();

		hxd.Window.getInstance().removeEventTarget( onWindowEvent );

		#if hl
		hxd.System.exit();
		#end
	}

	/** Called when Const.db values are hot-reloaded **/
	public function onDbReload() {
		if( Game.exists() )
			Game.ME.onDbReload();
	}

    override function update() {
		Assets.update(tmod);

        super.update();

		if( !Window.hasAnyModal() ) {
			if( ca.isPressed(GA_ScreenshotMode) )
				setScreenshotMode( !screenshotMode );

			if( ca.isPressed(GA_Pause) )
				toggleGamePause();

			if( ca.isPressed(GA_OpenConsoleFlags) )
				Console.ME.runCommand("/flags");
		}

		if( ui.Console.ME.isActive() )
			cd.setF("consoleRecentlyActive",2);


		// Mem track reporting
		#if debug
		if( ca.isKeyboardDown(K.SHIFT) && ca.isKeyboardPressed(K.ENTER) ) {
			Console.ME.runCommand("/cls");
			dn.debug.MemTrack.report( (v)->Console.ME.log(v,Yellow) );
		}
		#end

    }
}