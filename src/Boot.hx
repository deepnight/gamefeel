class Boot extends hxd.App {
	public static var ME : Boot;

	// Boot
	static function main() {
		new Boot();
	}

	// Engine ready
	override function init() {
		ME = this;
		new Main(s2d);
		onResize();
	}

	override function onResize() {
		super.onResize();
		dn.Process.resizeAll();
	}

	public inline function isSlowMo() return speed<1;
	public var speed = 1.0;
	override function update(deltaTime:Float) {
		super.update(deltaTime);

		var tmod = hxd.Timer.tmod * ( ui.Modal.hasAny() ? 1 : speed );
		dn.heaps.Controller.beforeUpdate();
		dn.Process.updateAll(tmod);
	}
}

