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
	var camFocuses : Map<String,CPoint> = new Map();

	public var hero : en.Hero;
	var bg : h2d.Bitmap;
	var slowMoIndicator : h2d.Graphics;

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_BG);

		bg = new h2d.Bitmap(h2d.Tile.fromColor(Const.BG_COLOR));
		root.add(bg,Const.DP_BG);

		slowMoIndicator = new h2d.Graphics();
		root.add(slowMoIndicator,Const.DP_FX_FRONT);
		slowMoIndicator.visible = false;

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_BG);

		camera = new Camera();
		camera.clampOnBounds = false;
		level = new Level();
		fx = new Fx();

		var oe = level.getEntities("hero")[0];
		hero = new en.Hero(oe.cx, oe.cy);
		for(oe in level.getEntities("camFocus"))
			camFocuses.set(oe.getStr("id"), new CPoint(oe.cx,oe.cy));
		setCameraFocus("main");

		for(oe in level.getEntities("mob")) {
			var e = new en.Mob(oe.cx, oe.cy);
			e.life = oe.getInt("life",1);
		}

		Process.resizeAll();
	}

	function setCameraFocus(id:String) {
		var pt = camFocuses.get(id);
		if( pt==null ) {
			if( id=="main" )
				camera.target = hero;
			else
				setCameraFocus("main");
		}
		else {
			camera.setPosition(pt.footX, pt.footY);
		}

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
		var wid = w()/Const.SCALE;
		var hei = h()/Const.SCALE;
		bg.scaleX = wid/Const.SCALE;
		bg.scaleY = hei/Const.SCALE;

		slowMoIndicator.clear();
		var pad = 20;
		slowMoIndicator.beginFill(0x0,1);
		slowMoIndicator.drawRect(0,0,wid,pad);
		slowMoIndicator.drawRect(0,hei-pad,wid,pad);
	}

	override function update() {
		super.update();

		// Sounds
		#if debug
		options.sounds = false;
		#end
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

			// Switch cam focus
			if( ca.dpadLeftPressed() ) {
				if( camera.target==null ) {
					tw.createS(camera.zoom, 2, 0.2);
					camera.target = hero;
					camera.recenter();
				}
				else {
					tw.terminateWithoutCallbacks(camera.zoom);
					camera.zoom = 1;
					setCameraFocus("main");
				}
			}

			// Slowmo
			if( ca.dpadDownPressed() ) {
				Boot.ME.speed = Boot.ME.speed==1 ? 0.2 : 1;
				slowMoIndicator.visible = Boot.ME.isSlowMo();
			}

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

