package en;

class Cadaver extends Entity {
	var bounces = 1;
	public function new(e:Entity) {
		super(0,0);
		setPosCase(e.cx,e.cy);
		xr = e.xr;
		yr = e.yr;
		dir = -e.dir;
		dx = dir*rnd(0.4,0.5);
		dy = -rnd(0.1,0.2);

		var g = new h2d.Graphics(spr);
		g.beginFill(0xdd6600);
		g.drawRect(-radius, -hei, radius*2, hei);
	}

	override function dispose() {
		super.dispose();
	}

	override function onLand(cHei:Float) {
		super.onLand(cHei);
		if( bounces-->0 ) {
			cd.setS("landedOnce",Const.INFINITE);
			dy = -rnd(0.1,0.2);
		}
	}

	override function update() {
		frict = onGround ? 0.8 : 0.96;

		super.update();

		if( level.hasCollision(cx-1,cy) && xr<=0.6 && dx<0 || level.hasCollision(cx+1,cy) && xr>=0.4 && dx>0 ) {
			dx*=-0.6;
			if( options.camShakesXY )
				game.camera.bumpXY(dir*2,0);
		}

		if( onGround || cd.has("landedOnce") ) {
			skewX += (1.5-skewX)*0.3;
			skewY += (0.2-skewY)*0.3;
			spr.rotation = 0;
		}
		else {
			skewX += (0.6-skewX)*0.3;
			skewY += (1.3-skewY)*0.3;
			spr.rotation += (dir*0.9 - spr.rotation)*0.6;
		}
	}
}