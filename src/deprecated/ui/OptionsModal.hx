package ui;

import hxd.Key as K;

class OptionsModal extends ui.Modal {
	var options(get,never) : Options; inline function get_options() return Main.ME.options;
	var elements : Array<{ f:h2d.Flow, toggle:Void->Void, getter:Void->Bool, setter:Bool->Void }> = [];
	var cursor : h2d.Bitmap;
	var list : h2d.Flow;

	var curIdx = 0;

	public function new() {
		super();

		win.layout = Horizontal;
		win.verticalAlign = Top;
		win.padding = 16;

		list = new h2d.Flow(win);
		list.layout = Vertical;

		cursor = new h2d.Bitmap(h2d.Tile.fromColor(0x0,1,1, 0.25), list);
		list.getProperties(cursor).isAbsolute = true;

		for(k in Type.getInstanceFields(Options))
			if( Type.typeof(Reflect.field(options, k)) == TBool ) {
				// Separator
				var meta = haxe.rtti.Meta.getFields(Options);
				for(m in Reflect.fields(meta)) {
					if( m==k && Reflect.hasField( Reflect.field(meta,m), "separator" ) ) {
						list.addSpacing(8);
						break;
					}
				}
				// Button
				addOptionButton(list, k, Reflect.field(options, k), function(v) Reflect.setField(options,k,v));
			}

		win.addSpacing(16);

		var help = new h2d.Flow(win);
		help.horizontalAlign = Right;
		help.layout = Vertical;
		help.paddingLeft = 32;
		var helpLines = [
			"GAMEPAD:",
			"A - Toggle", "Y - Toggle all before", "LB - Disable all", "RB - Enable all",
			" ", "KEYBOARD:",
			"ENTER - Toggle", "PAGE UP - Toggle all before", "DEL - Disable all", "A - Enable ALL"
		];

		for(h in helpLines) {
			var t = new h2d.Text(Assets.fontSmall, help);
			t.text = h;
			t.textColor = 0x7f7f7f;
		}

		dn.Process.resizeAll();
	}

	function addOptionButton(p:h2d.Flow, label:String, curValue:Bool, cb:Bool->Void) {
		var line = new h2d.Flow(p);
		line.layout = Horizontal;
		line.horizontalSpacing = 6;
		line.verticalAlign = Middle;
		line.padding = 0;

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
		/**
			WARNING: the following code was fixed in a quite DIRTY way to support keyboard keys. Do not use this as some good practice example :)
		**/

		var current = elements[curIdx];
		cursor.y = current.f.y;
		cursor.scaleX = list.outerWidth;
		cursor.scaleY = current.f.outerHeight;

		// Move cursor
		if( ( ca.downDown() || ca.isKeyboardDown(K.DOWN) ) && !cd.has("autoFireLock") ) {
			curIdx = M.imin( curIdx+1, elements.length-1 );
			if( ca.downDown() )
				cd.setS("autoFireLock", !cd.hasSetS("autoFireInitPad",Const.INFINITE) ? 0.16 : 0.04);
			else
				cd.setS("autoFireLock", !cd.hasSetS("autoFireInitKB",Const.INFINITE) ? 0.16 : 0.04);
		}

		if( ( ca.upDown() || ca.isKeyboardDown(K.UP) ) && !cd.has("autoFireLock") ) {
			curIdx = M.imax( curIdx-1, 0 );
			if( ca.upDown() )
				cd.setS("autoFireLock", !cd.hasSetS("autoFireInitPad",Const.INFINITE) ? 0.16 : 0.04);
			else
				cd.setS("autoFireLock", !cd.hasSetS("autoFireInitKB",Const.INFINITE) ? 0.16 : 0.04);
		}

		if( !ca.downDown() && !ca.upDown() )
			cd.unset("autoFireInitPad");

		if( !ca.isKeyboardDown(K.UP) && !ca.isKeyboardDown(K.DOWN) )
			cd.unset("autoFireInitKB");

		// Enable/disable all before
		if( ca.yPressed() || ca.isKeyboardPressed(K.PGUP) ) {
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
		if( ca.lbPressed() || ca.isKeyboardPressed(K.DELETE) ) {
			for(e in elements)
				e.setter(false);
			Main.ME.startGame();
		}

		// Enable all
		if( ca.rbPressed() || ca.isKeyboardPressed(K.A) ) {
			for(e in elements)
				e.setter(true);
			Main.ME.startGame();
		}

		// Toggle current
		if( ca.xPressed() || ca.aPressed() && !ca.isKeyboardDown(K.UP) || ca.isKeyboardPressed(K.ENTER) ) {
			current.toggle();
			Main.ME.startGame();
		}

		if( ca.startPressed() && !ca.isKeyboardDown(K.ENTER) || ca.isKeyboardPressed(K.ESCAPE) )
			close();
	}
}