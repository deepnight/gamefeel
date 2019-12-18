import h2d.Sprite;
import dn.heaps.HParticle;
import dn.Tweenie;


class Fx extends dn.Process {
	public var pool : ParticlePool;

	public var bgAddSb    : h2d.SpriteBatch;
	public var bgNormalSb    : h2d.SpriteBatch;
	public var topAddSb       : h2d.SpriteBatch;
	public var topNormalSb    : h2d.SpriteBatch;

	var game(get,never) : Game; inline function get_game() return Game.ME;

	public function new() {
		super(Game.ME);

		pool = new ParticlePool(Assets.tiles.tile, 2048, Const.FPS);

		bgAddSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(bgAddSb, Const.DP_FX_BG);
		bgAddSb.blendMode = Add;
		bgAddSb.hasRotationScale = true;

		bgNormalSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(bgNormalSb, Const.DP_FX_BG);
		bgNormalSb.hasRotationScale = true;

		topNormalSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(topNormalSb, Const.DP_FX_FRONT);
		topNormalSb.hasRotationScale = true;

		topAddSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(topAddSb, Const.DP_FX_FRONT);
		topAddSb.blendMode = Add;
		topAddSb.hasRotationScale = true;
	}

	override public function onDispose() {
		super.onDispose();

		pool.dispose();
		bgAddSb.remove();
		bgNormalSb.remove();
		topAddSb.remove();
		topNormalSb.remove();
	}

	public function clear() {
		pool.killAll();
	}

