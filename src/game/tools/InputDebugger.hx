package tools;

class InputDebugger {
    private var ca:Dynamic;
    private var entity:Entity;
    private var wasPressed:Map<GameAction, Bool> = [
        A_Shoot => false,
        A_Jump => false
    ];

    /**
     * Constructor to initialize InputDebugger with references to ControllerAccess and an Entity.
     * 
     * @param ca A reference to ControllerAccess.
     * @param entity The Entity instance for accessing fx, game, and debugging visuals (e.g. popText).
     */
    public function new(ca:Dynamic, entity:Entity) {
        this.ca = ca;
        this.entity = entity;
    }

    /**
     * Logs the initial press of an action or mouse input.
     * 
     * @param a The game action to check.
     * @param label The label to display for debug logging.
     * @param col The color for debug visualization.
     */
    public function logPress(a:GameAction, label:String, col:Col) {
        var isPressed = ca.isPressed(a);

        // add specific mouse checks for certain actions
        switch (a) {
            case A_Shoot:
                isPressed = isPressed || entity.game.isMouseDown(MB_Left);
            case A_Jump:
                isPressed = isPressed || entity.game.isMouseDown(MB_Right);
            default:
                // no additional mouse checks for other actions
        }

        // log initial press only (otherwise mouseDown will persist across frames)
        if (isPressed && !wasPressed[a]) {
            debugLog(label, col);
        }
        wasPressed[a] = isPressed;
    }

    /**
     * Logs the debug output for the given action.
     * 
     * @param label The label to display.
     * @param col The color for visualization.
     */
    private function debugLog(label:String, col:Col) {
        entity.fx.markerEntity(entity, col, 0.1);
        entity.popText(label, col);
    }
}
