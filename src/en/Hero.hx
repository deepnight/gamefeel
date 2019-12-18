package en;

class Hero extends Entity {
	var ca : dn.heaps.Controller.ControllerAccess;
	var gun : h2d.Graphics;
	var dashDir : Int;

	public function new(x,y) {
		super(x,y);
		ca = Main.ME.controller.createAccess("hero");

		var c = 0x00ff00;
		var g = new h2d.Graphics(spr);
		g.beginFill(Color.interpolateInt(c,0x0,0.4));
		g.drawRect(-radius, -hei, radius*2, hei);
		g.endFill();

		gun = new h2d.Graphics(spr);
		gun.beginFill(Color.interpolateInt(c,0x0,0.2)); gun.drawRect(3,-1,4,4); // back hand
		gun.beginFill(0xffffff); gun.drawRect(-3,-5,12,6); // gun
		gun.beginFill(c); gun.drawRect(-2,0,4,4); // front hand
	}

	override function dispose() {
		super.dispose();

		ca.dispose();
		ca = null;
	}

	override function onLand(cHei) {
		super.onLand(cHei);

		var pow = M.fclamp((cHei-2)/6, 0, 1);

		if( cHei>=4 ) {
			Assets.SBANK.stepHeavy0().playOnGroup(2,0.33);
			Assets.SBANK.land0().playOnGroup(3,0.2);

			if( options.physicalReactions )
				for(e in Mob.ALL) {
					e.dx+=dirTo(e) * rnd(0.06,0.11);
					e.dy = -rnd(0.1,0.2);
				}
		}
		else
			Assets.SBANK.land0().playOnGroup(3,0.2);

		if( options.camShakesXY ) {
			game.camera.bumpXY(0,6*pow);
			game.camera.shakeY(0.6*pow, 0.8*pow);
		}

		if( options.camShakesZoom )
			game.camera.bumpZoom(0.03*pow);

		if( options.controlLocks ) {
			dx*=0.5;
			lockS( 0.2*pow );
			cd.setS("walkLock",0.75*pow);
		}

		if( options.heroSquashAndStrech ) {
			var pow = M.fclamp(cHei/6, 0, 1);
			skew(1+0.4*pow, 1-0.8*pow);
		}
	}

	override function postUpdate() {
		super.postUpdate();

		gun.x = 3;
		gun.y = -hei*0.4;
		if( options.basicAnimations ) {
			var isWalking = onGround && M.fabs(dxTotal)>=0.03;
			gun.x += ( isWalking ? -2 + Math.cos(ftime*0.2)*3 : 0 );
			gun.y += isWalking ? M.fabs( Math.sin(0.2+ftime*0.3)*1 ) : 0;
			gun.rotation = 0;

			if( options.gunAiming ) {
				if( cd.has("gunRecoil") ) {
					gun.rotation = -0.15 * cd.getRatio("gunRecoil");
					gun.x -= 4 * cd.getRatio("gunRecoil");
					gun.y-=2;
				}
				else if( isChargingAction("shoot") || cd.has("gunHolding") || burstCount>0 ) {
					gun.x += 3 - 1*getChargeRatio("shoot");
					gun.y += -1 -1*getChargeRatio("shoot");
				}
				else {
					gun.y+=2;
					gun.rotation = 0.4;
				}
			}
		}
	}

	function shoot() {
		if( options.camShakesXY )
			game.camera.bumpXY(-dir*3, 0);

		if( options.flashes )
			fx.flashBangS(0xffcc00, 0.04, 0.1);

		if( options.heroSquashAndStrech )
			skew(1.2,0.9);

		if( options.physicalReactions ) {
			dx += -dir*rnd(0,0.01);
			animOffsetX+=-dir*rnd(1,3);
		}

		var b = new en.Bullet(this, rnd(0,1,true));
		if( options.randomizeBullets )
			b.ang += 0.04 - rnd(0,0.05);
		b.speed = 1;
		cd.setS("gunRecoil", 0.1);
		cd.setS("gunHolding", getLockS());

		if( options.cartridges )
			fx.cartridge(centerX, centerY, -dir);

		if( options.gunShotFx )
			fx.gunShot(centerX+dir*8, centerY-1, dir);
	}

	override function getGravity():Float {
		return super.getGravity() * ( 0.3 + 0.7*(1-cd.getRatio("reduceGravity")) );
	}

	var burstCount = 0;
	override function update() {
		super.update();

		if( onGround )
			cd.setS("airControl",2);

		// Dir control
		if( ca.rightDown() )
			dir = 1;
		else if( ca.leftDown() )
			dir = -1;

		if( canAct() ) {
			// Walk
			if( !cd.has("walkLock") ) {
				var spd = (onGround ? 0.011 : 0.015 ) * cd.getRatio("airControl");
				if( ca.rightDown() ) {
					dx+=spd*tmod;
				}
				else if( ca.leftDown() ) {
					dx-=spd*tmod;
				}
				else
					dx*=Math.pow(frict,tmod);
			}

			// Jump
			if( !onGround && cd.has("extraJumping") && ca.aDown() )
				dy+=-0.08*tmod;

			if( !onGround && ca.aPressed() && cd.has("allowAirJump") ) {
				// Double jump
				dy = -0.1;
				cd.unset("allowAirJump");
				cd.setS("extraJumping",0.1);
				cd.setS("reduceGravity",0.3);
			}

			if( onGround && ca.aPressed() ) {
				// Normal jump
				Assets.SBANK.dash1(0.2);
				dy = -0.16;
				cd.setS("reduceGravity",0.1);
				cd.setS("extraJumping", 0.1);
				cd.setS("allowAirJump",Const.INFINITE);
			}

			// Dash
			if( ( ca.bPressed() || cd.has("dashQueued") ) && !cd.hasSetS("dashLock",0.3) ) {
				cd.unset("dashQueued");
				dashDir = dir;
				dx = dashDir*0.5;
				Assets.SBANK.jetpack0().playOnGroup(3,0.3);

				if( options.camShakesXY )
					game.camera.bumpXY(dashDir*6, 0);

				if( options.camShakesZoom )
					game.camera.bumpZoom(0.03);

				cd.setS("dashing", 0.08);
				lockS( cd.getS("dashing")+0.1 );
			}

			// Shoot
			if( burstCount<=0 && ( ca.xDown() || ca.rtDown() ) && !cd.has("shootLock") ) {
				if( options.gunAiming )
					Assets.SBANK.aim0(0.5);
				chargeAction("shoot", options.gunAiming ? 0.39 : 0., function() {
					burstCount = 4;
				});
			}
		}

		// Dash movement
		if( cd.has("dashing") ) {
			dx+=dashDir*0.06*tmod;
			skew(1.3,0.7);
		}

		// Burst shooting
		if( burstCount>0 && !cd.hasSetS("burstLock",0.06)) {
			burstCount--;
			Assets.SBANK.gun0().playOnGroup(1,0.8);
			shoot();
			lockS(0.05);
			if( burstCount<=0 && !options.gunAiming )
				lockS(0.35); // to compensate for the missing aiming phase
		}

		// Queue dash action
		if( ca.bPressed() && !canAct() && !cd.has("dashing") ) {
			if( isChargingAction() )
				cancelAction();
			cd.setS("dashQueued", 0.25);
		}
	}
}