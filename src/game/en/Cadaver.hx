package en;

class Cadaver extends Entity {
	var bounces = 1;
	public function new(e:Entity) {
		super(0,0);
		setPosCase(e.cx,e.cy);
		xr = e.xr;
		yr = e.yr;
		dir = -e.dir;
		vBase.dx = dir*R.around(0.6);
		vBase.dy = -rnd(0.1,0.2);

		var g = new h2d.Graphics(spr);
		g.beginFill(0xdd6600);
		g.drawRect(-innerRadius, -hei, innerRadius*2, hei);
	}

	override function dispose() {
		super.dispose();
	}

	override function onLand(cHei:Float) {
		super.onLand(cHei);
		if( bounces-->0 ) {
			cd.setS("landedOnce",Const.INFINITE);
			vBase.dy = -rnd(0.1,0.2);
		}
	}

	override function frameUpdate() {
		vBase.frict = onGround ? 0.80 : 0.96;

		super.frameUpdate();

		// Wall impact
		if( level.hasCollision(cx-1,cy) && xr<=0.6 && vBase.dx<0 || level.hasCollision(cx+1,cy) && xr>=0.4 && vBase.dx>0 ) {
			vBase.dx*=-0.6;
			spr.rotation *= 0.5;
			if( options.camShakesXY )
				game.camera.bump(dir*2,0);
		}

		if( onGround || cd.has("landedOnce") ) {
			sprScaleX += (1.5-sprScaleX)*0.3;
			sprScaleY += (0.2-sprScaleY)*0.3;
			spr.rotation = 0;
		}
		else {
			sprScaleX += (0.6-sprScaleX)*0.3;
			sprScaleY += (1.3-sprScaleY)*0.3;
			spr.rotation += (dir*0.9 - spr.rotation)*0.6;
		}
	}
}