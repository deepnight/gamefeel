package ui.win;

class OptionsMenu extends ui.win.SimpleMenu {
	public function new() {
		super();

		horizontalAlign = Fill;
		verticalAlign = End;
		var barFlow = new h2d.Flow(content);

		addButton("Disable all", false, ()->setAllOptions(false));
		addButton("Enable all", false, ()->setAllOptions(true));
		addSpacer();

		for(k in Type.getInstanceFields(Options))
			if( Type.typeof(Reflect.field(options, k)) == TBool ) {
				// Separator
				var meta = haxe.rtti.Meta.getFields(Options);
				for(m in Reflect.fields(meta)) {
					if( m==k && Reflect.hasField( Reflect.field(meta,m), "separator" ) ) {
						addSpacer();
						break;
					}
				}
				// Button
				addCheckBox(k, ()->Reflect.field(options,k), (v)->{
					Reflect.setField(options,k,v);
					applyChanges();
				});
			}

		onClose = function() {
			applyChanges();
		};
	}

	override function close() {
		super.close();
		trace("closed");
	}

	function applyChanges() {
		App.ME.startGame();
	}

	function setAllOptions(v:Bool) {
		for(k in Type.getInstanceFields(Options))
			Reflect.setField(options, k, v);

		applyChanges();
	}
}