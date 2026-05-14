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
        var view = new ThemeSettingsView();
        return [ view, new ThemeSettingsDelegate(view) ];
    }
}

class ThemeSettingsView extends WatchUi.View {
    var tempTheme;
    var themeNames = ["Default", "Ivory Red", "Cyberpunk", "Tactical Orange", "Vintage Navy", "Black Red Ivory", "Red Ivory", "Ivory Green", "Green Ivory", "Black Green"];
    var watchFaceView;

    function initialize() {
        View.initialize();
        tempTheme = Application.Properties.getValue("Theme");
        if (tempTheme == null) { tempTheme = 0; }
        watchFaceView = new ChoiceWatchView();
    }

    function onLayout(dc) {
        watchFaceView.onLayout(dc);
    }

    function onUpdate(dc) {
        var currentTheme = Application.Properties.getValue("Theme");
        Application.Properties.setValue("Theme", tempTheme);
        
        // Call the watch face view's onUpdate to draw the preview
        watchFaceView.onUpdate(dc);
        
        // Restore the actual saved theme
        Application.Properties.setValue("Theme", currentTheme);
        
        // Draw a banner at the top to show the current selected theme
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, dc.getWidth(), 50);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, 15, Graphics.FONT_XTINY, "<- " + themeNames[tempTheme] + " ->", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(dc.getWidth()/2, 35, Graphics.FONT_XTINY, "Press Up/Down to cycle", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

class ThemeSettingsDelegate extends WatchUi.BehaviorDelegate {
    var view;

    function initialize(v) {
        BehaviorDelegate.initialize();
        view = v;
    }

    function onPreviousPage() {
        view.tempTheme--;
        if (view.tempTheme < 0) { view.tempTheme = 9; }
        WatchUi.requestUpdate();
        return true;
    }

    function onNextPage() {
        view.tempTheme++;
        if (view.tempTheme > 9) { view.tempTheme = 0; }
        WatchUi.requestUpdate();
        return true;
    }

    function onSelect() {
        Application.Properties.setValue("Theme", view.tempTheme);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}