package en;

class Hero extends Entity {
	var ca : dn.heaps.input.ControllerAccess<GameAction>;
	var gun : h2d.Graphics;
	var dashDir : Int;

	public function new(x,y) {
		super(x,y);
		ca = App.ME.controller.createAccess();
		var c : Col = options.baseArt ? 0x00ff00 : 0xffffff;

		if( options.heroSprite ) {
			// Real animations
			spr.set(Assets.hero, D.hero.idle);
			spr.anim.registerStateAnim(D.hero.jumpUp,4, function() return !onGround && vBase.dy<0);
			spr.anim.registerStateAnim(D.hero.jumpDown,4, function() return !onGround && vBase.dy>=0);
			spr.anim.registerStateAnim(D.hero.land,3, function() return onGround && cd.has("landed"));
			spr.anim.registerStateAnim(D.hero.idleWeapon,2, function() return isChargingAction(CA_Shoot) || cd.has("gunHolding"));

			// spr.anim.registerStateAnim("mechWalkWeapon",2, 1.0 /* Speed is set in update */, function() return isCarryingAnything() && getCurrentVelocity()>=0.0001 );

			spr.anim.registerStateAnim(D.hero.run,1, function() return M.fabs(dxTotal)>=0.04 );
			// spr.anim.registerStateAnim("mechWalkWeapon",1, 1.0 /* Speed is set in update */, function() return weaponReady && !cd.has("running") && getCurrentVelocity()>=0.0001 );

			// spr.anim.registerStateAnim("mechRun",1, 0.35 /* Speed is set in update */, function() return !weaponReady && cd.has("running") && getCurrentVelocity()>=0.010 );
			// spr.anim.registerStateAnim("mechWalk",1, 1.0 /* Speed is set in update */, function() return !weaponReady && !cd.has("running") && getCurrentVelocity()>=0.0001 );

			spr.anim.registerStateAnim(D.hero.idle,0);
		}
		else {
			// Hero placeholder
			var g = new h2d.Graphics(spr);
			g.beginFill(c.toBlack(0.4));
			g.drawRect(-innerRadius, -hei, innerRadius*2, hei);
			g.endFill();
		}

		// Gun placeholder
		gun = new h2d.Graphics(spr);
		gun.visible = options.baseArt && !options.heroSprite;
		gun.beginFill(c.toBlack(0.2)); gun.drawRect(3,-1,4,4); // back hand
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
			cd.setS("landed", 0.5*pow);

		if( cHei>=4 ) {
			// Assets.SBANK.stepHeavy0().playOnGroup(2,0.33);
			// Assets.SBANK.land0().playOnGroup(3,0.2);

			// if( options.physicalReactions ) // TODO mobs phys reactions
			// 	for(e in Mob.ALL) {
			// 		e.dx+=dirTo(e) * rnd(0.06,0.11);
			// 		e.dy = -rnd(0.1,0.2);
			// 	}
		}
		// else
		// 	Assets.SBANK.land0().playOnGroup(3,0.2);

		if( options.camShakesXY ) {
			game.camera.bump(0, 6*pow);
			game.camera.shakeS(0.6*pow, 0.8*pow);
		}

		if( options.camShakesZoom )
			game.camera.bumpZoom(0.03*pow);

		if( options.controlLocks && cHei>2 ) {
			var pow = M.fclamp((cHei-2)/6, 0, 1);
			vBase.dx *= (1-0.5)*pow;
			lockControlS( 0.2*pow );
			cd.setS("walkLock",0.75*pow);
		}

		if( options.heroSquashAndStrech ) {
			var pow = M.fclamp(cHei/6, 0, 1);
			setSquashY(1-0.8*pow);
		}

		// if( options.heroSprite && cHei>=3 )
		// 	fx.landSmoke(attachX, attachY);
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
				else if( isChargingAction(CA_Shoot) || cd.has("gunHolding") || burstCount>0 ) {
					gun.x += 3 - 1*getChargeRatio(CA_Shoot);
					gun.y += -1 -1*getChargeRatio(CA_Shoot);
				}
				else {
					gun.y+=2;
					gun.rotation = 0.4;
				}
			}
		}
	}


	function lockControlS(t:Float) {
		cd.setS("controlsLocked", t);
	}

	inline function controlsLocked() {
		return destroyed || cd.has("controlsLocked");
	}


	function shoot() {
		// if( options.camShakesXY )
		// 	game.camera.bumpXY(-dir*3, 0);

		// if( options.flashes )
		// 	fx.flashBangS(0xffcc00, 0.04, 0.1);

		// if( options.heroSquashAndStrech )
		// 	skew(1.2,0.9);

		// if( options.physicalReactions ) {
		// 	dx += -dir*rnd(0,0.01);
		// 	animOffsetX+=-dir*rnd(1,3);
		// }

		// var off = options.randomizeBullets ? rnd(0, 2.5, true) : 0;
		// if( options.heroSprite )
		// 	off-=3;
		// var b = new en.Bullet(this, off);
		// if( options.randomizeBullets )
		// 	b.ang += 0.04 - rnd(0,0.065);
		// b.speed = options.randomizeBullets ? rnd(0.95,1.05) : 1;
		// lockControlS(0.1);
		// cd.setS("gunRecoil", 0.1);
		// cd.setS("gunHolding", getLockS());

		// if( options.cartridges )
		// 	fx.cartridge(b.footX, b.footY, -dir);

		// if( options.gunShotFx )
		// 	fx.gunShot(b.footX+dir*8, b.footY-1, dir);

		// if( options.lighting ) {
		// 	fx.lightSpot(
		// 		centerX+dir*10 + rnd(0,3,true), centerY-1+rnd(0,3,true),
		// 		new Col(0xff0000).to(0xffcc00,rnd(0,1)),
		// 		0.2
		// 	);
		// }
	}

	override function getGravityMul():Float {
		return super.getGravityMul() * ( 0.3 + 0.7*(1-cd.getRatio("reduceGravity")) );
	}

	var burstCount = 0;
	override function frameUpdate() {
		super.frameUpdate();

		if( onGround )
			cd.setS("airControl",2);

		// Dir control
		if( ca.isDown(GA_MoveRight) )
			dir = 1;
		else if( ca.isDown(GA_MoveLeft) )
			dir = -1;

		// Run step frames
		if( options.heroSprite && ( spr.groupName=="mechRun" || spr.groupName=="mechRunWeapon" ) && spr.frame==1 && !cd.hasSetS("runCycleBreak"+spr.frame, 0.25) ) {
			// Run
			vBase.dx *= 0.4;
			vBase.dy *= 0.4;
			if( options.camShakesXY ) {
				game.camera.bump(0,0.5);
				game.camera.shakeS(0.3,0.2);
			}
		}

		if( !controlsLocked() ) {
			// Walk
			if( !cd.has("walkLock") ) {
				var spd = (onGround ? 0.015 : 0.015 ) * cd.getRatio("airControl");
				if( ca.isDown(GA_MoveRight) ) {
					vBase.dx+=spd*tmod;
				}
				else if( ca.isDown(GA_MoveLeft) ) {
					vBase.dx-=spd*tmod;
				}
				else
					vBase.dx *= Math.pow(0.85,tmod); // braking
			}

			debug(M.pretty(vBase.dx,4));

			// Jump
			if( !onGround && cd.has("extraJumping") && ca.isDown(GA_Jump) )
				vBase.dy+=-0.08*tmod;

			if( !onGround && ca.isPressed(GA_Jump) && cd.has("allowAirJump") ) {
				// Double jump
				vBase.dy = -0.1;
				cd.unset("allowAirJump");
				cd.setS("extraJumping",0.1);
				cd.setS("reduceGravity",0.3);
				if( options.heroSquashAndStrech )
					setSquashX(0.85);
			}

			if( onGround && ca.isPressed(GA_Jump) ) {
				// Normal jump
				// Assets.SBANK.dash1(0.2);
				vBase.dy = -0.16;
				cd.setS("reduceGravity",0.1);
				cd.setS("extraJumping", 0.1);
				cd.setS("allowAirJump",Const.INFINITE);
				if( options.heroSquashAndStrech )
					setSquashX(0.55);
			}

			// Dash
			if( ( ca.isPressed(GA_Dash) || cd.has("dashQueued") ) && !cd.hasSetS("dashLock",0.3) ) {
				cd.unset("dashQueued");
				dashDir = dir;
				vBase.dx = dashDir*0.5;
				burstCount = 0;
				// Assets.SBANK.jetpack0().playOnGroup(3,0.3);

				if( options.camShakesXY )
					game.camera.bump(dashDir*6, 0);

				if( options.camShakesZoom )
					game.camera.bumpZoom(0.03);

				cd.setS("dashing", 0.08);
				lockControlS( cd.getS("dashing")+0.1 );

				if( options.heroSprite )
					vBase.dy-=0.1;
			}

			// Shoot
			if( burstCount<=0 && ca.isDown(GA_Shoot) && !cd.has("shootLock") ) {
				// if( options.gunAiming )
				// 	Assets.SBANK.aim0(0.5);
				chargeAction(CA_Shoot, options.gunAiming ? 0.39 : 0., (a)->{
					burstCount = 4;
				});
			}
		}

		// Dash movement
		if( cd.has("dashing") ) {
			vBase.dx+=dashDir*0.06*tmod;
			if( options.heroSquashAndStrech )
				setSquashX(1.3);
		}

		// Burst shooting
		if( burstCount>0 && !cd.hasSetS("burstLock", options.randomizeBullets ? rnd(0.04,0.07) : 0.06)) {
			burstCount--;
			// Assets.SBANK.gun0().playOnGroup(1,0.8);
			shoot();
			if( burstCount<=0 && !options.gunAiming )
				lockControlS(0.35); // to compensate for the missing aiming phase
		}

		// Queue dash action
		if( ca.isPressed(GA_Dash) && !controlsLocked() && !cd.has("dashing") ) {
			if( isChargingAction() )
				cancelAction();
			cd.setS("dashQueued", 0.25);
		}
	}
}