package ui;

class OptionsModal extends ui.Modal {
	var options(get,never) : Options; inline function get_options() return Main.ME.options;
	var elements : Array<{ f:h2d.Flow, toggle:Void->Void }> = [];
	var cursor : h2d.Bitmap;

	var curIdx = 0;

	public function new() {
		super();

		cursor = new h2d.Bitmap(h2d.Tile.fromColor(0x0,1,1, 0.25), win);
		win.getProperties(cursor).isAbsolute = true;

		addOptionButton("Level textures", options.levelTextures, function(v) options.levelTextures = v);
		addOptionButton("Camera shakes", options.camShakes, function(v) options.camShakes = v);
		addOptionButton("Flashes", options.flashes, function(v) options.flashes = v);

		dn.Process.resizeAll();
	}

	function addOptionButton(label:String, curValue:Bool, cb:Bool->Void) {
		var line = new h2d.Flow(win);
		line.layout = Horizontal;
		line.horizontalSpacing = 2;
		line.verticalAlign = Middle;
		line.padding = 3;

		var icon = new h2d.Graphics(line);

		var tf = new h2d.Text(Assets.fontSmall, line);
		tf.text = label;
		tf.textColor = 0x0;

		var setter = function(v:Bool) {
			curValue = v;
			cb(v);

			icon.clear();
			icon.lineStyle(1,0x0);
			icon.drawRect(0,0,10,10);
			if( v ) {
				icon.beginFill(0x0,1);
				icon.lineStyle(0);
				icon.drawRect(2,2,6,6);
				icon.endFill();
			}
			tf.alpha = v ? 1 : 0.25;
		}
		setter(curValue);

		elements.push({ f:line, toggle:function() setter(!curValue) });
	}

	override function update() {
		super.update();

		var current = elements[curIdx];
		cursor.y = current.f.y;
		cursor.scaleX = win.outerWidth;
		cursor.scaleY = current.f.outerHeight;

		if( ca.downDown() && !cd.has("autoFireLock") ) {
			curIdx = M.imin( curIdx+1, elements.length-1 );
			cd.setS("autoFireLock", !cd.hasSetS("autoFireFirst",Const.INFINITE) ? 0.20 : 0.07);
		}

		if( ca.upDown() && !cd.has("autoFireLock") ) {
			curIdx = M.imax( curIdx-1, 0 );
			cd.setS("autoFireLock", !cd.hasSetS("autoFireFirst",Const.INFINITE) ? 0.20 : 0.07);
		}

		if( ca.xPressed() || ca.aPressed() || ca.yPressed() ) {
			current.toggle();
			Main.ME.startGame();
		}

		if( !ca.downDown() && !ca.upDown() )
			cd.unset("autoFireFirst");
	}
}