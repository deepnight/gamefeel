package en;

class Hero extends Entity {
	var ca : dn.heaps.input.ControllerAccess<GameAction>;
	var ctrlQueue : dn.heaps.input.ControllerQueue<GameAction>;
	var gun : h2d.Graphics;
	var dashDir : Int;

	public function new(x,y) {
		super(x,y);

		hei = 22;

		ca = App.ME.controller.createAccess();
		ca.lockCondition = ()->App.ME.anyInputHasFocus() || Window.hasAnyModal();
		ctrlQueue = new ControllerQueue(ca);
		ctrlQueue.watch(A_Jump);
		ctrlQueue.watch(A_Shoot);
		ctrlQueue.watch(A_Dash);

		var c : Col = options.baseArt ? 0x1e65e9 : 0xffffff;

		if( options.heroSprite ) {
			// Real animations
			spr.set(Assets.hero, D.hero.idle);
			spr.setCenterRatio();
			spr.anim.registerStateAnim(D.hero.jumpUp,4, function() return !onGround && vBase.dy<0);
			spr.anim.registerStateAnim(D.hero.jumpDown,4, function() return !onGround && vBase.dy>=0);
			spr.anim.registerStateAnim(D.hero.land,3, function() return onGround && cd.has("landed"));

			spr.anim.registerStateAnim(D.hero.readyWeapon,2, 2, function() return isChargingAction(CA_PrepareGun));

			spr.anim.registerStateAnim(D.hero.runWeapon,1.1, function() return ( isChargingAction(CA_Shoot) || gunIsReady() ) && M.fabs(dxTotal)>=0.08);
			spr.anim.registerStateAnim(D.hero.run,1.0, function() return M.fabs(dxTotal)>=0.08 && !cd.has("walkLock") );

			spr.anim.registerStateAnim(D.hero.idleWeapon,0.1, function() return isChargingAction(CA_Shoot) || gunIsReady() );
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

	public function gunIsReady() {
		return cd.has("gunReady");
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
			if( options.physicalReactions )
				for(e in Mob.ALL) {
					var pow = 1 - M.fclamp( distCase(e) / 12, 0, 1 );
					e.vBase.dx += dirTo(e) * rnd(0.1,0.2) * pow;
					e.vBase.dy = -rnd(0.2,0.3) * pow;
				}
		}

		if( options.camShakesXY ) {
			game.camera.bump(0, 6*pow);
			game.camera.shakeS(0.6*pow, 0.8*pow);
		}

		if( options.camShakesZoom )
			game.camera.bumpZoom(0.03*pow);

		if( options.controlLocks )
			if( cHei>3 ) {
				var pow = M.fclamp((cHei-2)/6, 0, 1);
				vBase.dx *= (1-0.5)*pow;
				lockControlS( 0.2*pow );
				cd.setS("walkLock",0.75*pow);
			}
			else {
				lockControlS( 0.06 );
				vBase.dx *= 0.7;
			}

		if( options.heroSquashAndStrech ) {
			var pow = 0.2 + 0.8 * M.fclamp(cHei/6, 0, 1);
			setSquashY(1-0.5*pow);
		}

		if( options.movementFx && cHei>=3 )
			if( cHei>=3 )
				fx.landSmoke(attachX, attachY, 1);
			else
				fx.landSmoke(attachX, attachY, 0.25);
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
		}

		if( options.gunAimingAnim ) {
			if( cd.has("gunRecoil") ) {
				gun.rotation = -0.15 * cd.getRatio("gunRecoil");
				gun.x -= 4 * cd.getRatio("gunRecoil");
				gun.y-=2;
			}
			else if( isChargingAction(CA_Shoot) || gunIsReady() || burstCount>0 ) {
				gun.x += 3 - 1*getChargeRatio(CA_Shoot);
				gun.y += -1 -1*getChargeRatio(CA_Shoot);
			}
			else {
				gun.y+=2;
				gun.rotation = 0.4;
			}
		}
	}


	function lockControlS(t:Float) {
		cd.setS("controlsLocked", t);
	}

