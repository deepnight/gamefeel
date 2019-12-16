import dn.heaps.slib.*;

class Assets {
	public static var fontSmall : h2d.Font;
	public static var fontMedium : h2d.Font;
	public static var fontLarge : h2d.Font;
	public static var tiles : SpriteLib;

	static var initDone = false;
	public static function init() {
		if( initDone )
			return;
		initDone = true;

		fontSmall = hxd.Res.fonts.barlow_condensed_regular_12.toFont();
		fontMedium = hxd.Res.fonts.barlow_condensed_regular_17.toFont();
		fontLarge = hxd.Res.fonts.barlow_condensed_regular_32.toFont();
		tiles = dn.heaps.assets.Atlas.load("atlas/tiles.atlas");
	}
}