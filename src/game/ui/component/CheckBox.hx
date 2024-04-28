package ui.component;

class CheckBox extends ui.component.Button {
	var label : String;
	var lastDisplayedValue : Bool;
	var getter : Void->Bool;
	var setter : Bool->Void;

	var icon : h2d.Bitmap;

	public function new(label:String, getter:Void->Bool, setter:Bool->Void, ?p:h2d.Object) {
		this.getter = getter;
		this.setter = setter;
		icon = new h2d.Bitmap(Assets.tiles.getTile(D.tiles.uiCheckOff));

		super(label, p);

		verticalAlign = Middle;
		horizontalSpacing = 4;
		addChildAt(icon, 0);
	}

	override function onUse() {
		super.onUse();

		setter(!getter());
		setLabel(label);
	}

	override function setLabel(str:String, col:Col = Black) {
		label = str;
		lastDisplayedValue = getter();
		icon.tile = Assets.tiles.getTile(getter() ? D.tiles.uiCheckOn : D.tiles.uiCheckOff);
		super.setLabel( label, col );
	}

	override function sync(ctx:h2d.RenderContext) {
		super.sync(ctx);
		if( lastDisplayedValue!=getter() )
			setLabel(label);
	}
}
