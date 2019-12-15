package en;

class Hero extends Entity {
	var ca : dn.heaps.Controller.ControllerAccess;

	public function new(x,y) {
		super(x,y);
		ca = Main.ME.controller.createAccess("hero");
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

		debug(pretty(cd.getRatio("airControl")));
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
	}
}