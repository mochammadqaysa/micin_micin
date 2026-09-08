/// State machine states extracted directly from the Sugar Sugar SWF binary.
enum GameState {
  init,
  initAfterLoad,
  initMenu,
  menuLoop,
  initLevelSelect,
  levelSelectLoop,
  initLevel,
  levelLoop,
  siteLocked,
}