	inline function controlsLocked() {
		return destroyed || cd.has("controlsLocked");
	}

	inline function getControlLockS() {
		return cd.getS("controlsLocked");
	}


	function shoot() {
		if( options.camShakesXY )
			game.camera.bump(-dir*3, 0);

		if( options.flashbang )
			fx.flashBangS(0xffcc00, 0.04, 0.1);

		if( options.heroSquashAndStrech )
			setSquashX(1.2);

		if( options.physicalReactions ) {
			vBase.dx += -dir*rnd(0,0.01);
			sprOffsetX += -dir*rnd(1,3);
		}

		// Create Bullet entity
		var off = options.randomizeBullets ? rnd(0, 1.5, true) : 0;
		if( options.heroSprite )
			off-=1;
		var b = new en.Bullet(this, off);
		if( options.randomizeBullets )
			b.ang += 0.04 - rnd(0,0.065);
		b.speed = options.randomizeBullets ? rnd(0.95,1.05) : 1;
		lockControlS(0.1);
		cd.setS("gunRecoil", 0.1);

		if( options.cartridges )
			fx.cartridge(b.attachX, b.attachY, -dir);

		if( options.gunShotFx )
			fx.gunShot(b.attachX+dir*8, b.attachY+off, dir);

		if( options.lighting ) {
			fx.lightSpot(
				centerX+dir*10 + rnd(0,3,true), centerY-1+rnd(0,3,true),
				new Col(0xff0000).to(0xffcc00,rnd(0,1)),
				0.2
			);
		}
	}

	override function getGravityMul():Float {
		return super.getGravityMul() * ( 0.1 + 0.9*(1-cd.getRatio("reduceGravity")) );
	}


	override function preUpdate() {
		super.preUpdate();
		ctrlQueue.earlyFrameUpdate(game.stime);
	}


	function climbStep(stepDir:Int) {
		dir = stepDir;
		cd.setS("smallStepLock",0.1);
		vBase.dx += 0.15*stepDir;
		vBase.dy = -0.35;
		xr = 0.5 + 0.1*stepDir;
		yr = 0.7;
		lockControlS(0.15);
		setSquashY(0.8);

		if( options.heroSprite )
			spr.anim.playOverlap(D.hero.climbStep);

		if( options.movementFx )
			fx.climbSmoke((cx+0.5 + 0.5*dir)*Const.GRID, cy*Const.GRID, stepDir, 0.5);
	}

	function climbCliff(stepDir:Int) {
		dir = stepDir;
		cd.setS("smallStepLock",0.1);
		vBase.dx += 0.15*stepDir;
		vBase.dy = -0.35;
		xr = 0.5 + 0.1*stepDir;
		yr = 0.7;
		lockControlS(0.2);
		setSquashY(0.8);

		if( options.heroSprite )
			spr.anim.playOverlap(D.hero.climbStep);

		if( options.movementFx )
			fx.climbSmoke((cx+0.5 + 0.5*dir)*Const.GRID, cy*Const.GRID, stepDir, 0.5);
	}

	override function onPreStepX() {
		super.onPreStepX();

		if( options.smallStepsHelper && level.marks.has(M_SmallStep,cx,cy) && !cd.has("smallStepLock")) {
			if( dir>0 && xr>=0.6 && yr>0.5 && dyTotal>=0 && level.marks.hasWithBit(M_SmallStep,SM_Right,cx,cy) )
				climbStep(1);
			else if( dir<0 && xr<=0.4 && yr>0.5 && dyTotal>=0 && level.marks.hasWithBit(M_SmallStep,SM_Left,cx,cy) )
				climbStep(-1);
		}
		if( options.cliffGrabHelper && level.marks.has(M_Cliff,cx,cy) && !cd.has("cliffLock")) {
			if( dir>0 && xr>=0.6 && yr>0.2 && dyTotal>=0 && level.marks.hasWithBit(M_Cliff,SM_Right,cx,cy) )
				climbCliff(1);
			else if( dir<0 && xr<=0.4 && yr>0.2 && dyTotal>=0 && level.marks.hasWithBit(M_Cliff,SM_Left,cx,cy) )
				climbCliff(-1);
		}
	}


