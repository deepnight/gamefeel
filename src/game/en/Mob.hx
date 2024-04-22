package en;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		life.initMaxOnMax(5);

		var g = new h2d.Graphics(spr);
		g.beginFill(options.baseArt ? 0xffcc00 : 0xffffff);
		g.drawRect(-innerRadius, -hei, innerRadius*2, hei);
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}


	override function hit(dmg:Int, from:Null<Entity>) {
		super.hit(dmg, from);
		var impactDir = from!=null ? from.dirTo(this) : -dir;

		if( options.mobSquashAndStrech )
			setSquashX(0.6);

		if( options.physicalReactions )
			if( !cd.hasSetS("firstImpact",0.4) )
				vBump.addXY(impactDir * rnd(0.040, 0.060), -0.05);
			else
				vBump.addXY(impactDir * rnd(0.005,0.010), 0);

		if( options.blinkImpact )
			blink(0xffffff);

		if( options.lighting )
			fx.lightSpot(centerX+rnd(0,15)*-impactDir, centerY+rnd(0,8,true), 0xff0000, rnd(0.15,0.18));

		if( options.blood ) {
			fx.bloodBackHits(centerX, centerY, impactDir, 2);
			fx.bloodFrontHits(centerX, centerY, -impactDir, 0.6);
		}
	}

	override function onDie() {
		super.onDie();
		if( options.cadavers )
			new en.Cadaver(this);
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		dir = dirTo(hero);
	}
}