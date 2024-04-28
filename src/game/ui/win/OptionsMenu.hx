package ui.win;

class OptionsMenu extends ui.win.SimpleMenu {
	var helpFlow : h2d.Flow;

	public function new() {
		super();

		horizontalAlign = Center;
		verticalAlign = End;
		var barFlow = new h2d.Flow(content);

		helpFlow = new h2d.Flow(root);
		helpFlow.backgroundTile = Col.warmGray(0.3).toTile();
		helpFlow.padding = 4;
		helpFlow.paddingTop = 2;
		helpFlow.verticalSpacing = 2;
		helpFlow.layout = Vertical;

		addButton("Disable all", false, ()->setAllOptions(false));
		addButton("Enable all", false, ()->setAllOptions(true));
		addSpacer();

		for(k in Type.getInstanceFields(Options))
			if( Type.typeof(Reflect.field(options, k)) == TBool ) {
				// Separator
				var meta = haxe.rtti.Meta.getFields(Options);
				var help = null;
				var when = null;
				for(m in Reflect.fields(meta)) {
					if( m!=k )
						continue;

					if( Reflect.hasField( Reflect.field(meta,m), "help" ) ) {
						help = Reflect.field( Reflect.field(meta,m), "help" )[0];
						if( Reflect.hasField( Reflect.field(meta,m), "when" ) )
							when = Reflect.field( Reflect.field(meta,m), "when" )[0];
					}

					if( Reflect.hasField( Reflect.field(meta,m), "separator" ) )
						addSpacer();
				}
				// Button
				var bt = addCheckBox(k, ()->Reflect.field(options,k), (v)->{
					Reflect.setField(options,k,v);
					applyChanges();
				});
				if( help!=null )
					attachHelp(bt, k, help, when);
			}
	}

	function attachHelp(bt:ui.UiComponent, name:String, desc:String, ?when:String) {
		bt.onFocusCb = function() {
			setHelp(name, desc, when);
		};
		bt.onBlurCb = function() {
			clearHelp();
		};
	}

	function clearHelp() {
		helpFlow.removeChildren();
		helpFlow.visible = false;
	}

	function setHelp(name:String, desc:String, ?when:String) {
		clearHelp();
		helpFlow.visible = true;

		var tf = new h2d.Text(Assets.fontPixel, helpFlow);
		tf.text = name.toUpperCase();
		tf.textColor = White;
		tf.alpha = 0.4;
		emitResizeAtEndOfFrame();

		helpFlow.addSpacing(4);

		var tf = new h2d.Text(Assets.fontPixel, helpFlow);
		tf.text = desc;
		tf.textColor = White;

		if( when!=null ) {
			var tf = new h2d.Text(Assets.fontPixel, helpFlow);
			tf.text = '(when: $when)';
			tf.alpha = 0.6;
			tf.textColor = White;
		}

		emitResizeAtEndOfFrame();
	}

	override function onResize() {
		super.onResize();

		helpFlow.minWidth = helpFlow.maxWidth = content.outerWidth;
		helpFlow.x = content.x;
		helpFlow.y = content.y - helpFlow.outerHeight - 4;
	}

	function applyChanges() {
		Game.ME.restartLevel();
		Game.ME.resume();
		delayer.addF(Game.ME.pause, 1);
	}

	function setAllOptions(v:Bool) {
		options.setAll(v);
		applyChanges();
	}
}