package en;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];
	public var life = 1;

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
			skew(0.6, 1.35);

		if( options.physicalReactions )
			if( !cd.hasSetS("firstImpact",0.4) )
				bump(impactDir * rnd(0.20, 0.25), -0.05);
			else
				bump(impactDir*rnd(0.01,0.02), 0);

		if( options.blinkImpact )
			blink(0xfff170);

		if( options.blood ) {
			fx.bloodBackHits(centerX, centerY, impactDir, 2);
			fx.bloodFrontHits(centerX, centerY, -impactDir, 0.6);
		}

		if( life<=0 ) {
			life = 0;
			onDie();
		}
	}

	function onDie() {
		destroy();
	}
}