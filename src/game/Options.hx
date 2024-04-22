@:keep class Options {
	public var baseArt = true;
	public var blinkImpact = true;
	public var flashbang = true;
	public var lighting = true;
	public var camShakesXY = true;
	public var camShakesZoom = true;

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
