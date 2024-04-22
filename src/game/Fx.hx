import h2d.Sprite;
import dn.heaps.HParticle;


class Fx extends GameChildProcess {
	var pool : ParticlePool;

	public var options(get,never) : Options; inline function get_options() return App.ME.options;

	public var bg_add    : h2d.SpriteBatch;
	public var bg_normal    : h2d.SpriteBatch;
	public var main_add       : h2d.SpriteBatch;
	public var main_normal    : h2d.SpriteBatch;

	public function new() {
		super();

		pool = new ParticlePool(Assets.tiles.tile, 2048, Const.FPS);

		bg_add = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(bg_add, Const.DP_FX_BG);
		bg_add.blendMode = Add;
		bg_add.hasRotationScale = true;

		bg_normal = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(bg_normal, Const.DP_FX_BG);
		bg_normal.hasRotationScale = true;

		main_normal = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(main_normal, Const.DP_FX_FRONT);
		main_normal.hasRotationScale = true;

		main_add = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(main_add, Const.DP_FX_FRONT);
		main_add.blendMode = Add;
		main_add.hasRotationScale = true;
	}

	override public function onDispose() {
		super.onDispose();

		pool.dispose();
		bg_add.remove();
		bg_normal.remove();
		main_add.remove();
		main_normal.remove();
	}

	/** Clear all particles **/
	public function clear() {
		pool.clear();
	}

	/** Create a HParticle instance in the BG layer, using ADDITIVE blendmode **/
	public inline function allocBg_add(id,x,y) return pool.alloc(bg_add, Assets.tiles.getTileRandom(id), x, y);

	/** Create a HParticle instance in the BG layer, using NORMAL blendmode **/
	public inline function allocBg_normal(id,x,y) return pool.alloc(bg_normal, Assets.tiles.getTileRandom(id), x, y);

	/** Create a HParticle instance in the MAIN layer, using ADDITIVE blendmode **/
	public inline function allocMain_add(id,x,y) return pool.alloc( main_add, Assets.tiles.getTileRandom(id), x, y );

	/** Create a HParticle instance in the MAIN layer, using NORMAL blendmode **/
	public inline function allocMain_normal(id,x,y) return pool.alloc(main_normal, Assets.tiles.getTileRandom(id), x, y);


	public inline function markerEntity(e:Entity, c:Col=Pink, short=false) {
		#if debug
		if( e!=null && e.isAlive() )
			markerCase(e.cx, e.cy, short?0.03:3, c);
		#end
	}

