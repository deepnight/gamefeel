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
		gun.beginFill(Color.interpolateInt(c,0x0,0.2)); gun.drawRect(3,1,4,4); // back hand
		gun.beginFill(0xffffff); gun.drawRect(-3,-3,12,6); // gun
		gun.beginFill(c); gun.drawRect(-2,2,4,4); // front hand
	}

	override function dispose() {
		super.dispose();

		ca.dispose();
		ca = null;
	}

	override function onLand() {
		super.onLand();
		if( options.camShakes ) {
			game.camera.bump(0,3);
			game.camera.shakeS(0.5, 0.2);
		}
	}

	override function postUpdate() {
		super.postUpdate();
		gun.x = 3;
		gun.y = -hei*0.5;
	}

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
			if( ca.xDown() && !cd.has("shootLock") ) {
				chargeAction("shoot", 0., function() {
					if( options.camShakes )
						game.camera.bump(-dir*2, 0);

					if( options.flashes )
						fx.flashBangS(0xffcc00, 0.09, 0.1);

					var b = new en.Bullet(this);
					b.speed = 1;
					lockS(0.15);
				});
			}
		}
	}
}