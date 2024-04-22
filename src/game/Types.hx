/**	This abstract enum is used by the Controller class to bind general game actions to actual keyboard keys or gamepad buttons. **/
enum abstract GameAction(Int) to Int {
	var A_MoveLeft;
	var A_MoveRight;
	var A_MoveUp;
	var A_MoveDown;

	var A_Dash;
	var A_Shoot;
	var A_Jump;
	var A_Restart;

	var A_MenuLeft;
	var A_MenuRight;
	var A_MenuUp;
	var A_MenuDown;
	var A_MenuOk;
	var A_MenuCancel;

	var A_Options;
	var A_Pause;

	var A_OpenConsoleFlags;
	var A_ToggleDebugDrone;
	var A_DebugDroneZoomIn;
	var A_DebugDroneZoomOut;
	var A_DebugTurbo;
	var A_DebugSlowMo;
	var A_ScreenshotMode;
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
	var M_SmallStep;
	var M_Cliff;
}

enum abstract LevelSubMark(Int) to Int {
	var SM_None; // 0
	var SM_Left;
	var SM_Right;
}

enum abstract SlowMoId(Int) to Int {
	var S_Default; // 0
	var S_Dash;
}

enum abstract ChargedActionId(Int) to Int {
	var CA_Unknown;
	var CA_Shoot;
	var CA_PrepareGun;
}