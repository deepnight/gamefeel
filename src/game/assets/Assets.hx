package assets;

import dn.heaps.slib.*;

/**
	This class centralizes all assets management (ie. art, sounds, fonts etc.)
**/
class Assets {
	// Fonts
	public static var fontPixel : h2d.Font;
	public static var fontPixelMono : h2d.Font;

	/** Main atlas **/
	public static var hero : SpriteLib;
	public static var tiles : SpriteLib;

	public static var worldData : World;


	static var _initDone = false;
	public static function init() {
		if( _initDone )
			return;
		_initDone = true;

		// Fonts
		fontPixel = new hxd.res.BitmapFont( hxd.Res.fonts.pixel_unicode_regular_12_xml.entry ).toFont();
		fontPixelMono = new hxd.res.BitmapFont( hxd.Res.fonts.pixica_mono_regular_16_xml.entry ).toFont();

		// build sprite atlas directly from Aseprite file
		hero = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.hero.toAseprite());
		tiles = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.tiles.toAseprite());

		// LDtk init & parsing
		worldData = new World();

		// LDtk file hot-reloading
		#if debug
		var res = try hxd.Res.load(worldData.projectFilePath.substr(4)) catch(_) null; // assume the LDtk file is in "res/" subfolder
		if( res!=null )
			res.watch( ()->{
				// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
				App.ME.delayer.cancelById("ldtk");
				App.ME.delayer.addS("ldtk", function() {
					worldData.parseJson( res.entry.getText() );
					if( Game.exists() )
						Game.ME.onLdtkReload();
				}, 0.2);
			});
		#end
	}


	/**
		Pass `tmod` value from the game to atlases, to allow them to play animations at the same speed as the Game.
		For example, if the game has some slow-mo running, all atlas anims should also play in slow-mo
	**/
	public static function update(tmod:Float) {
		if( Game.exists() && Game.ME.isPaused() )
			tmod = 0;

		hero.tmod = tmod;
		tiles.tmod = tmod;
		// <-- add other atlas TMOD updates here
	}

}