package en;

class Bullet extends Entity {
	public static var ALL : Array<Bullet> = [];
	public var speed = 1.0;
	public var ang : Float;

	public function new(e:Entity) {
		super(0,0);
		setPosPixel(e.centerX, e.centerY);
		ALL.push(this);

		hasCollisions = false;
		ang = e.dirToAng();
		frict = 1;
		gravity = 0;
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	function onBulletHitWall(hitX:Float,hitY:Float) {
		fx.markerFree(hitX, hitY, 0.2, 0xffcc00);
		destroy();
	}

	override function update() {
		dx = Math.cos(ang)*0.3*speed;
		dy = Math.sin(ang)*0.3*speed;

		super.update();

		if( !level.isValid(cx,cy) || level.hasCollision(cx,cy) )
			onBulletHitWall(
				(cx+0.5)*Const.GRID - Math.cos(ang)*Const.GRID*0.5,
				(cy+0.5)*Const.GRID - Math.sin(ang)*Const.GRID*0.5
			);
	}
}