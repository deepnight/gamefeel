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

		var spd = 0.004;
		if( ca.rightDown() ) {
			dx+=spd*tmod;
		}
		if( ca.leftDown() ) {
			dx-=spd*tmod;
		}
	}
}