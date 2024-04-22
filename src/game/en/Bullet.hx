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

		collidesWithWalls = false;
		ang = e.dirToAng();
		vBase.frict = 1;
		hei = 2;

		if( options.heroSprite ) {
			spr.set(Assets.tiles, D.tiles.bullet);
			spr.colorize(Yellow);
			spr.setCenterRatio(0.9, 0.5);
			spr.blendMode = Add;
			sprScaleX = rnd(1,2);
		}
		else {
			spr.set(Assets.tiles, D.tiles.empty);
			spr.smooth = true;
			var g = new h2d.Graphics(spr);
			if( options.baseArt ) {
				// Tail
				g.beginFill(0xff0000,0.5);
				g.drawRect(-16, -0.5, 13, 1);
			}

			if( options.randomizeBullets ) {
				g.beginFill( new Col(0xffff00).to(0xff9900, rnd(0,1)) );
				g.drawRect(-3, -1, irnd(2,3), 2);
			}
			else {
				g.beginFill(0xffcc00);
				g.drawRect(-3, -1.5, 3, 3);
			}
		}
	}

	override function getGravityMul():Float {
		return 0;
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	function onBulletHitWall(hitX:Float,hitY:Float) {
		fx.hitWall( hitX, hitY, M.radDistance(ang,0)<=M.PIHALF ? -1 : 1 ); // options check happens inside

		if( options.lighting )
			fx.lightSpot( hitX+rnd(0,5,true), hitY+rnd(0,5,true), new Col(0xff0000).to(0xffcc00,rnd(0,1)), 0.1);

		destroy();
	}

	override function postUpdate() {
		super.postUpdate();
		spr.scaleX = M.fabs(spr.scaleX); // ignore dir
		spr.rotation = ang;
		if( !cd.hasSetS("tailFx",0.03) )
			fx.bulletTail(this, Red);
	}

	override function frameUpdate() {
		vBase.dx = Math.cos(ang)*0.9*speed;
		vBase.dy = Math.sin(ang)*0.9*speed;

		super.frameUpdate();

		dir = M.radDistance(ang,0)<=M.PIHALF ? 1 : -1;

		// Mobs
		for(e in Mob.ALL) {
			if( e.isAlive() && attachX>=e.left && attachX<=e.right && attachY>=e.top && attachY<=e.bottom ) {
				e.hit(1, hero);
				if( options.bulletImpactFx )
					fx.hitEntity( e.centerX-dir*4, attachY, -dir );
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