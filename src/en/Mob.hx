package en;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];
	var life = 7;

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

	public function hit(dmg:Int, impactDir:Int) {
		life-=dmg;

		if( options.mobSquashAndStrech )
			skew(0.8, 1.25);

		if( options.physicalReactions )
			if( !cd.hasSetS("firstImpact",0.4) )
				bump(impactDir*rnd(0.06,0.07), -0.05);
			else
				bump(impactDir*rnd(0.01,0.02), 0);

		if( options.blinkImpact )
			blink(0xfff170);

		if( life<=0 ) {
			life = 0;
			onDie();
		}
	}

	function onDie() {
		destroy();
	}
}