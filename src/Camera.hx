class Camera extends dn.Process {
	public var target : Null<Entity>;
	public var x : Float;
	public var y : Float;
	public var dx : Float;
	public var dy : Float;
	public var screenWid(get,never) : Int;
	public var screenHei(get,never) : Int;
	var bumpOffX = 0.;
	var bumpOffY = 0.;
	public var zoom = 1.;

	public var clampOnBounds = true;

	var shakePowerX = 0.;
	var shakePowerY = 0.;
	var shakePowerZ = 0.;

	public function new() {
		super(Game.ME);
		x = y = 0;
		dx = dy = 0;
	}

	function get_screenWid() {
		return M.ceil( Game.ME.w() / Const.SCALE );
	}

	function get_screenHei() {
		return M.ceil( Game.ME.h() / Const.SCALE );
	}

	public function setPosition(tx,ty) {
		x = tx;
		y = ty;
		target = null;
	}

	public function recenter() {
		if( target!=null ) {
			x = target.centerX;
			y = target.centerY;
		}
	}

	public inline function scrollerToGlobalX(v:Float) return v*Const.SCALE + Game.ME.scroller.x;
	public inline function scrollerToGlobalY(v:Float) return v*Const.SCALE + Game.ME.scroller.y;

	public function shakeBoth(pow:Float, t:Float) {
		cd.setS("shakingX", t, false);
		cd.setS("shakingY", t, false);
		shakePowerX = shakePowerY = pow;
	}

	public function shakeX(pow:Float, t:Float) {
		cd.setS("shakingX", t, false);
		shakePowerX = pow;
	}

	public function shakeY(pow:Float, t:Float) {
		cd.setS("shakingY", t, false);
		shakePowerY = pow;
	}

	public function shakeZoom(pow:Float, t:Float) {
		cd.setS("shakingZ", t, false);
		shakePowerZ = pow;
	}

	public inline function bumpAng(a, dist) {
		bumpOffX+=Math.cos(a)*dist;
		bumpOffY+=Math.sin(a)*dist;
	}

	public inline function bump(x,y) {
		bumpOffX+=x;
		bumpOffY+=y;
	}


	override function postUpdate() {
		super.postUpdate();

		if( !ui.Console.ME.hasFlag("scroll") ) {
			var level = Game.ME.level;
			var scroller = Game.ME.scroller;

			// Apply zoom
			scroller.setScale(zoom);
			scroller.scale( 1 + Math.sin(0.3+ftime*1.33) * 0.02 * shakePowerZ * cd.getRatio("shakingZ") );

			// Update scroller
			if( screenWid<level.wid*Const.GRID*scroller.scaleX || !clampOnBounds )
				scroller.x = -x*scroller.scaleX + screenWid*0.5;
			else
				scroller.x = screenWid*0.5 - level.wid*0.5*Const.GRID*scroller.scaleX;

			if( screenHei<level.hei*Const.GRID*scroller.scaleY || !clampOnBounds )
				scroller.y = -y*scroller.scaleY + screenHei*0.5;
			else
				scroller.y = screenHei*0.5 - level.hei*0.5*Const.GRID*scroller.scaleY;

			// Clamp
			if( clampOnBounds ) {
				if( screenWid<level.wid*Const.GRID*scroller.scaleX )
					scroller.x = M.fclamp(scroller.x, screenWid-level.wid*Const.GRID*scroller.scaleX, 0);
				if( screenHei<level.hei*Const.GRID*scroller.scaleY )
					scroller.y = M.fclamp(scroller.y, screenHei-level.hei*Const.GRID*scroller.scaleY, 0);
			}

			// Shakes
			if( cd.has("shakingX") )
				scroller.x += Math.cos(ftime*1.10)*1*Const.SCALE*shakePowerX*scroller.scaleX * cd.getRatio("shakingX");

			if( cd.has("shakingY") )
				scroller.y += Math.sin(0.3+ftime*1.33)*1*Const.SCALE*shakePowerY*scroller.scaleY * cd.getRatio("shakingY");

			// Bumps friction
			bumpOffX *= Math.pow(0.75, tmod);
			bumpOffY *= Math.pow(0.75, tmod);

			// Rounding
			scroller.x = Std.int(scroller.x + bumpOffX*scroller.scaleX);
			scroller.y = Std.int(scroller.y + bumpOffY*scroller.scaleY);
		}
	}

	override function update() {
		super.update();

		// Follow target entity
		if( target!=null ) {
			var s = 0.009;
			var deadZone = 5;
			var tx = target.footX + target.dir*Const.GRID*2/zoom;
			var ty = target.footY - Const.GRID*3/zoom;

			var d = M.dist(x,y, tx, ty);
			if( d>=deadZone ) {
				var a = Math.atan2( ty-y, tx-x );
				dx += Math.cos(a) * (d-deadZone) * s * tmod * zoom;
				dy += Math.sin(a) * (d-deadZone) * s * tmod * zoom;
			}
		}

		var frict = 0.86;
		x += dx*tmod;
		dx *= Math.pow(frict,tmod);

		y += dy*tmod;
		dy *= Math.pow(frict,tmod);
	}
}