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
		t.text = "This prototype is not exactly an actual game. It was developed to "+
			"serve as a demonstration for a \"Game feel\" talk.\n\n"+
			"It shows the impact of small details on the overall quality of a game.\n\n"+
			"You will need a GAMEPAD to test it. You can enable or disable game "+
			"features in this demo by pressing the START button.\n\n"+
			"Press any key to continue.";

		dn.Process.resizeAll();
	}

	override function update() {
		super.update();

		if( ca.startPressed() || ca.aPressed() || ca.xPressed() )
			close();
	}
}