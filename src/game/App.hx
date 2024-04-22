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
		controller.bindPadLStick4(A_MoveLeft, A_MoveRight, A_MoveUp, A_MoveDown);
		controller.bindPad(A_Jump, A);
		controller.bindPad(A_Dash, B);
		controller.bindPad(A_Shoot, [X,Y,RT,RB]);
		controller.bindPad(A_Restart, SELECT);
		controller.bindPad(A_Pause, LT);
		controller.bindPad(A_Options, START);
		controller.bindPad(A_MoveLeft, DPAD_LEFT);
		controller.bindPad(A_MoveRight, DPAD_RIGHT);
		controller.bindPad(A_MoveUp, DPAD_UP);
		controller.bindPad(A_MoveDown, DPAD_DOWN);

		controller.bindPad(A_MenuUp, [DPAD_UP, LSTICK_UP]);
		controller.bindPad(A_MenuDown, [DPAD_DOWN, LSTICK_DOWN]);
		controller.bindPad(A_MenuLeft, [DPAD_LEFT, LSTICK_LEFT]);
		controller.bindPad(A_MenuRight, [DPAD_RIGHT, LSTICK_RIGHT]);
		controller.bindPad(A_MenuOk, [A, X]);
		controller.bindPad(A_MenuCancel, B);

		// Keyboard bindings
		controller.bindKeyboard(A_MoveLeft, [K.LEFT, K.Q, K.A]);
		controller.bindKeyboard(A_MoveRight, [K.RIGHT, K.D]);
		controller.bindKeyboard(A_MoveUp, [K.UP, K.Z, K.W]);
		controller.bindKeyboard(A_MoveDown, [K.DOWN, K.S]);
		controller.bindKeyboard(A_Jump, [K.SPACE,K.UP]);
		controller.bindKeyboard(A_Dash, [K.SHIFT,K.CTRL]);
		controller.bindKeyboard(A_Shoot, [K.F]);
		controller.bindKeyboard(A_Restart, K.R);
		controller.bindKeyboard(A_ScreenshotMode, K.F9);
		controller.bindKeyboard(A_Pause, [K.P, K.PAUSE_BREAK]);
		controller.bindKeyboard(A_Options, [K.O, K.ENTER, K.ESCAPE]);

		controller.bindKeyboard(A_MenuUp, [K.UP, K.Z, K.W]);
		controller.bindKeyboard(A_MenuDown, [K.DOWN, K.S]);
		controller.bindKeyboard(A_MenuLeft, [K.LEFT, K.Q, K.A]);
		controller.bindKeyboard(A_MenuRight, [K.RIGHT, K.D]);
		controller.bindKeyboard(A_MenuOk, [K.SPACE, K.ENTER, K.F]);
		controller.bindKeyboard(A_MenuCancel, K.ESCAPE);

		// Debug controls
		controller.bindPad(A_DebugSlowMo, LB);
		controller.bindKeyboard(A_DebugSlowMo, [K.HOME, K.NUMPAD_SUB]);
		#if debug
		controller.bindPad(A_DebugDroneZoomIn, RSTICK_UP);
		controller.bindPad(A_DebugDroneZoomOut, RSTICK_DOWN);

		controller.bindKeyboard(A_DebugDroneZoomIn, K.PGUP);
		controller.bindKeyboard(A_DebugDroneZoomOut, K.PGDOWN);
		// controller.bindKeyboard(A_DebugTurbo, [K.END, K.NUMPAD_ADD]);
		controller.bindPadCombo(A_ToggleDebugDrone, [LSTICK_PUSH, RSTICK_PUSH]);
		controller.bindKeyboardCombo(A_ToggleDebugDrone, [K.CTRL,K.SHIFT, K.D]);
		controller.bindKeyboardCombo(A_OpenConsoleFlags, [[K.QWERTY_TILDE], [K.QWERTY_QUOTE], ["²".code], [K.CTRL,K.SHIFT, K.F]]);
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

		if( !cd.has("modalRecentlyActive") ) {
			if( ca.isPressed(A_ScreenshotMode) )
				setScreenshotMode( !screenshotMode );

			if( ca.isPressed(A_OpenConsoleFlags) )
				Console.ME.runCommand("/flags");

			if( ca.isPressed(A_Options) )
				new ui.win.OptionsMenu();

			if( !Window.hasAnyModal() && ca.isPressed(A_Pause) )
				Game.ME.togglePause();
		}

		if( ui.Console.ME.isActive() )
			cd.setF("consoleRecentlyActive",2);

		if( Window.hasAnyModal() )
			cd.setF("modalRecentlyActive",2);

		// Mem track reporting
		#if debug
		if( ca.isKeyboardDown(K.SHIFT) && ca.isKeyboardPressed(K.ENTER) ) {
			Console.ME.runCommand("/cls");
			dn.debug.MemTrack.report( (v)->Console.ME.log(v,Yellow) );
		}
		#end

    }
}