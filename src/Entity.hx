class Entity {
    public static var ALL : Array<Entity> = [];
    public static var GC : Array<Entity> = [];

	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;
	public var destroyed(default,null) = false;
	public var ftime(get,never) : Float; inline function get_ftime() return game.ftime;
	public var tmod(get,never) : Float; inline function get_tmod() return Game.ME.tmod;
	public var hero(get,never) : en.Hero; inline function get_hero() return Game.ME.hero;
	public var options(get,never) : Options; inline function get_options() return Main.ME.options;

	public var cd : dn.Cooldown;

	public var uid : Int;
    public var cx = 0;
    public var cy = 0;
    public var xr = 0.5;
    public var yr = 1.0;

    public var dx = 0.;
    public var dy = 0.;
    public var bdx = 0.;
    public var bdy = 0.;
	public var dxTotal(get,never) : Float; inline function get_dxTotal() return dx+bdx;
	public var dyTotal(get,never) : Float; inline function get_dyTotal() return dy+bdy;
	public var frict = 0.89;
	public var bumpFrict = 0.93;
	var gravity = 0.025;
	public var hei : Float = Const.GRID;
	public var radius = Const.GRID*0.5;
	public var onGround(get,never) : Bool; inline function get_onGround() return level.hasCollision(cx,cy+1) && yr==1 && dy>=0;

	public var dir(default,set) = 1;
	public var sprScaleX = 1.0;
	public var sprScaleY = 1.0;
	public var entityVisible = true;
	public var hasCollisions = true;

	var skewX = 1.;
	var skewY = 1.;
	var animOffsetX = 0.;
	var animOffsetY = 0.;

    public var spr : HSprite;
	public var colorAdd : h3d.Vector;
	var colorMatrix : h3d.Matrix;
	var debugLabel : Null<h2d.Text>;

	public var footX(get,never) : Float; inline function get_footX() return (cx+xr)*Const.GRID;
	public var footY(get,never) : Float; inline function get_footY() return (cy+yr)*Const.GRID;
	public var headX(get,never) : Float; inline function get_headX() return footX;
	public var headY(get,never) : Float; inline function get_headY() return footY-hei;
	public var centerX(get,never) : Float; inline function get_centerX() return footX;
	public var centerY(get,never) : Float; inline function get_centerY() return footY-hei*0.5;

	var actions : Array<{ id:String, cb:Void->Void, startT:Float, curT:Float }> = [];

    public function new(x:Int, y:Int) {
        uid = Const.NEXT_UNIQ;
        ALL.push(this);

		cd = new dn.Cooldown(Const.FPS);
        setPosCase(x,y);

        spr = new HSprite(Assets.tiles);
        Game.ME.scroller.add(spr, Const.DP_MAIN);
		spr.colorAdd = colorAdd = new h3d.Vector();
		colorMatrix = h3d.Matrix.I();
		spr.filter = new h2d.filter.ColorMatrix(colorMatrix);
		spr.setCenterRatio(0.5,1);
		spr.set("pixel");
    }

	inline function set_dir(v) {
		return dir = v>0 ? 1 : v<0 ? -1 : dir;
	}

	public function isAlive() {
		return !destroyed;
	}

	public function kill(by:Null<Entity>) {
		destroy();
	}

	public function setPosCase(x:Int, y:Int) {
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 1;
	}

	public function setPosPixel(x:Float, y:Float) {
		cx = Std.int(x/Const.GRID);
		cy = Std.int(y/Const.GRID);
		xr = (x-cx*Const.GRID)/Const.GRID;
		yr = (y-cy*Const.GRID)/Const.GRID;
	}

	public function bump(x:Float,y:Float) {
		bdx+=x;
		bdy+=y;
	}

	public function cancelVelocities() {
		dx = bdx = 0;
		dy = bdy = 0;
	}

	public function is<T:Entity>(c:Class<T>) return Std.is(this, c);
	public function as<T:Entity>(c:Class<T>) : T return Std.downcast(this, c);

	public inline function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
	public inline function irnd(min,max,?sign) return Lib.irnd(min,max,sign);
	public inline function pretty(v,?p=1) return M.pretty(v,p);

	public inline function dirTo(e:Entity) return e.centerX<centerX ? -1 : 1;
	public inline function dirToAng() return dir==1 ? 0. : M.PI;

	public inline function distCase(e:Entity) return M.dist(cx+xr, cy+yr, e.cx+e.xr, e.cy+e.yr);
	public inline function distCaseFree(tcx:Int, tcy:Int, ?txr=0.5, ?tyr=0.5) return M.dist(cx+xr, cy+yr, tcx+txr, tcy+tyr);

	public inline function distPx(e:Entity) return M.dist(footX, footY, e.footX, e.footY);
	public inline function distPxFree(x:Float, y:Float) return M.dist(footX, footY, x, y);

	public function makePoint() return new CPoint(cx,cy, xr,yr);

    public inline function destroy() {
        if( !destroyed ) {
            destroyed = true;
            GC.push(this);
        }
    }

    public function dispose() {
        ALL.remove(this);

		colorAdd = null;

		spr.remove();
		spr = null;

		if( debugLabel!=null ) {
			debugLabel.remove();
			debugLabel = null;
		}

		cd.destroy();
		cd = null;
    }

	public inline function debug(?v:Dynamic) {
		#if debug
		if( v==null && debugLabel!=null ) {
			debugLabel.remove();
			debugLabel = null;
		}
		if( v!=null ) {
			if( debugLabel==null )
				debugLabel = new h2d.Text(Assets.fontSmall, Game.ME.scroller);
			debugLabel.text = Std.string(v);
		}
		#end
	}


	function chargeAction(id:String, sec:Float, cb:Void->Void) {
		if( isChargingAction(id) )
			cancelAction(id);
		if( sec<=0 )
			cb();
		else {
			if( Boot.ME.isSlowMo() )
				sec*=0.33;
			actions.push({ id:id, cb:cb, startT:sec, curT:sec});
		}
	}

	public function getChargeRatio(id:String) {
		for(a in actions)
			if( a.id==id )
				return 1-a.curT/a.startT;
		return 0.;
	}
	public function isChargingAction(?id:String) {
		if( id==null )
			return actions.length>0;

		for(a in actions)
			if( a.id==id )
				return true;

		return false;
	}

	public function cancelAction(?id:String) {
		if( id==null )
			actions = [];
		else {
			var i = 0;
			while( i<actions.length ) {
				if( actions[i].id==id )
					actions.splice(i,1);
				else
					i++;
			}
		}
	}

	function updateActions() {
		var i = 0;
		while( i<actions.length ) {
			var a = actions[i];
			a.curT -= tmod/Const.FPS;
			if( a.curT<=0 ) {
				actions.splice(i,1);
				if( isAlive() )
					a.cb();
			}
			else
				i++;
		}
	}

	public function lockS(t:Float, ?allowLower=false) {
		if( !isAlive() )
			return;

		if( allowLower )
			cd.setS("lock", t, true);
		else
			cd.setS("lock", t, false);
	}

	public function isLocked() return isAlive() ? cd.has("lock") : true;
	public inline function getLockS() return isAlive() ? cd.getS("lock") : 0.;

	public function canAct() {
		return isAlive() && !isLocked() && !isChargingAction();
	}

	public function getGravity() return gravity;

	public inline function skew(x:Float, y:Float) {
		skewX = x;
		skewY = y;
	}

	public function blink(c:UInt) {
		colorMatrix.colorAdd( Color.addAlphaF(c) );
		cd.setF("keepBlink",1);
	}

    public function preUpdate() {
		cd.update(tmod);
		updateActions();
    }

    public function postUpdate() {
        spr.x = Std.int( (cx+xr)*Const.GRID );
        spr.y = Std.int( (cy+yr)*Const.GRID );
        spr.scaleX = dir*sprScaleX;
        spr.scaleY = sprScaleY;
		spr.visible = entityVisible;

		// Squash & stretch
		spr.scaleX *= skewX;
		spr.scaleY *= skewY;
		skewX += (1-skewX)*0.2;
		skewY += (1-skewY)*0.2;

		// Temp offseting
		spr.x+=animOffsetX;
		spr.y+=animOffsetY;
		animOffsetX *= Math.pow(0.8,tmod);
		animOffsetY *= Math.pow(0.8,tmod);

		// Blink
		if( !cd.has("keepBlink") ) {
			var spd = 0.3;
			colorMatrix._11 += (1-colorMatrix._11)*spd;
			colorMatrix._12 += (0-colorMatrix._12)*spd;
			colorMatrix._13 += (0-colorMatrix._13)*spd;
			colorMatrix._14 += (0-colorMatrix._14)*spd;

			colorMatrix._21 += (0-colorMatrix._21)*spd;
			colorMatrix._22 += (1-colorMatrix._22)*spd;
			colorMatrix._23 += (0-colorMatrix._23)*spd;
			colorMatrix._24 += (0-colorMatrix._24)*spd;

			colorMatrix._31 += (0-colorMatrix._31)*spd;
			colorMatrix._32 += (0-colorMatrix._32)*spd;
			colorMatrix._33 += (1-colorMatrix._33)*spd;
			colorMatrix._34 += (0-colorMatrix._34)*spd;

			colorMatrix._41 += (0-colorMatrix._41)*spd;
			colorMatrix._42 += (0-colorMatrix._42)*spd;
			colorMatrix._43 += (0-colorMatrix._43)*spd;
			colorMatrix._44 += (1-colorMatrix._44)*spd;
			// _12 *= v;
			// _13 *= v;
			// _14 *= v;
			// _21 *= v;
			// _22 *= v;
			// _23 *= v;
			// _24 *= v;
			// _31 *= v;
			// _32 *= v;
			// _33 *= v;
			// _34 *= v;
			// _41 *= v;
			// _42 *= v;
			// _43 *= v;
			// _44 *= v;
			// colorMatrix.multiply
			// colorAdd.r*=Math.pow(0.60, tmod);
			// colorAdd.g*=Math.pow(0.55, tmod);
			// colorAdd.b*=Math.pow(0.50, tmod);
		}

		// Debug
		if( debugLabel!=null ) {
			debugLabel.x = Std.int(footX - debugLabel.textWidth*0.5);
			debugLabel.y = Std.int(footY+1);
		}
    }

	function onLand(cHei:Float) {}


	var fallStartY : Float = Const.INFINITE;
    public function update() {
		// X
		var steps = M.ceil( M.fabs(dxTotal*tmod) );
		var step = dxTotal*tmod / steps;
		while( steps>0 ) {
			xr+=step;

			if( hasCollisions && xr>=0.6 && level.hasCollision(cx+1,cy) ) {
				xr = 0.6;
			}

			if( hasCollisions && xr<=0.4 && level.hasCollision(cx-1,cy) ) {
				xr = 0.4;
			}

			while( xr>1 ) { xr--; cx++; }
			while( xr<0 ) { xr++; cx--; }
			steps--;
		}
		dx*=Math.pow(frict,tmod);
		bdx*=Math.pow(bumpFrict,tmod);
		if( M.fabs(dx)<=0.0005*tmod ) dx = 0;
		if( M.fabs(bdx)<=0.0005*tmod ) bdx = 0;

		// Y
		if( !onGround )
			dy+=getGravity()*tmod;
		if( onGround || dy<0 )
			fallStartY = footY;
		var steps = M.ceil( M.fabs(dyTotal*tmod) );
		var step = dyTotal*tmod / steps;
		while( steps>0 ) {
			yr+=step;

			if( hasCollisions && yr>1 && level.hasCollision(cx,cy+1) ) {
				dy = 0;
				yr = 1;
				bdy = 0;
				onLand( (footY-fallStartY)/Const.GRID );
			}

			if( hasCollisions && yr<0.5 && level.hasCollision(cx,cy-1) )
				yr = 0.5;

			while( yr>1 ) { yr--; cy++; }
			while( yr<0 ) { yr++; cy--; }
			steps--;
		}
		dy*=Math.pow(frict,tmod);
		bdy*=Math.pow(bumpFrict,tmod);
		if( M.fabs(dy)<=0.0005*tmod ) dy = 0;
		if( M.fabs(bdy)<=0.0005*tmod ) bdy = 0;
    }
}