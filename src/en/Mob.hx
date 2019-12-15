package en;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}
}