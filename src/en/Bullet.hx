package en;

class Bullet extends Entity {
	public static var ALL : Array<Bullet> = [];
	public var speed = 1.0;
	public var ang : Float;

	public function new(e:Entity, offY=0.) {
		super(0,0);
		setPosPixel(e.centerX, e.centerY+offY);
		ALL.push(this);
		Game.ME.scroller.add(spr, Const.DP_BG);

		hasCollisions = false;
		ang = e.dirToAng();
		frict = 1;
		gravity = 0;
		radius = 2;
		hei = 0;

		var g = new h2d.Graphics(spr);
		spr.smooth = true;
		g.beginFill(0xff0000,0.33);
		g.drawRect(-16, -1, 13, 1);
		if( options.randomizeBullets ) {
			g.beginFill( Color.interpolateInt(0xffff00, 0xff9900, rnd(0,1)) );
			g.drawRect(-3, -1, irnd(6,8), 2);
		}
		else {
			g.beginFill(0xffcc00);
			g.drawRect(-3, -0.5, 6, 2);
		}
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	function onBulletHitWall(hitX:Float,hitY:Float) {
		if( options.bulletImpactFx )
			fx.hitWall( hitX, hitY, M.radDistance(ang,0)<=M.PIHALF ? -1 : 1 );
		destroy();
	}

	override function postUpdate() {
		super.postUpdate();
		spr.scaleX = M.fabs(spr.scaleX); // ignore dir
		spr.rotation = ang;
	}

	override function update() {
		dx = Math.cos(ang)*0.55*speed;
		dy = Math.sin(ang)*0.55*speed;

		super.update();

		dir = M.radDistance(ang,0)<=M.PIHALF ? 1 : -1;

		// Mobs
		for(e in Mob.ALL) {
			if( e.isAlive() && footX>=e.footX-e.radius && footX<=e.footX+e.radius && footY>=e.footY-e.hei && footY<=e.footY ) {
				e.hit(1, dir);
				if( options.bulletImpactFx ) {
					fx.hitEntity( e.centerX-dir*4, footY, -dir );
				}
				destroy();
			}
		}

		// Walls
		if( !level.isValid(cx,cy) || level.hasCollision(cx,cy) )
			onBulletHitWall(
				(cx+0.5)*Const.GRID - Math.cos(ang)*Const.GRID*0.5,
				(cy+0.5)*Const.GRID - Math.sin(ang)*Const.GRID*0.5
			);
	}
}