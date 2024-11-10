package ui.win;

class SimpleMenu extends ui.Window {
	public var uiCtrl : UiGroupController;

	public function new() {
		super(true);

		content.padding = 1;
		content.horizontalSpacing = 4;
		content.verticalSpacing = 0;
		content.layout = Vertical;
		content.multiline = true;
		content.colWidth = 150;

		uiCtrl = new UiGroupController(this);
		uiCtrl.customControllerLock = ()->!isActive();
	}


	public function setColumnWidth(w:Int) {
		content.colWidth = w;
	}

	override function onResize() {
		super.onResize();
		switch verticalAlign {
			case Start,End: content.maxHeight = Std.int( 0.4 * stageHei/Const.UI_SCALE );
			case Center: content.maxHeight = Std.int( 0.8 * stageHei/Const.UI_SCALE );
			case Fill: content.maxHeight = Std.int( stageHei/Const.UI_SCALE );
		}
	}

	public function addSpacer() {
		var f = new h2d.Flow(content);
		f.minWidth = f.minHeight = 12;
	}

	public function addTitle(str:String) {
		new ui.component.Title( str, Col.coldGray(0.6), content );
	}

	public function addText(str:String) {
		new ui.component.Text( str, Black, content );
	}

	public function addButton(label:String, ?tile:h2d.Tile, autoClose=true, cb:Void->Void) {
		var bt = new ui.component.Button(label, tile, content);
		bt.minWidth = content.colWidth;
		bt.onUseCb = ()->{
			cb();
			if( autoClose )
				close();
		}
		uiCtrl.register(bt);
		return bt;
	}

	public function addCheckBox(label:String, getter:Void->Bool, setter:Bool->Void, autoClose=false) {
		var bt = new ui.component.CheckBox(label,getter,setter,content);
		bt.minWidth = content.colWidth;
		bt.onUseCb = ()->{
			if( autoClose )
				close();
		}

		uiCtrl.register(bt);
		return bt;
	}
}