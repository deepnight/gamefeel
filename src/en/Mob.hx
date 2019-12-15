package en;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];
	var life = 5;

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

	override function isAlive():Bool {
		return super.isAlive() && life>0;
	}

	public function hit(dmg:Int) {
		life-=dmg;
		if( life<=0 ) {
			life = 0;
			onDie();
		}
	}

	function onDie() {
		destroy();
	}
}