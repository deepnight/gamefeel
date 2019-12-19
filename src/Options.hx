@:keep
class Options {
	public var baseArt = false;
	public var flashes = false;
	public var camShakesXY = false;
	public var camShakesZoom = false;
	public var controlLocks = false;

	@separator
	public var heroSquashAndStrech = false;
	public var randomizeBullets = false;
	public var basicAnimations = false;
	public var gunAiming = false;

	@separator
	public var cartridges = false;
	public var gunShotFx = false;
	public var bulletImpactFx = false;

	@separator
	public var physicalReactions = false;
	public var blinkImpact = false;
	public var mobSquashAndStrech = false;

	@separator
	public var blood = false;
	public var cadavers = false;

	@separator
	public var sounds = false;
	public var levelTextures = false;
	public var lighting = true;
	public var heroSprite = true;

	public function new() {
		#if debug
		#end
	}
}
