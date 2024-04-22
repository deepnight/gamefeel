/**	This abstract enum is used by the Controller class to bind general game actions to actual keyboard keys or gamepad buttons. **/
enum abstract GameAction(Int) to Int {
	var GA_MoveLeft;
	var GA_MoveRight;
	var GA_MoveUp;
	var GA_MoveDown;

	var GA_Dash;
	var GA_Shoot;
	var GA_Jump;
	var GA_Restart;

	var GA_MenuLeft;
	var GA_MenuRight;
	var GA_MenuUp;
	var GA_MenuDown;
	var GA_MenuOk;
	var GA_MenuCancel;

	var GA_Pause;

	var GA_OpenConsoleFlags;
	var GA_ToggleDebugDrone;
	var GA_DebugDroneZoomIn;
	var GA_DebugDroneZoomOut;
	var GA_DebugTurbo;
	var GA_DebugSlowMo;
	var GA_ScreenshotMode;
}

/** Entity state machine. Each entity can only have 1 active State at a time. **/
enum abstract State(Int) {
	var Normal;
}


/** Entity Affects have a limited duration in time and you can stack different affects. **/
enum abstract Affect(Int) {
	var Stun;
}

enum abstract LevelMark(Int) to Int {
	var M_Coll_Wall; // 0
}

enum abstract LevelSubMark(Int) to Int {
	var SM_None; // 0
}

enum abstract SlowMoId(Int) to Int {
	var S_Default; // 0
}

enum abstract ChargedActionId(Int) to Int {
	var CA_Unknown;
	var CA_Shoot;
}