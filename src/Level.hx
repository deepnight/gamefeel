class Level extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;

	public var wid(get,never) : Int; inline function get_wid() return data.getLayerByName("collisions").cWid;
	public var hei(get,never) : Int; inline function get_hei() return data.getLayerByName("collisions").cHei;

	var invalidated = true;
	var project : ogmo.Project;
	var data : ogmo.Level;

	var collMap : Map<Int,Bool> = new Map();

	public function new() {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);
		project = new ogmo.Project(hxd.Res.map.feel, false);
		data = project.getLevelByName("level");

		var l = data.getLayerByName("collisions");
		for(cy in 0...l.cHei)
		for(cx in 0...l.cWid) {
			if( l.getIntGrid(cx,cy)==1 )
				setCollision(cx,cy,true);
		}
	}

	public inline function isValid(cx,cy) return cx>=0 && cx<wid && cy>=0 && cy<hei;
	public inline function coordId(cx,cy) return cx + cy*wid;

	public inline function setCollision(cx,cy,v) {
		if( isValid(cx,cy) )
			if( v )
				collMap.set( coordId(cx,cy), true );
			else
				collMap.remove( coordId(cx,cy) );
	}

	public inline function hasCollision(cx,cy) {
		return isValid(cx,cy) ? collMap.get(coordId(cx,cy))==true : true;
	}


	public function render() {
		// Debug level render
		root.removeChildren();
		for(cx in 0...wid)
		for(cy in 0...hei) {
			if( !hasCollision(cx,cy) )
				continue;
			var g = new h2d.Graphics(root);
			g.beginFill(Color.randomColor(rnd(0,1), 0.5, 0.4), 1);
			g.drawRect(cx*Const.GRID, cy*Const.GRID, Const.GRID, Const.GRID);
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