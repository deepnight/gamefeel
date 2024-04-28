@:keep class Options {
	@help("Produce a short white flash on entities.")
	@when("Bullets hit enemy entities")
	public var blinkImpact = true;

	@help("Produce a screen yellow flash.")
	@when("Player shoots")
	public var flashbang = true;

	@help("Spawn a yellow halo particle.")
	@when("Player shoots or bullets hit anything")
	public var lighting = true;

	@help("Shake the camera horizontally or vertically.")
	@when("Player shoots (X shake) or lands from a high place (Y shake)")
	public var camShakesXY = true;

	@help("Abruptly offset the camera for a short period of time.")
	@when("Player shoots or lands from a high place")
	public var camBumpXY = true;

	@help("Abruptly zoom-in the camera for a short period of time.")
	@when("Player lands or dashes")
	public var camBumpZoom = true;

	@separator

	@help("Distort enemies like a jelly ball in reaction of external events.")
	@when("Enemies are hit by bullets")
	public var mobSquashAndStrech = true;

	@help("Distort the hero like a jelly ball in reaction of external events.")
	@when("Player jumps, lands, dashes or shoots")
	public var heroSquashAndStrech = true;

	@separator

	@help("Slightly randomize bullets spreading to make them feel more natural.")
	public var randomizeBullets = true;

	@help("Activate simple animations for the player.")
	public var basicAnimations = true;

	@help("Activate weapon related animations for the player (aiming and shooting).")
	@when("Player shoots")
	public var gunAnimations = true;

	@separator

	@help("Produce small cartridges particles that fall and bounce on the ground. They last for a long time.")
	@when("Player shoots")
	public var cartridges = true;

	@help("Produce brief burst particles at the weapon muzzle.")
	@when("Player shoots")
	public var gunShotFx = true;

	@help("Add a a short tail of light to Bullets as they move.")
	public var bulletTail = true;

	@help("Produce brief impact particles at impact point.")
	@when("Bullets hit anything")
	public var bulletImpactFx = true;

	@help("Produce a pack of small particles of dust that fall to the ground at impact point.")
	@when("Bullets hit anything")
	public var bulletImpactDustFx = true;

	public var bulletWallBurnFx = true;
	public var blood = true;

	@help("Produce a small smoke puff when the player lands.")
	public var movementFx = true;

	@separator
	public var controlLocks = true;
	public var physicalReactions = true;

	@separator
	public var cadavers = true;

	@separator
	public var smallStepsHelper = true;
	public var cliffGrabHelper = true;
	public var justInTimeJump = true;
	public var ctrlQueue = true;
	public var slowMos = true;

	@separator
	public var levelTextures = true;
	public var heroSprite = true;

	public function new() {}

	public function setAll(v:Bool) {
		for(k in Type.getInstanceFields(Options))
			if( Type.typeof(Reflect.field(this,k)) == TBool )
				Reflect.setField(this, k, v);
	}
}
