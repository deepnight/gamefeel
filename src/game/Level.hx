class Level extends GameChildProcess {
	public var options(get,never) : Options; inline function get_options() return App.ME.options;

	/** Level grid-based width**/
	public var cWid(default,null): Int;
	/** Level grid-based height **/
	public var cHei(default,null): Int;

	/** Level pixel width**/
	public var pxWid(default,null) : Int;
	/** Level pixel height**/
	public var pxHei(default,null) : Int;

	public var data : World_Level;
	var tilesetSource : h2d.Tile;

	var wrapper : h2d.Object;
	var debugRender : h2d.Graphics;

	public var marks : dn.MarkerMap<LevelMark>;
	var invalidated = true;

	public function new(ldtkLevel:World.World_Level) {
		super();

		createRootInLayers(Game.ME.scroller, Const.DP_BG);
		wrapper = new h2d.Object(root);
		debugRender = new h2d.Graphics(root);

		data = ldtkLevel;
		cWid = data.l_Collisions.cWid;
		cHei = data.l_Collisions.cHei;
		pxWid = cWid * Const.GRID;
		pxHei = cHei * Const.GRID;
		tilesetSource = hxd.Res.levels.sampleWorldTiles.toAseprite().toTile();

		marks = new dn.MarkerMap(cWid, cHei);
		function _hasColl(cx,cy) {
			return data.l_Collisions.getInt(cx,cy)==1;
		}
		for(cy in 0...cHei)
		for(cx in 0...cWid) {
			if( data.l_Collisions.getInt(cx,cy)==1 )
				marks.set(M_Coll_Wall, cx,cy);

			if( !_hasColl(cx,cy) && _hasColl(cx+1,cy) && !_hasColl(cx+1,cy-1) )
				if( _hasColl(cx,cy+1) )
					marks.setWithBit(M_SmallStep, SM_Right, cx,cy);
				else
					marks.setWithBit(M_Cliff, SM_Right, cx,cy);

			if( !_hasColl(cx,cy) && _hasColl(cx-1,cy) && !_hasColl(cx-1,cy-1) )
				if( _hasColl(cx,cy+1) )
					marks.setWithBit(M_SmallStep, SM_Left, cx,cy);
				else
					marks.setWithBit(M_Cliff, SM_Left, cx,cy);
		}
	}

	public function renderDebugMark(mark:LevelMark, ?subBit:LevelSubMark) {
		debugRender.clear();
		debugRender.beginFill(Pink,0.66);
		for(cx in 0...cWid)
		for(cy in 0...cHei)
			if( subBit!=null && marks.hasWithBit(mark,subBit, cx,cy) || subBit==null && marks.has(mark, cx,cy) )
				debugRender.drawRect(cx*Const.GRID, cy*Const.GRID, Const.GRID, Const.GRID);
	}

	override function onDispose() {
		super.onDispose();
		data = null;
		tilesetSource = null;
		marks.dispose();
		marks = null;
	}

	/** TRUE if given coords are in level bounds **/
	public inline function isValid(cx,cy) return cx>=0 && cx<cWid && cy>=0 && cy<cHei;

	/** Gets the integer ID of a given level grid coord **/
	public inline function coordId(cx,cy) return cx + cy*cWid;

	/** Ask for a level render that will only happen at the end of the current frame. **/
	public inline function invalidate() {
		invalidated = true;
	}

	/** Return TRUE if "Collisions" layer contains a collision value **/
	public inline function hasCollision(cx,cy) : Bool {
		return !isValid(cx,cy) ? true : marks.has(M_Coll_Wall, cx,cy);
	}

	/** Render current level**/
	function render() {
		// Placeholder level render
		wrapper.removeChildren();


		var bg = new h2d.Bitmap(h2d.Tile.fromColor(Const.BG_COLOR), wrapper);
		bg.scaleX = data.pxWid;
		bg.scaleY = data.pxHei;

		if( !options.levelTextures ) {
			// Simple rendering
			var g = new h2d.Graphics(wrapper);
			for(cx in 0...cWid)
			for(cy in 0...cHei)
				if( marks.has(M_Coll_Wall, cx,cy) ) {
					g.beginFill(new Col("#724f2d"));
					g.drawRect(cx*Const.GRID, cy*Const.GRID, Const.GRID, Const.GRID);
				}
		}
		else {
			// Full rendering
			var tg = new h2d.TileGroup(tilesetSource, wrapper);
			data.l_Collisions.render(tg);
		}
	}

	override function postUpdate() {
		super.postUpdate();

		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}