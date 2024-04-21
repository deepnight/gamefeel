import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;
	public var controller : dn.heaps.Controller;
	public var ca : dn.heaps.Controller.ControllerAccess;
	public var options : Options;

	public function new(s:h2d.Scene) {
		super();
		ME = this;

        createRoot(s);
        root.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

		// Engine settings
		hxd.Timer.wantedFPS = Const.FPS;
		engine.backgroundColor = 0xff<<24|Const.BG_COLOR;
        #if( hl && !debug )
        engine.fullScreen = true;
        #end

		// Resources
		#if debug
		hxd.Res.initLocal();
        #else
        hxd.Res.initEmbed();
        #end

		// Assets init
		Assets.init();

		// Console
		new ui.Console(Assets.fontSmall, s);

		// Game controller
		controller = new dn.heaps.Controller(s);
		ca = controller.createAccess("main");
		controller.bind(AXIS_LEFT_X_NEG, Key.LEFT, Key.Q, Key.A);
		controller.bind(AXIS_LEFT_X_POS, Key.RIGHT, Key.D);
		controller.bind(X, Key.X, Key.CTRL, Key.SHIFT, Key.SPACE);
		controller.bind(A, Key.UP);
		controller.bind(SELECT, Key.R);
		controller.bind(START, Key.ENTER);

		// Start
		options = new Options();
		hxd.snd.Manager.get(); // force sound init
		delayer.addF(startGame, 1);
		hxd.Timer.skip();
	}

	public function startGame() {
		if( Game.ME!=null ) {
			Game.ME.destroy();
			delayer.addF(function() {
				Boot.ME.speed = 1;
				new Game();
			}, 1);
		}
		else
			new Game();
	}

	override public function onResize() {
		super.onResize();

		// Auto scaling
		if( Const.AUTO_SCALE_TARGET_WID>0 )
			Const.SCALE = M.ceil( h()/Const.AUTO_SCALE_TARGET_WID );
		else if( Const.AUTO_SCALE_TARGET_HEI>0 )
			Const.SCALE = M.ceil( h()/Const.AUTO_SCALE_TARGET_HEI );
		Const.UI_SCALE = M.fmax(1,Const.SCALE-2);
		root.setScale(Const.SCALE);
	}

    override function update() {
		Assets.tiles.tmod = tmod;
        super.update();
    }
}