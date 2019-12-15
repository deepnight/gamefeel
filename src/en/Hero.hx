package en;

class Hero extends Entity {
	var ca : dn.heaps.Controller.ControllerAccess;

	public function new(x,y) {
		super(x,y);
		ca = Main.ME.controller.createAccess("hero");

		var g = new h2d.Graphics(spr);
		g.beginFill(0x00ff00);
		g.drawRect(-radius, -hei, radius*2, hei);
	}

	override function dispose() {
		super.dispose();

		ca.dispose();
		ca = null;
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
			}
			else if( ca.leftDown() ) {
				dx-=spd*tmod;
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

			if( ca.xDown() && !cd.has("shootLock") ) {
				chargeAction("shoot", 0.15, function() {
					var b = new en.Bullet(this);
					b.speed = 1;
				});
			}
		}
	}
}