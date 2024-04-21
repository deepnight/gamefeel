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
			"It shows the impact and importance of small details on the global 'feeling' of a game. If you wonder why Dead Cells feels right, this demo explains just that.\n\n"+
			"To toggle features: press gamepad START, or keyboard ENTER.\n\n"+
			"Press any key to continue.";

		dn.Process.resizeAll();
	}

	override function update() {
		super.update();

		if( ca.startPressed() || ca.aPressed() || ca.xPressed() )
			close();
	}
}