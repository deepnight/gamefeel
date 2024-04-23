package ui;

class Hud extends GameChildProcess {
	var uiWid(get,never) : Int; inline function get_uiWid() return Std.int( w()/Const.UI_SCALE );

	var flow : h2d.Flow;
	var invalidated = true;
	var notifications : Array<h2d.Flow> = [];
	var notifTw : dn.Tweenie;

	var debugText : h2d.Text;

	var help : h2d.Flow;

	public function new() {
		super();

		notifTw = new Tweenie(Const.FPS);

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.Nothing(); // force pixel perfect rendering

		flow = new h2d.Flow(root);
		flow.paddingTop = 4;
		flow.horizontalAlign = Middle;
		notifications = [];

		help = new h2d.Flow(flow);
		help.verticalAlign = Middle;
		help.horizontalSpacing = 16;
		createControlText(A_Options, "Toggle gamefeel elements", help);
		createControlText(A_Restart, "Restart", help);
		createControlText(A_Shoot, "Shoot", help);
		createControlText(A_Jump, "Jump", help);
		createControlText(A_Dash, "Dash", help);

		debugText = new h2d.Text(Assets.fontPixel, root);
		debugText.filter = new dn.heaps.filter.PixelOutline();
		clearDebug();
	}

	function createControlText(a:GameAction, txt:String, ?p:h2d.Object) {
		var keys = new h2d.Flow();
		keys.verticalAlign = Middle;
		keys.addChild( App.ME.controller.getFirstBindindIconFor(a, Gamepad) );
		var tf = new h2d.Text(Assets.fontPixel, keys);
		tf.text = "/";
		keys.getProperties(tf).offsetY = -2;
		switch a {
			case A_Shoot:
				keys.addChild( App.ME.controller.getMouseButtonIcon(0) );

			case A_Jump:
				keys.addChild( App.ME.controller.getMouseButtonIcon(1) );

			case _:
				keys.addChild( App.ME.controller.getFirstBindindIconFor(a, Keyboard) );
		}

		return createText(keys, txt, p);
	}

	function createText(?iconTile:h2d.Tile, ?iconFlow:h2d.Flow, txt:String, col:Col=White, ?p:h2d.Object) {
		var f = new h2d.Flow(p);
		f.horizontalSpacing = 4;
		f.verticalAlign = Middle;
		f.paddingHorizontal = 2;
		f.backgroundTile = h2d.Tile.fromColor(Black,1,1, 0.6);

		if( iconTile!=null )
			new h2d.Bitmap(iconTile,f);

		if( iconFlow!=null )
			f.addChild(iconFlow);

		var tf = new h2d.Text(Assets.fontPixel, f);
		tf.text = txt;
		tf.textColor = col;
		tf.filter = new dn.heaps.filter.PixelOutline();
		f.getProperties(tf).offsetY = -2;

		return f;
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
		flow.minWidth = uiWid;
	}

	/** Clear debug printing **/
	public inline function clearDebug() {
		debugText.text = "";
		debugText.visible = false;
	}

	/** Display a debug string **/
	public inline function debug(v:Dynamic, clear=true) {
		if( clear )
			debugText.text = Std.string(v);
		else
			debugText.text += "\n"+v;
		debugText.visible = true;
		debugText.x = Std.int( w()/Const.UI_SCALE - 4 - debugText.textWidth );
	}


	/** Pop a quick s in the corner **/
	public function notify(str:String, color:Col=0x0) {
		// Bg
		var t = Assets.tiles.getTile( D.tiles.uiWindow );
		var f = new dn.heaps.FlowBg(t, 5, root);
		f.colorizeBg(color);
		f.paddingHorizontal = 6;
		f.paddingBottom = 4;
		f.paddingTop = 0;
		f.paddingLeft = 9;
		f.y = 4;

		// Text
		var tf = new h2d.Text(Assets.fontPixel, f);
		tf.text = str;
		tf.maxWidth = 0.6 * w()/Const.UI_SCALE;
		tf.textColor = 0xffffff;
		tf.filter = new dn.heaps.filter.PixelOutline( color.toBlack(0.2) );

		// Notification lifetime
		var durationS = 2 + str.length*0.04;
		var p = createChildProcess();
		notifications.insert(0,f);
		p.tw.createS(f.x, -f.outerWidth>-2, TEaseOut, 0.1);
		p.onUpdateCb = ()->{
			if( p.stime>=durationS && !p.cd.hasSetS("done",Const.INFINITE) )
				p.tw.createS(f.x, -f.outerWidth, 0.2).end( p.destroy );
		}
		p.onDisposeCb = ()->{
			notifications.remove(f);
			f.remove();
		}

		// Move existing notifications
		var y = 4;
		for(f in notifications) {
			notifTw.terminateWithoutCallbacks(f.y);
			notifTw.createS(f.y, y, TEaseOut, 0.2);
			y+=f.outerHeight+1;
		}

	}

	public inline function invalidate() invalidated = true;

	function render() {}

	public function onLevelStart() {}

	override function preUpdate() {
		super.preUpdate();
		notifTw.update(tmod);
	}

	override function postUpdate() {
		super.postUpdate();

		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}