	public inline function markerCase(cx:Int, cy:Int, sec=3.0, c:Col=Pink) {
		#if debug
		var p = allocMain_add(D.tiles.fxCircle, (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.lifeS = sec;

		var p = allocMain_add(D.tiles.fxPixel, (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(2);
		p.lifeS = sec;
		#end
	}

	public inline function markerFree(x:Float, y:Float, sec=3.0, c:Col=Pink) {
		#if debug
		var p = allocMain_add(D.tiles.fxDot, x,y);
		p.setCenterRatio(0.5,0.5);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(3);
		p.lifeS = sec;
		#end
	}

	public inline function markerText(cx:Int, cy:Int, txt:String, t=1.0) {
		#if debug
		var tf = new h2d.Text(Assets.fontPixel, main_normal);
		tf.text = txt;

		var p = allocMain_add(D.tiles.fxCircle, (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.colorize(0x0080FF);
		p.alpha = 0.6;
		p.lifeS = 0.3;
		p.fadeOutSpeed = 0.4;
		p.onKill = tf.remove;

		tf.setPosition(p.x-tf.textWidth*0.5, p.y-tf.textHeight*0.5);
		#end
	}


	public inline function markerLine(fx:Float, fy:Float, tx:Float, ty:Float, c:Col, sec=3.) {
		#if debug
		var p = allocMain_add(D.tiles.fxLineFadeBoth, fx,fy);
		p.setFadeS(1, 0, 0);
		p.colorize(c);
		p.setCenterRatio(0,0.5);
		p.scaleX = M.dist(fx,fy,tx,ty) / p.t.width;
		p.rotation = Math.atan2(ty-fy, tx-fx);
		p.lifeS = sec;
		#end
	}

	inline function collides(p:HParticle, offX=0., offY=0.) {
		return level.hasCollision( Std.int((p.x+offX)/Const.GRID), Std.int((p.y+offY)/Const.GRID) );
	}

	public inline function flashBangS(c:Col, a:Float, t=0.1) {
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
		if( options.bulletImpactFx ) {
			var p = allocMain_add(D.tiles.fxShoot, x-normalDir*rnd(1,3), y+rnd(0,2,true) );
			p.setCenterRatio(0,0.5);
			p.setFadeS(1, 0, 0.03);
			p.colorAnimS( 0xffb600, 0xff4a00, 0.06 );
			p.scaleX = normalDir*rnd(0.7,1);
			p.scaleY = rnd(2,3,true);
			p.scaleXMul = 0.94;
			p.scaleYMul = 0.91;
			p.lifeS = 0.12;
		}

		// Falling dots
		if( options.bulletImpactBurnFx )
			for(i in 0...5) {
				var p = allocMain_add(D.tiles.fxPixel, x, y+rnd(0,2,true));
				p.setFadeS(rnd(0.5,0.9), 0, rnd(0.2, 0.5));
				p.alphaFlicker = 0.4;
				p.colorAnimS( new Col(0xffd524).to(0xff6606, rnd(0,1) ), 0x990000, rnd(0.3,2) );
				p.dx = normalDir*rnd(0.3,2);
				p.dy = rnd(-1,0.5);
				p.gy = rnd(0.1, 0.2);
				p.frict = rnd(0.92,0.95);
				p.lifeS = rnd(0.4,2);
				p.onUpdate = _physics;
			}

		// Stuck dots
		if( options.bulletImpactBurnFx )
			for(i in 0...7) {
				var p = allocMain_add(D.tiles.fxPixel, x+rnd(0,1,true)*-normalDir, y+rnd(0,6,true));
				p.colorAnimS( new Col(0xffd524).to(0xff6606, rnd(0,1) ), 0x990000, rnd(0.3,2) );
				p.setFadeS(rnd(0.5,0.9), rnd(0.2,0.4), rnd(1, 2));
				p.alphaFlicker = 0.4;
				p.lifeS = rnd(2,3);
			}
	}

	public function hitEntity(x:Float, y:Float, normalDir:Int) {
		// Main impact
		var p = allocMain_add(D.tiles.fxShoot, x-normalDir*rnd(1,3), y+rnd(0,2,true) );
		p.setCenterRatio(0,0.5);
		p.setFadeS(1, 0, 0.03);
		p.colorAnimS( 0xffb600, 0xff4a00, 0.06 );
		p.scaleX = normalDir*rnd(0.7,1);
		p.scaleY = rnd(2,3,true);
		p.scaleXMul = 0.94;
		p.scaleYMul = 0.91;
		p.lifeS = 0.12;

		// Falling dots
		if( options.bulletImpactBurnFx )
			for(i in 0...5) {
				var p = allocMain_add(D.tiles.fxPixel, x, y+rnd(0,2,true));
				p.setFadeS(rnd(0.5,0.9), 0, rnd(0.2, 0.5));
				p.alphaFlicker = 0.4;
				p.colorAnimS( new Col(0xffd524).to(0xff6606, rnd(0,1) ), 0x990000, rnd(0.3,2) );
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
		var p = allocMain_add(D.tiles.fxShoot, x,y);
		p.setCenterRatio(0,0.5);
		p.setFadeS(1, 0, 0.03);
		p.colorAnimS( 0xffb600, 0xff4a00, 0.06 );
		p.scaleX = dir*rnd(1.5,2);
		p.scaleY = rnd(1.2,1.4,true);
		p.lifeS = 0.12;

		// Core
		for(i in 0...6) {
			var p = allocMain_add(D.tiles.fxShoot, x+rnd(0,1,true), y+rnd(0,1,true));
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
			var ang = (dir==1?0:M.PI) + -0.9 + 1.8*(i+1)/n + rnd(0,0.1,true);
			var p = allocMain_add(D.tiles.fxLineFadeBoth, x,y);
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
		var p = allocMain_normal(D.tiles.fxCartridge, x+rnd(0,1,true), y);
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

	function _trackEntity(p:HParticle) {
		var e : Entity = p.userData;
		if( e==null )
			return;
		p.setPosition(e.attachX+p.data0, e.attachY+p.data1);
	}

	inline function trackEntity(p:HParticle, e:Entity) {
		p.userData = e;
		p.onUpdate = _trackEntity;
		p.data0 = p.x - e.attachX;
		p.data1 = p.y - e.attachY;
	}

	public function lightSpot(x:Float, y:Float, c:Col, a=1.0) {
		var p = allocMain_add(D.tiles.fxHalo, x,y);
		p.setScale(rnd(2,3));
		p.setFadeS(a, 0, 0.3);
		p.colorize(c);
		p.ds = 0.1;
		p.dsFrict = 0.9;
		p.scaleMul = 0.92;
		p.lifeS = 0.1;
	}

	public function landSmoke(x:Float, y:Float) {
		var c = 0xb78662;
		for(i in 0...20) {
			var dir = i%2==0 ? 1 : -1;
			var p = allocMain_normal(D.tiles.fxSmoke, x+rnd(0,6)*dir, y+rnd(0,2,true));
			p.colorize(c);
			p.setFadeS(rnd(0.1,0.2), 0.1, rnd(0.3,1.5));

			p.setScale(rnd(0.3,0.5,true));
			p.scaleMul = rnd(1,1.002);

			p.dx = rnd(0.1,1) * dir;
			p.dy = -rnd(0.1,0.4);
			p.frict = rnd(0.92,0.94);

			p.rotation = rnd(0,6.28);
			p.dr = rnd(0,0.002,true);
			p.lifeS = rnd(0.3,0.9);
		}
	}

	public function bloodBackHits(x:Float, y:Float, dir:Int, qty=1.0) {
		// Hit line
		var ang = (dir==1?0:M.PI) + rnd(0,0.1,true);
		var p = allocMain_normal(D.tiles.fxShoot, x+dir*rnd(0,1,true), y+rnd(0,4,true));
		p.setCenterRatio(0,0.5);
		p.setFadeS(rnd(0.9,1), 0, 0.06);
		p.colorize( new Col(0xb70000).toBlack(rnd(0,0.2)) );
		p.scaleX = rnd(2,3);
		p.scaleXMul = rnd(0.94,0.96);
		p.dsX = rnd(0,0.1);
		p.dsFrict = 0.9;
		p.moveAng(ang,rnd(3,4));
		p.rotation = ang;
		p.frict = rnd(0.91, 0.92);
		p.lifeS = rnd(0.06,0.10);

		// Dots
		for( i in 0...M.ceil(qty*rnd(9,15)) ) {
			var p = allocBg_normal(D.tiles.fxPixel, x+rnd(0,3,true), y+rnd(0,6,true));
			p.setFadeS(1, 0, rnd(5,7));
			p.colorize( new Col(0xb70000).toBlack(rnd(0,0.2)) );
			p.dx = dir*rnd(0.7,4.8);
			p.dy = rnd(-2,0.5);
			p.gy = rnd(0.2,0.25);
			p.frict = rnd(0.96, 0.97);
			p.onUpdate = _bloodPhysics;
			p.lifeS = rnd(12,15);
		}
	}

	public function bloodFrontHits(x:Float, y:Float, dir:Int, qty=1.0) {
		// Core lines
		for( i in 0...M.ceil(qty*rnd(3,5)) ) {
			var ang = (dir==1?0:M.PI) + rnd(0,0.2,true);
			var p = allocMain_normal(D.tiles.fxShoot, x+dir*rnd(0,1,true), y+rnd(0,5,true));
			p.setCenterRatio(0,0.5);
			p.setFadeS(rnd(0.2,0.6), 0, 0.06);
			p.colorize( new Col(0xb70000).toBlack(rnd(0,0.2)) );
			p.scaleX = rnd(0.7,1.5);
			p.scaleXMul = rnd(0.94,0.96);
			p.dsX = rnd(0,0.1);
			p.dsFrict = 0.9;
			p.moveAng(ang,rnd(1,2));
			p.rotation = ang;
			p.frict = rnd(0.91, 0.92);
			p.lifeS = rnd(0.06,0.12);
		}

		// Dots
		for( i in 0...M.ceil(qty*rnd(9,15)) ) {
			var p = allocBg_normal(D.tiles.fxPixel, x+rnd(0,3,true), y+rnd(0,6,true));
			p.setFadeS(1, 0, rnd(5,7));
			p.colorize( new Col(0xb70000).toBlack(rnd(0,0.2)) );
			p.dx = dir*rnd(-2,3.5);
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