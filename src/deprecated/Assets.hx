import dn.heaps.slib.*;

class Assets {
	public static var fontSmall : h2d.Font;
	public static var fontMedium : h2d.Font;
	public static var fontLarge : h2d.Font;
	public static var tiles : SpriteLib;
	public static var SBANK = dn.heaps.assets.SfxDirectory.load("sfx");

	static var initDone = false;
	public static function init() {
		if( initDone )
			return;
		initDone = true;

		fontSmall = hxd.Res.fonts.barlow_condensed_regular_12.toFont();
		fontMedium = hxd.Res.fonts.barlow_condensed_regular_17.toFont();
		fontLarge = hxd.Res.fonts.barlow_condensed_regular_32.toFont();

		tiles = dn.heaps.assets.Atlas.load("atlas/tiles.atlas");
		tiles.defineAnim("mechRun", "0(6), 1(2), 2(6), 1(2)");
		tiles.defineAnim("mechRunWeapon", "0(6), 1(2), 2(6), 1(2)");
		tiles.defineAnim("mechIdle", "0(5), 1(10), 0(15), 1(10), 3(20), 2(4), 1(10)");
		tiles.defineAnim("mechShootLoad", "7(9999)");
		tiles.defineAnim("mechLand", "0(3), 1, 2(9999)");
		tiles.defineAnim("mechShoot", "0(2), 1-2");
	}
}