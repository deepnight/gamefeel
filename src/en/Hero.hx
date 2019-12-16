package en;

class Hero extends Entity {
	var ca : dn.heaps.Controller.ControllerAccess;
	var gun : h2d.Graphics;

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

		var pow = M.fclamp((cHei-2)/4, 0, 1);

		if( options.camShakes ) {
			game.camera.bump(0,3*pow);
			game.camera.shakeS(0.5, 0.2*pow);
		}

		if( options.controlLocks ) {
			dx*=0.5;
			lockS( 0.4*pow );
		}

		if( options.heroSquashAndStrech ) {
			var pow = M.fclamp(cHei/3, 0, 1);
			skew(1+0.2*pow, 1-0.6*pow);
		}
	}

	override function postUpdate() {
		super.postUpdate();

		gun.x = 3;
		gun.y = -hei*0.4;
		if( options.basicAnimations ) {
			var isWalking = onGround && M.fabs(dxTotal)>=0.1;
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
		if( options.camShakes )
			game.camera.bump(-dir*2, 0);

		if( options.flashes )
			fx.flashBangS(0xffcc00, 0.09, 0.1);

		if( options.heroSquashAndStrech )
			skew(1.2,0.9);

		var b = new en.Bullet(this);
		b.speed = 1;
		cd.setS("gunRecoil", 0.1);
		cd.setS("gunHolding", getLockS());

		if( options.cartridges )
			fx.cartridge(centerX, centerY, -dir);

		if( options.gunShotFx )
			fx.gunShot(centerX+dir*8, centerY-1, dir);
	}

	var burstCount = 0;
	override function update() {
		super.update();

		if( onGround )
			cd.setS("airControl",2);

		if( canAct() ) {
			// Walk
			var spd = 0.015 * cd.getRatio("airControl");
			if( ca.rightDown() ) {
				dx+=spd*tmod;
				dir = 1;
			}
			else if( ca.leftDown() ) {
				dx-=spd*tmod;
				dir = -1;
			}
			else
				dx*=Math.pow(frict,tmod);

			// Jump
			if( !onGround && cd.has("extraJumping") && ca.aDown() )
				dy+=-0.09*tmod;

			if( onGround && ca.aPressed() ) {
				dy = -0.20;
				cd.setS("extraJumping", 0.1);
			}

			// Shoot
			if( burstCount<=0 && ca.xDown() && !cd.has("shootLock") )
				chargeAction("shoot", options.gunAiming ? 0.35 : 0., function() {
					burstCount = 4;
					// if( options.heroSquashAndStrech )
						// skew(1.2,0.9);
				});

			if( burstCount>0 ) {
				burstCount--;
				shoot();
				lockS(0.05);
				if( burstCount<=0 && !options.gunAiming )
					lockS(0.35); // to compensate for the missing aiming phase
			}
		}
	}
}