	var burstCount = 0;
	override function frameUpdate() {
		super.frameUpdate();

		if( onGround )
			cd.setS("airControl",2);

		// Dir control
		if( ca.isDown(A_MoveRight) )
			dir = 1;
		else if( ca.isDown(A_MoveLeft) )
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
				var spd = (onGround ? 0.015 : 0.019 ) * cd.getRatio("airControl");
				if( isChargingAction(CA_PrepareGun) )
					spd *= 0.1;
				// else if( isChargingAction(CA_Shoot) )
					// spd *= 0.66;

				if( ca.isDown(A_MoveRight) ) {
					vBase.dx+=spd*tmod;
				}
				else if( ca.isDown(A_MoveLeft) ) {
					vBase.dx-=spd*tmod;
				}
				else
					vBase.dx *= Math.pow(0.85,tmod); // braking
			}

			if( onGround )
				cd.setS("allowJitJump",0.15);

			// Jump extra power when held
			// if( !onGround && cd.has("extraJumping") && ca.isDown(A_Jump) )
			// 	vBase.dy+=-0.04*tmod;

			if( !onGround && !cd.has("allowJitJump") && cd.has("allowAirJump") && ctrlQueue.consumePress(A_Jump) ) {
				// Double jump
				vBase.dy = -0.52;
				cd.unset("allowAirJump");
				cd.setS("extraJumping",0.1);
				cd.setS("reduceGravity",0.3);
				if( options.movementFx )
					fx.doubleJump(attachX, attachY);

				if( options.heroSquashAndStrech )
					setSquashX(0.66);
			}

			if( ( onGround || cd.has("allowJitJump") ) && ctrlQueue.consumePressOrDown(A_Jump) ) {
				// Normal jump
				vBase.dy = -0.45;
				cd.setS("reduceGravity",0.1);
				cd.setS("extraJumping", 0.1);
				cd.setS("allowAirJump",Const.INFINITE);
				cd.unset("allowJitJump");
				if( options.heroSquashAndStrech )
					setSquashX(0.55);
			}

			// Dash
			if( !cd.has("dashLock") && ctrlQueue.consumePress(A_Dash) ) {
				cd.setS("dashLock",0.8);
				dashDir = dir;
				vBase.dx = dashDir*0.5;
				vBase.dy *= 0.1;
				burstCount = 0;

				if( options.camShakesXY )
					game.camera.bump(dashDir*6, 0);

				if( options.camShakesZoom )
					game.camera.bumpZoom(0.03);

				cd.setS("dashing", 0.12);
				cd.setS("reduceGravity",0.2);
				lockControlS( cd.getS("dashing")+0.1 );

				if( options.movementFx )
					fx.dash(centerX, centerY, dir);

				if( options.heroSprite )
					vBase.dy-=0.1;
			}

			// Shoot
			if( burstCount<=0 && ca.isDown(A_Shoot) && !cd.has("shootLock") && !isChargingAction(CA_Shoot) && !isChargingAction(CA_PrepareGun) ) {
				if( !options.gunAimingAnim ) {
					burstCount = 3;
				}
				else {
					if( !gunIsReady() )
						chargeAction(CA_PrepareGun, 0.33, (a)->{
							cd.setS("gunReady", 2.5);
							burstCount = 3;
						});
					else
						chargeAction(CA_Shoot, 0.06, (a)->{
							cd.setS("gunReady", 2.5);
							burstCount = 3;
						});
				}
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
			shoot();
			if( burstCount<=0 && !options.gunAimingAnim )
				lockControlS(0.35); // to compensate for the missing aiming phase
		}

		// Queue dash action
		// if( ca.isPressed(A_Dash) && !controlsLocked() && !cd.has("dashing") ) {
		// 	if( isChargingAction() )
		// 		cancelAction();
		// 	cd.setS("dashQueued", 0.25);
		// }
	}
}