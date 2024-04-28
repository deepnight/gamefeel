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

	@help("Produce a pack of small particles at impact point on walls. They slowly fade from yellow to red then disappear.")
	@when("Bullets hit a wall")
	public var bulletWallBurnFx = true;

	@help("Produce (lots of) blood particles on impacts that stick to nearby walls/grounds. They last for a very long time.")
	@when("Bullets hit enemies")
	public var blood = true;

	@help("Produce a small smoke puff when the player jumps, double-jumps or lands.")
	public var jumpFx = true;

	@help("Produce lines particles representing a trail of blue light as player dashes.")
	@when("Player dashes")
	public var dashFx = true;

	@help("Slightly offset player sprite, without affecting actual ingame physical position.")
	@when("Player shoots")
	public var gunRecoilVisual = true;

	@help("Slightly move player entity as player shoots.")
	@when("Player shoots")
	public var gunRecoilMovement = true;

	@separator

	@help("Briefly lock player controls to simulate a short 'stun' moment after intense events.")
	@when("Player lands from a high place")
	public var controlLocks = true;

	@help("Physical movements of enemies that are a consequence of external events.")
	@when("Enemies are hit by bullets, or player lands nearby")
	public var enemyPhysicalReactions = true;

	@separator
	public var cadavers = true;

	@separator
	public var smallStepsHelper = true;
	public var cliffGrabHelper = true;

	@help("Spawn small particles of dust as player is assisted by traversal helpers (steps/cliffs).")
	@when("Player climbs a step or a cliff")
	public var climbFx = true;

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
