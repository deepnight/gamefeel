package ui;

class Intro extends ui.Modal {
	public function new() {
		super();

		win.padding = 8;

		var t = new h2d.Text(Assets.fontMedium, win);
		t.textColor = 0x0;
		t.text = "Game-feel demonstration";
		win.addSpacing(12);

		var t = new h2d.Text(Assets.fontSmall, win);
		t.textColor = 0x0;
		t.maxWidth = 250;
		t.text = "This prototype is not exactly an actual game.\n\n"+
			"It shows the impact of small details on the overall final quality and 'game feel'.\n\n"+
			"To toggle game features: press gamepad START, or keyboard ENTER.\n\n"+
			"Press any key to continue.";

		dn.Process.resizeAll();
	}

	override function update() {
		super.update();

		if( ca.startPressed() || ca.aPressed() || ca.xPressed() )
			close();
	}
}