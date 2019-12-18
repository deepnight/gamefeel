import dn.Process;
import hxd.Key;

class Game extends Process {
	public static var ME : Game;

	public var ca : dn.heaps.Controller.ControllerAccess;
	public var fx : Fx;
	public var camera : Camera;
	public var scroller : h2d.Layers;
	public var level : Level;
	public var options(get,never) : Options; inline function get_options() return Main.ME.options;


	public var hero : en.Hero;
	var bg : h2d.Bitmap;

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_BG);

		bg = new h2d.Bitmap(h2d.Tile.fromColor(Const.BG_COLOR), root);

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_BG);

		camera = new Camera();
		level = new Level();
		fx = new Fx();

		var oe = level.getEntities("hero")[0];
		hero = new en.Hero(oe.cx, oe.cy);
		var camLock = level.getEntities("cam")[0];
		if( camLock==null )
			camera.target = hero;
		else
			camera.setPosition(camLock.x, camLock.y);

		for(oe in level.getEntities("mob")) {
			var e = new en.Mob(oe.cx, oe.cy);
			e.life = oe.getInt("life",1);
		}

		Process.resizeAll();
	}

	public function onCdbReload() {
	}


	function gc() {
		if( Entity.GC==null || Entity.GC.length==0 )
			return;

		for(e in Entity.GC)
			e.dispose();
		Entity.GC = [];
	}

	override function onDispose() {
		super.onDispose();

		fx.destroy();
		for(e in Entity.ALL)
			e.destroy();
		gc();
	}

	override function onResize() {
		super.onResize();
		bg.scaleX = w()/Const.SCALE;
		bg.scaleY = h()/Const.SCALE;
	}

	override function update() {
		super.update();

		if( options.sounds && dn.heaps.Sfx.isMuted(0) ) {
			for(gid in 0...10)
				dn.heaps.Sfx.unmuteGroup(gid);
		}
		if( !options.sounds && !dn.heaps.Sfx.isMuted(0) ) {
			for(gid in 0...10)
				dn.heaps.Sfx.muteGroup(gid);
		}

		// Updates
		for(e in Entity.ALL) if( !e.destroyed ) e.preUpdate();
		for(e in Entity.ALL) if( !e.destroyed ) e.update();
		for(e in Entity.ALL) if( !e.destroyed ) e.postUpdate();
		gc();

		if( !ui.Console.ME.isActive() && !ui.Modal.hasAny() ) {
			#if hl
			// Exit
			if( ca.isKeyboardPressed(Key.ESCAPE) )
				if( !cd.hasSetS("exitWarn",3) )
					trace("Press ESCAPE again to exit.");
				else
					hxd.System.exit();
			#end

			if( ca.startPressed() )
				new ui.OptionsModal();

			#if hl
			if( ca.isPressed(RSTICK) )
				Boot.ME.engine.fullScreen = !Boot.ME.engine.fullScreen;
			#end

			// Restart
			if( ca.selectPressed() )
				Main.ME.startGame();
		}
	}
}

