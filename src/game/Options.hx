@:keep class Options {
	@help("Produce a short white flash on Enemy entities hit by a bullet")
	public var blinkImpact = true;

	@help("Produce a screen yellow flash when player shoots.")
	public var flashbang = true;

	@help("Spawn a yellow halo particle when player shoots, or when a bullet hits something.")
	public var lighting = true;

	@help("Shake the camera when player shoots (X shake) or lands from a high place (Y shake).")
	public var camShakesXY = true;

	@help("Abruptly offset the camera for a short period of time. Used when player shoots, dashes or lands from a high place.")
	public var camBumpXY = true;

	@help("Abruptly zoom-in the camera for a short period of time. Used when player lands or dashes.")
	public var camBumpZoom = true;

	@separator
	public var mobSquashAndStrech = true;
	public var heroSquashAndStrech = true;

	@separator
	public var randomizeBullets = true;
	public var basicAnimations = true;
	public var gunAimingAnim = true;

	@separator
	public var cartridges = true;
	public var gunShotFx = true;
	public var bulletTail = true;
	public var bulletImpactFx = true;
	public var bulletImpactDustFx = true;
	public var bulletWallBurnFx = true;
	public var movementFx = true;

	@separator
	public var controlLocks = true;
	public var physicalReactions = true;

	@separator
	public var blood = true;
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
