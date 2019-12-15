package en;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];

	public function new(x,y) {
		super(x,y);
		ALL.push(this);

		var g = new h2d.Graphics(spr);
		g.beginFill(0xff0000);
		g.drawRect(-radius, -hei, radius*2, hei);
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}
}