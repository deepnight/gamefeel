package ui;

class OptionsModal extends ui.Modal {
	var options(get,never) : Options; inline function get_options() return Main.ME.options;
	var elements : Array<{ f:h2d.Flow, toggle:Void->Void, getter:Void->Bool, setter:Bool->Void }> = [];
	var cursor : h2d.Bitmap;

	var curIdx = 0;

	public function new() {
		super();

		cursor = new h2d.Bitmap(h2d.Tile.fromColor(0x0,1,1, 0.25), win);
		win.getProperties(cursor).isAbsolute = true;

		for(k in Type.getInstanceFields(Options))
			if( Type.typeof(Reflect.field(options, k)) == TBool )
				addOptionButton(k, Reflect.field(options, k), function(v) Reflect.setField(options,k,v));

		dn.Process.resizeAll();
	}

	function addOptionButton(label:String, curValue:Bool, cb:Bool->Void) {
		var line = new h2d.Flow(win);
		line.layout = Horizontal;
		line.horizontalSpacing = 6;
		line.verticalAlign = Middle;
		line.padding = 3;

		var icon = new h2d.Graphics(line);

		var tf = new h2d.Text(Assets.fontSmall, line);
		tf.text = label;
		tf.textColor = 0x0;
		line.getProperties(tf).offsetY = -3;

		var setter = function(v:Bool) {
			curValue = v;
			cb(v);

			icon.clear();
			icon.lineStyle(1,0x0, v ? 1 : 0.5);
			icon.drawRect(0,0,10,10);
			if( v ) {
				icon.beginFill(0x0,1);
				icon.lineStyle(0);
				icon.drawRect(2,2,6,6);
				icon.endFill();
			}
			tf.alpha = v ? 1 : 0.5;
		}
		setter(curValue);

		elements.push({ f:line, toggle:function() setter(!curValue), setter:setter, getter:function() return curValue });
	}

	override function update() {
		super.update();

		var current = elements[curIdx];
		cursor.y = current.f.y;
		cursor.scaleX = win.outerWidth;
		cursor.scaleY = current.f.outerHeight;

		// Move cursor
		if( ca.downDown() && !cd.has("autoFireLock") ) {
			curIdx = M.imin( curIdx+1, elements.length-1 );
			cd.setS("autoFireLock", !cd.hasSetS("autoFireFirst",Const.INFINITE) ? 0.20 : 0.07);
		}

		if( ca.upDown() && !cd.has("autoFireLock") ) {
			curIdx = M.imax( curIdx-1, 0 );
			cd.setS("autoFireLock", !cd.hasSetS("autoFireFirst",Const.INFINITE) ? 0.20 : 0.07);
		}

		if( !ca.downDown() && !ca.upDown() )
			cd.unset("autoFireFirst");

		// Enable/disable all before
		if( ca.yPressed() ) {
			var curValue = current.getter();
			for(e in elements)
				e.setter(false);
			for(e in elements) {
				e.setter(!curValue);
				if( e==current )
					break;
			}
			Main.ME.startGame();
		}

		// Disable all
		if( ca.lbPressed() ) {
			for(e in elements)
				e.setter(false);
			Main.ME.startGame();
		}

		// Enable all
		if( ca.rbPressed() ) {
			for(e in elements)
				e.setter(true);
			Main.ME.startGame();
		}

		// Toggle current
		if( ca.xPressed() || ca.aPressed() ) {
			current.toggle();
			Main.ME.startGame();
		}
	}
}