	public inline function allocTopAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topAddSb, t, x, y);
	}

	public inline function allocTopNormal(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topNormalSb, t,x,y);
	}

	public inline function allocBgAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(bgAddSb, t,x,y);
	}

	public inline function allocBgNormal(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(bgNormalSb, t,x,y);
	}

	public inline function getTile(id:String) : h2d.Tile {
		return Assets.tiles.getTileRandom(id);
	}

	public function killAll() {
		pool.killAll();
	}

	public function markerEntity(e:Entity, ?c=0xFF00FF, ?short=false) {
		#if debug
		if( e==null )
			return;

		markerCase(e.cx, e.cy, short?0.03:3, c);
		#end
	}

	public function markerCase(cx:Int, cy:Int, ?sec=3.0, ?c=0xFF00FF) {
		#if debug
		var p = allocTopAdd(getTile("fxCircle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.lifeS = sec;

		var p = allocTopAdd(getTile("pixel"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(2);
		p.lifeS = sec;
		#end
	}

	public function markerFree(x:Float, y:Float, ?sec=3.0, ?c=0xFF00FF) {
		#if debug
		var p = allocTopAdd(getTile("fxDot"), x,y);
		p.setCenterRatio(0.5,0.5);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(3);
		p.lifeS = sec;
		#end
	}

	public function markerText(cx:Int, cy:Int, txt:String, ?t=1.0) {
		#if debug
		var tf = new h2d.Text(Assets.fontSmall, topNormalSb);
		tf.text = txt;

		var p = allocTopAdd(getTile("fxCircle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.colorize(0x0080FF);
		p.alpha = 0.6;
		p.lifeS = 0.3;
		p.fadeOutSpeed = 0.4;
		p.onKill = tf.remove;

		tf.setPosition(p.x-tf.textWidth*0.5, p.y-tf.textHeight*0.5);
		#end
	}

	public function flashBangS(c:UInt, a:Float, ?t=0.1) {
		var e = new h2d.Bitmap(h2d.Tile.fromColor(c,1,1,a));
		game.root.add(e, Const.DP_FX_FRONT);
		e.scaleX = game.w();
		e.scaleY = game.h();
		e.blendMode = Add;
		game.tw.createS(e.alpha, 0, t).end( function() {
			e.remove();
		});
	}

	inline function hasCollision(p:HParticle, offX=0., offY=0.) {
		return game.level.hasCollision( Std.int((p.x+offX)/Const.GRID), Std.int((p.y+offY)/Const.GRID) );
	}

	function _bloodPhysics(p:HParticle) {
		if( hasCollision(p) && Math.isNaN(p.data0) ) {
			p.data0 = 1;
			p.frict = 0.8;
			p.dx*=0.4;
			p.dy = p.gy = 0;
			p.gy = rnd(0, 0.001);
			p.frict = rnd(0.5,0.7);
			p.dsY = rnd(0, 0.001);
			p.rotation = 0;
			p.dr = 0;
			if( !hasCollision(p,-5,0) || !hasCollision(p,5,0) )
				p.scaleY *= rnd(2,3);
			if( !hasCollision(p,0,-5) || !hasCollision(p,0,5) )
				p.scaleX *= rnd(2,3);
		}
	}

	function _physics(p:HParticle) {
		if( Math.isNaN(p.data0) )
			p.data0 = irnd(1,2);

		// Bounce on ground
		if( hasCollision(p,0,1) && p.dy>0 ) {
			if( p.data0-->0 ) {
				p.dy = -M.fabs(p.dy*0.7);
			}
			else {
				p.rotation = 0;
				p.frict = 0.8;
				p.dy = p.gy = 0;
				p.dr = 0;
			}
		}
		else if( !hasCollision(p,0,2) ) {
			// Bounce on walls
			if( hasCollision(p,2,0) )
				p.dx = -M.fabs(p.dx*0.9);
			else if( hasCollision(p,-2,0) )
				p.dx = M.fabs(p.dx*0.9);
		}
	}

	public function hitWall(x:Float, y:Float, normalDir:Int) {
		// Main impact
		var p = allocTopAdd(getTile("fxShoot"), x-normalDir*rnd(1,3), y+rnd(0,2,true) );
		p.setCenterRatio(0,0.5);
		p.setFadeS(1, 0, 0.03);
		p.colorAnimS( 0xffb600, 0xff4a00, 0.06 );
		p.scaleX = normalDir*rnd(0.7,1);
		p.scaleY = rnd(2,3,true);
		p.scaleXMul = 0.94;
		p.scaleYMul = 0.91;
		p.lifeS = 0.12;

		// Falling dots
		for(i in 0...5) {
			var p = allocTopAdd(getTile("pixel"), x, y+rnd(0,2,true));
			p.setFadeS(rnd(0.5,0.9), 0, rnd(0.2, 0.5));
			p.alphaFlicker = 0.4;
			p.colorAnimS( Color.interpolateInt( 0xffd524, 0xff6606, rnd(0,1) ), 0x990000, rnd(0.3,2) );
			p.dx = normalDir*rnd(0.3,2);
			p.dy = rnd(-1,0.5);
			p.gy = rnd(0.1, 0.2);
			p.frict = rnd(0.92,0.95);
			p.lifeS = rnd(0.4,2);
			p.onUpdate = _physics;
		}

		// Stuck dots
		for(i in 0...7) {
			var p = allocTopAdd(getTile("pixel"), x+rnd(0,1,true)*-normalDir, y+rnd(0,6,true));
			p.colorAnimS( Color.interpolateInt( 0xffd524, 0xff6606, rnd(0,1) ), 0x990000, rnd(0.3,2) );
			p.setFadeS(rnd(0.5,0.9), rnd(0.2,0.4), rnd(1, 2));
			p.alphaFlicker = 0.4;
			p.lifeS = rnd(2,3);
		}
	}

	public function hitEntity(x:Float, y:Float, normalDir:Int) {
		// Main impact
		var p = allocTopAdd(getTile("fxShoot"), x-normalDir*rnd(1,3), y+rnd(0,2,true) );
		p.setCenterRatio(0,0.5);
		p.setFadeS(1, 0, 0.03);
		p.colorAnimS( 0xffb600, 0xff4a00, 0.06 );
		p.scaleX = normalDir*rnd(0.7,1);
		p.scaleY = rnd(2,3,true);
		p.scaleXMul = 0.94;
		p.scaleYMul = 0.91;
		p.lifeS = 0.12;

		// Falling dots
		for(i in 0...5) {
			var p = allocTopAdd(getTile("pixel"), x, y+rnd(0,2,true));
			p.setFadeS(rnd(0.5,0.9), 0, rnd(0.2, 0.5));
			p.alphaFlicker = 0.4;
			p.colorAnimS( Color.interpolateInt( 0xffd524, 0xff6606, rnd(0,1) ), 0x990000, rnd(0.3,2) );
			p.dx = normalDir*rnd(0.3,2);
			p.dy = rnd(-1,0.5);
			p.gy = rnd(0.1, 0.2);
			p.frict = rnd(0.92,0.95);
			p.lifeS = rnd(0.4,2);
			p.onUpdate = _physics;
		}
	}

	public function gunShot(x:Float, y:Float, dir:Int) {
		// Long main line
		var p = allocTopAdd(getTile("fxShoot"), x,y);
		p.setCenterRatio(0,0.5);
		p.setFadeS(1, 0, 0.03);
		p.colorAnimS( 0xffb600, 0xff4a00, 0.06 );
		p.scaleX = dir*rnd(1.5,2);
		p.scaleY = rnd(1.2,1.4,true);
		p.lifeS = 0.12;

		// Core
		for(i in 0...6) {
			var p = allocTopAdd(getTile("fxShoot"), x+rnd(0,1,true), y+rnd(0,1,true));
			p.setCenterRatio(0,0.5);
			p.setFadeS(rnd(0.8,1), 0, 0.03);
			p.colorAnimS( 0xffb600, 0xff4a00, rnd(0,0.06) );
			p.scaleX = dir*rnd(0.7,1.5);
			p.scaleY = rnd(1.5,2.5,true);
			p.lifeS = rnd(0.03,0.06);
		}

		// Small lines
		var n = irnd(9,10);
		for(i in 0...n) {
			var ang = -0.9 + 1.8*(i+1)/n + rnd(0,0.1,true);
			var p = allocTopAdd(getTile("fxLineDir"), x,y);
			p.setFadeS(rnd(0.6,0.9), 0, 0.05);
			p.rotation = ang;
			p.moveAng(ang, rnd(4,8));
			p.colorize(0xef5100);
			p.scaleX = rnd(0.2,0.4);
			p.scaleY = rnd(1,2,true);
			p.scaleXMul = rnd(0.97,0.99);
			p.frict = rnd(0.82,0.84);
			p.lifeS = rnd(0.03,0.06);
		}
	}

	public function cartridge(x:Float, y:Float, dir:Int) {
		var p = allocTopNormal(getTile("fxCartridge"), x+rnd(0,1,true), y);
		p.setFadeS(1, 0, rnd(5,7));
		p.colorize(0xefc04b);
		p.dx = dir*rnd(0.7,2.8);
		p.dy = -rnd(3,4);
		p.scaleX = rnd(1,1.5);
		p.gy = 0.25;
		p.frict = 0.96;
		p.dr = dir*rnd(0.1,0.2);
		p.onUpdate = _physics;
		p.lifeS = rnd(12,15);
	}

	public function bloodBackHits(x:Float, y:Float, dir:Int, qty=1.0) {
		for( i in 0...M.ceil(qty*rnd(9,15)) ) {
			var p = allocTopNormal(getTile("pixel"), x+rnd(0,3,true), y+rnd(0,6,true));
			p.setFadeS(1, 0, rnd(5,7));
			p.colorize( Color.interpolateInt(0xb70000, 0x0, rnd(0,0.2)) );
			p.dx = dir*rnd(0.7,4.8);
			p.dy = rnd(-2,0.5);
			p.gy = rnd(0.2,0.25);
			p.frict = rnd(0.96, 0.97);
			p.onUpdate = _bloodPhysics;
			p.lifeS = rnd(12,15);
		}
	}

	public function bloodFrontHits(x:Float, y:Float, dir:Int, qty=1.0) {
		// Lines
		for( i in 0...M.ceil(qty*rnd(9,15)) ) {
			var p = allocTopNormal(getTile("fxShoot"), x+dir*rnd(4,7), y+rnd(0,2,true));
			p.setCenterRatio(0,0.5);
			p.setFadeS(rnd(0.2,0.6), 0, 0.06);
			p.colorize( Color.interpolateInt(0xb70000, 0x0, rnd(0,0.2)) );
			p.scaleX = rnd(0.7,1.5);
			p.scaleXMul = rnd(0.94,0.96);
			p.dsX = rnd(0,0.1);
			p.dsFrict = 0.9;
			p.moveAwayFrom(x,y,rnd(1,2));
			p.rotation = p.getMoveAng();
			p.frict = rnd(0.91, 0.92);
			p.onUpdate = _bloodPhysics;
			p.lifeS = 0.06;
		}

		// Dots
		for( i in 0...M.ceil(qty*rnd(9,15)) ) {
			var p = allocTopNormal(getTile("pixel"), x+rnd(0,3,true), y+rnd(0,6,true));
			p.setFadeS(1, 0, rnd(5,7));
			p.colorize( Color.interpolateInt(0xb70000, 0x0, rnd(0,0.2)) );
			p.dx = dir*rnd(1,2);
			p.dy = rnd(-2,0.5);
			p.gy = rnd(0.02,0.05);
			p.frict = rnd(0.91, 0.92);
			p.onUpdate = _bloodPhysics;
			p.lifeS = rnd(12,15);
		}
	}

	override function update() {
		super.update();

		pool.update(game.tmod);
	}
}