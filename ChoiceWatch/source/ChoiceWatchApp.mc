import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class ChoiceWatchApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        return [ new ChoiceWatchView() ];
    }

    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }

    // Return the settings view and delegate
    function getSettingsView() {
        return [ new SettingsMenu(), new SettingsDelegate() ];
    }
}

class SettingsMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title=>"Select Theme"});
        addItem(new WatchUi.MenuItem("Default (Original)", null, 0, null));
        addItem(new WatchUi.MenuItem("Ivory Red", null, 1, null));
        addItem(new WatchUi.MenuItem("Cyberpunk", null, 2, null));
        addItem(new WatchUi.MenuItem("Tactical Orange", null, 3, null));
        addItem(new WatchUi.MenuItem("Vintage Navy", null, 4, null));
        addItem(new WatchUi.MenuItem("Black Red Ivory", null, 5, null));
        addItem(new WatchUi.MenuItem("Red Ivory", null, 6, null));
    }
}

class SettingsDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var id = item.getId();
        Application.Properties.setValue("Theme", id);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}