import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.Math;
import Toybox.WatchUi;

class ChoiceWatchView extends WatchUi.WatchFace {

    var isAwake as Boolean = true;
    var backgroundBitmap;
    var minHandBitmap;
    var hourHandBitmap;
    var secHandBitmap;
    var textBuffer = null;
    var sunriseMarkerBitmap;
    var sunsetMarkerBitmap;
    var loadedTheme = -1;
    var themeTextColor = Graphics.COLOR_WHITE;
    var themeDashedColor = Graphics.COLOR_DK_GRAY;
    var themeProgressColor = Graphics.COLOR_WHITE;
    var themeRadialTextColor = Graphics.COLOR_BLACK;

    function initialize() {
        WatchFace.initialize();
    }

    function loadThemeResources() {
        var theme = Application.Properties.getValue("Theme");
        if (theme == loadedTheme) {
            return;
        }
        loadedTheme = theme;

        if (theme == 1) {
            backgroundBitmap = Application.loadResource(Rez.Drawables.BgIvoryRed);
            minHandBitmap = Application.loadResource(Rez.Drawables.MinuteHandIvoryRed);
            hourHandBitmap = Application.loadResource(Rez.Drawables.HourHandIvoryRed);
            themeTextColor = 0x66001F;
            themeDashedColor = 0xCCCCCC; // Light Grey for empty circles on Ivory
            themeProgressColor = 0x66001F; // Burgundy for progress
            themeRadialTextColor = 0xFFFCEF; // Cream on Burgundy ring
        } else if (theme == 2) {
            backgroundBitmap = Application.loadResource(Rez.Drawables.BgCyberpunk);
            minHandBitmap = Application.loadResource(Rez.Drawables.MinuteHandCyberpunk);
            hourHandBitmap = Application.loadResource(Rez.Drawables.HourHandCyberpunk);
            themeTextColor = 0x00F5FF;
            themeDashedColor = 0x1C1C1C;
            themeProgressColor = 0x00F5FF;
            themeRadialTextColor = 0x00F5FF;
        } else if (theme == 3) {
            backgroundBitmap = Application.loadResource(Rez.Drawables.BgTacticalOrange);
            minHandBitmap = Application.loadResource(Rez.Drawables.MinuteHandTacticalOrange);
            hourHandBitmap = Application.loadResource(Rez.Drawables.HourHandTacticalOrange);
            themeTextColor = 0xE0E0E0;
            themeDashedColor = 0x333333;
            themeProgressColor = 0xFF6F00;
            themeRadialTextColor = 0xFF6F00;
        } else if (theme == 4) {
            backgroundBitmap = Application.loadResource(Rez.Drawables.BgVintageNavy);
            minHandBitmap = Application.loadResource(Rez.Drawables.MinuteHandVintageNavy);
            hourHandBitmap = Application.loadResource(Rez.Drawables.HourHandVintageNavy);
            themeTextColor = 0xFFFCEF;
            themeDashedColor = 0x102A43; // Dark Navy for empty circles
            themeProgressColor = 0xFFFCEF; // Cream for progress
            themeRadialTextColor = 0x1B2A47; // Dark Navy on Cream ring
        } else if (theme == 5) {
            backgroundBitmap = Application.loadResource(Rez.Drawables.BgBlackRedIvory);
            minHandBitmap = Application.loadResource(Rez.Drawables.MinuteHandBlackRedIvory);
            hourHandBitmap = Application.loadResource(Rez.Drawables.HourHandBlackRedIvory);
            themeTextColor = 0xFFFFF0;
            themeDashedColor = 0x333333;
            themeProgressColor = 0x66001F;
            themeRadialTextColor = 0xFFFCEF;
        } else if (theme == 6) {
            backgroundBitmap = Application.loadResource(Rez.Drawables.BgRedIvory);
            minHandBitmap = Application.loadResource(Rez.Drawables.MinuteHandRedIvory);
            hourHandBitmap = Application.loadResource(Rez.Drawables.HourHandRedIvory);
            themeTextColor = 0xFFFFF0;
            themeDashedColor = 0x882B52; // Dim Burgundy
            themeProgressColor = 0xFFFCEF;
            themeRadialTextColor = 0x66001F; // Burgundy on Cream ring
        } else {
            backgroundBitmap = Application.loadResource(Rez.Drawables.BackgroundSVG);
            minHandBitmap = Application.loadResource(Rez.Drawables.MinuteHand);
            hourHandBitmap = Application.loadResource(Rez.Drawables.HourHand);
            themeTextColor = Graphics.COLOR_WHITE;
            themeDashedColor = Graphics.COLOR_DK_GRAY;
            themeProgressColor = Graphics.COLOR_WHITE;
            themeRadialTextColor = Graphics.COLOR_BLACK;
        }
    }

    // Load your resources here
    function onLayout(dc as Graphics.Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        loadThemeResources();
        secHandBitmap = Application.loadResource(Rez.Drawables.SecondHand);
        sunriseMarkerBitmap = Application.loadResource(Rez.Drawables.SunriseMarker);
        sunsetMarkerBitmap = Application.loadResource(Rez.Drawables.SunsetMarker);
    }

    // Called when this View is brought to the foreground
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Graphics.Dc) as Void {
        loadThemeResources();
        // Get and format the current date
        var now = Time.now();
        var dateInfo = Gregorian.info(now, Time.FORMAT_SHORT);
        var dateString = Lang.format("$1$/$2$/$3$", [dateInfo.month, dateInfo.day, dateInfo.year]);
        var dateView = View.findDrawableById("DateLabel") as WatchUi.Text;
        dateView.setText(dateString);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Enable anti-aliasing to smooth out the jagged/pixelated lines
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        // Draw our perfect vector background!
        if (backgroundBitmap != null) {
            dc.drawBitmap(0, 0, backgroundBitmap);
        }

        // Draw Analog Watch Elements
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;
        var cy = height / 2;
        var radius = cx < cy ? cx : cy;

        // --- FETCH EXTRA DATA ---
        var hrInfo = Activity.getActivityInfo();
        var activityInfo = ActivityMonitor.getInfo();
        var hrStr = "--";
        var hrPercent = 0.0;
        var currentHR = null;

        if (hrInfo != null && hrInfo.currentHeartRate != null) {
            currentHR = hrInfo.currentHeartRate;
        } else if (Toybox has :SensorHistory && Toybox.SensorHistory has :getHeartRateHistory) {
            var hrIter = Toybox.SensorHistory.getHeartRateHistory({:period => 1, :order => Toybox.SensorHistory.ORDER_NEWEST_FIRST});
            var sample = hrIter.next();
            if (sample != null && sample.data != null) {
                currentHR = sample.data;
            }
        }

        if (currentHR != null) {
            hrStr = currentHR.format("%d");
            hrPercent = currentHR.toFloat() / 185.0; // Assume max HR 185
            if (hrPercent > 1.0) { hrPercent = 1.0; }
        }

        var activeMinPercent = 0.0;
        if (activityInfo != null && activityInfo.activeMinutesWeek != null && activityInfo.activeMinutesWeek.total != null && activityInfo.activeMinutesWeekGoal != null && activityInfo.activeMinutesWeekGoal > 0) {
            activeMinPercent = activityInfo.activeMinutesWeek.total.toFloat() / activityInfo.activeMinutesWeekGoal;
            if (activeMinPercent > 1.0) { activeMinPercent = 1.0; }
        }

        var tempStr = "--°";
        if (Toybox has :Weather) {
            var conditions = Toybox.Weather.getCurrentConditions();
            if (conditions != null) {
                if (conditions.temperature != null) {
                    var condStr = "";
                    if (conditions.condition != null) {
                        condStr = " " + getWeatherConditionString(conditions.condition);
                    }
                    tempStr = conditions.temperature.format("%d") + "°" + condStr;
                }

                // Sunrise/Sunset Dot
                var sunrise = null;
                var sunset = null;

                var location = conditions.observationLocationPosition;
                if (location == null && Toybox has :Position) {
                    var posInfo = Toybox.Position.getInfo();
                    if (posInfo != null) {
                        location = posInfo.position;
                    }
                }

                if (location != null) {
                    sunrise = Toybox.Weather.getSunrise(location, now);
                    sunset = Toybox.Weather.getSunset(location, now);
                }

                var nextEvent = null;
                var isSunrise = false;

                if (sunrise != null && sunset != null) {
                    if (sunrise.greaterThan(now)) {
                        nextEvent = sunrise;
                        isSunrise = true;
                    } else if (sunset.greaterThan(now)) {
                        nextEvent = sunset;
                        isSunrise = false;
                    } else {
                        // Both in the past! Show tomorrow's sunrise (approx by adding 1 day)
                        nextEvent = sunrise.add(new Toybox.Time.Duration(86400));
                        isSunrise = true;
                    }
                }

                var hour = 7;
                var min = 0;

                if (nextEvent != null) {
                    var info = Gregorian.info(nextEvent, Time.FORMAT_SHORT);
                    hour = info.hour % 12;
                    min = info.min;
                } else {
                    isSunrise = true;
                }

                var angleDeg = (hour * 30.0) + (min * 0.5);
                var angleRad = angleDeg * Math.PI / 180.0;

                if (isSunrise) {
                    drawRotatedHand(dc, sunriseMarkerBitmap, cx, cy, angleRad, 12, 208);
                } else {
                    drawRotatedHand(dc, sunsetMarkerBitmap, cx, cy, angleRad, 12, 208);
                }
            }
        }

        var actCal = activityInfo != null && activityInfo.calories != null ? activityInfo.calories : 0;
        var calStr = "ACTIVE CAL " + actCal;

        // --- DRAW CIRCULAR GAUGES ---
        var battery = System.getSystemStats().battery;
        var steps = activityInfo != null && activityInfo.steps != null ? activityInfo.steps : 0;
        var stepGoal = activityInfo != null && activityInfo.stepGoal != null ? activityInfo.stepGoal : 5000;
        if (stepGoal == 0) { stepGoal = 5000; }

        var stepPercent = steps.toFloat() / stepGoal;
        if (stepPercent > 1.0) { stepPercent = 1.0; }

        var batteryPercent = battery / 100.0;
        if (batteryPercent > 1.0) { batteryPercent = 1.0; }

        // Sub-dial Math (Percentages based on the new SVG layout: dist 60, radius 36)
        var dialRadius = (radius * (36.0 / 208.0)).toNumber();
        var dialOffset = (radius * (60.0 / 208.0)).toNumber();
        dc.setPenWidth(8);

        // Bottom Sub-dial (Steps)
        drawSubDialArc(dc, cx, cy + dialOffset, dialRadius, stepPercent, themeProgressColor);

        var bodyBattery = 0;
        if (Toybox has :SensorHistory && Toybox.SensorHistory has :getBodyBatteryHistory) {
            var bbIter = Toybox.SensorHistory.getBodyBatteryHistory({:period => 1, :order => Toybox.SensorHistory.ORDER_NEWEST_FIRST});
            var bbSample = bbIter.next();
            if (bbSample != null && bbSample.data != null) {
                bodyBattery = bbSample.data;
            }
        }
        var bodyBatteryPercent = bodyBattery.toFloat() / 100.0;
        if (bodyBatteryPercent > 1.0) { bodyBatteryPercent = 1.0; }

        // Left Sub-dial (Body Battery Arc)
        drawSubDialArc(dc, cx - dialOffset, cy, dialRadius, bodyBatteryPercent, themeProgressColor);

        // --- SUB-DIAL INNER TEXT ---
        dc.setColor(themeTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - dialOffset, cy + 8, Graphics.FONT_XTINY, bodyBattery.format("%d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Bottom Sub-dial (Steps)
        dc.drawText(cx, cy + dialOffset + 8, Graphics.FONT_XTINY, steps.toString(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // --- NEW TOP AREA (Heart Rate Icon & Number) ---
        dc.setColor(themeTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - dialOffset + 5, Graphics.FONT_XTINY, hrStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // --- NEW RIGHT AREA (Date) ---
        var nowShort = Toybox.Time.Gregorian.info(Toybox.Time.now(), Toybox.Time.FORMAT_SHORT);
        var nowMed = Toybox.Time.Gregorian.info(Toybox.Time.now(), Toybox.Time.FORMAT_MEDIUM);

        var monthStr = nowMed.month.toUpper();
        var dayStr = nowShort.day.format("%d");
        var dowStr = nowMed.day_of_week.toUpper();

        // DOW in theme color
        dc.setColor(themeTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + dialOffset, cy - 12, Graphics.FONT_XTINY, dowStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Month and Day in theme color
        dc.drawText(cx + dialOffset, cy + 8, Graphics.FONT_XTINY, monthStr + " " + dayStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // --- DRAW TEXT FIELDS ---
        if (textBuffer == null) {
            if (Graphics has :createBufferedBitmap) {
                try {
                    textBuffer = Graphics.createBufferedBitmap({ :width => 80, :height => 40 });
                } catch (e) {
                    textBuffer = null;
                }
            } else if (Graphics has :BufferedBitmap) {
                try {
                    textBuffer = new Graphics.BufferedBitmap({ :width => 80, :height => 40 });
                } catch (e) {
                    textBuffer = null;
                }
            }
        }

        // Top-Left Text (Battery in Days) - perfectly rotated on the grey ring (angle: 225 deg)
        var stats = System.getSystemStats();
        var batStr = "BATTERY ";
        if (stats has :batteryInDays && stats.batteryInDays != null && stats.batteryInDays > 0) {
            var days = stats.batteryInDays;
            if (days < 1.0) {
                batStr += (days * 24.0).format("%.0f") + " HRS";
            } else {
                batStr += days.format("%.0f") + " DAYS";
            }
        } else {
            batStr += battery.toNumber() + "%";
        }
        drawRadialTextBitmap(dc, batStr, cx, cy, 135, Math.PI * 1.25);

        // Top-Right Text (Temperature & Weather) - perfectly rotated on the grey ring (angle: 315 deg)
        drawRadialTextBitmap(dc, tempStr, cx, cy, 135, Math.PI * 1.75);

        // Bottom-Center Text (Calories) - perfectly rotated on the grey ring (angle: 90 deg)
        drawRadialTextBitmap(dc, calStr, cx, cy, 135, Math.PI * 0.5);

        // Get current time again to draw hands
        var clockTime = System.getClockTime();

        // 0 radians is straight up (12 o'clock) for our SVGs!
        var hourAngle = (((clockTime.hour % 12) * 60.0 + clockTime.min) / 720.0) * Math.PI * 2;
        var minAngle = (clockTime.min / 60.0) * Math.PI * 2;

        // Draw Hands using AffineTransform
        // We pass the exact pixel coordinates of the "pivot" point for each hand
        drawRotatedHand(dc, hourHandBitmap, cx, cy, hourAngle, 12, 150);
        drawRotatedHand(dc, minHandBitmap, cx, cy, minAngle, 10, 190);

        // Draw Second Hand (Only when the watch is awake)
        if (isAwake) {
            var secAngle = (clockTime.sec / 60.0) * Math.PI * 2;
            drawRotatedHand(dc, secHandBitmap, cx, cy, secAngle, 6, 190);
        }

        // Draw a neat center cap covering where the hands meet
        dc.setColor(themeTextColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, cy, 6);
        dc.setColor(themeDashedColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, cy, 3);
    }

    // Helper function to draw a vector bitmap rotated perfectly around a pivot point
    function drawRotatedHand(dc as Graphics.Dc, bitmap, cx as Number, cy as Number, angle as Float, pivotX as Number, pivotY as Number) as Void {
        if (dc has :drawBitmap2) {
            // 1. Move the image so its pivot point is at (0,0)
            var transform = new Graphics.AffineTransform();
            transform.setToTranslation(-pivotX.toFloat(), -pivotY.toFloat());

            // 2. Rotate it around the new (0,0) origin
            var rotTransform = new Graphics.AffineTransform();
            rotTransform.setToRotation(angle);

            // Apply the rotation TO the translation
            rotTransform.concatenate(transform);

            // 3. Draw it, using drawBitmap2's built-in translation to move the (0,0) origin to (cx,cy)
            dc.drawBitmap2(cx, cy, bitmap, { :transform => rotTransform, :filterMode => Graphics.FILTER_MODE_BILINEAR });
        }
    }

    // Helper to draw text radially along a circle using a buffer (True Character-by-Character Curving)
    function drawRadialTextBitmap(dc as Graphics.Dc, text as String, cx as Number, cy as Number, radius as Number, angleRad as Float) as Void {
        if (textBuffer != null && dc has :drawBitmap2) {
            var actualBuffer = textBuffer;
            if (textBuffer has :get) {
                actualBuffer = textBuffer.get();
            }

            if (actualBuffer == null) { return; } // Buffer was purged

            var tdc = actualBuffer.getDc();

            var totalAngleSpan = 0;

            for (var i = 0; i < text.length(); i++) {
                var charStr = text.substring(i, i + 1);
                var charWidth = dc.getTextWidthInPixels(charStr, Graphics.FONT_XTINY);
                totalAngleSpan += charWidth.toFloat() / radius;
            }

            var isBottomHalf = (angleRad > 0 && angleRad < Math.PI);
            var currentAngle = 0.0;

            if (isBottomHalf) {
                currentAngle = angleRad + (totalAngleSpan / 2.0);
            } else {
                currentAngle = angleRad - (totalAngleSpan / 2.0);
            }

            for (var i = 0; i < text.length(); i++) {
                var charStr = text.substring(i, i + 1);
                var charAngleSpan = dc.getTextWidthInPixels(charStr, Graphics.FONT_XTINY).toFloat() / radius;

                var charAngle = currentAngle;
                if (isBottomHalf) {
                    charAngle -= (charAngleSpan / 2.0);
                } else {
                    charAngle += (charAngleSpan / 2.0);
                }

                tdc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
                tdc.clear();
                tdc.setColor(themeRadialTextColor, Graphics.COLOR_TRANSPARENT);
                tdc.drawText(40, 20, Graphics.FONT_XTINY, charStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

                var tx = cx + radius * Math.cos(charAngle);
                var ty = cy + radius * Math.sin(charAngle);

                // Calculate rotation so text wraps along the circle.
                // A tangent line to the circle has angle (charAngle + PI/2)
                var rotAngle = charAngle + (Math.PI / 2.0);
                if (isBottomHalf) {
                    rotAngle += Math.PI;
                }

                drawRotatedHand(dc, actualBuffer, tx.toNumber(), ty.toNumber(), rotAngle, 40, 20);

                if (isBottomHalf) {
                    currentAngle -= charAngleSpan;
                } else {
                    currentAngle += charAngleSpan;
                }
            }
        } else {
            // Fallback
            var tx = cx + radius * Math.cos(angleRad);
            var ty = cy + radius * Math.sin(angleRad);
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.drawText(tx, ty, Graphics.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // Helper to get simple weather condition string
    function getWeatherConditionString(condition) {
        if (condition == null) { return ""; }
        switch(condition) {
            case 0: return "CLEAR";
            case 1: return "P. CLOUD";
            case 2: return "M. CLOUD";
            case 3: return "RAIN";
            case 4: return "SNOW";
            case 6: return "STORM";
            case 11: return "SHOWER";
            case 14: return "L. RAIN";
            case 20: return "CLOUDY";
            default: return "CLOUDS";
        }
    }

    // Helper to draw a progress arc
    function drawSubDialArc(dc as Graphics.Dc, cx as Number, cy as Number, radius as Number, percent as Float, color as Number) as Void {
        var dashDegrees = 6.0;
        var gapDegrees = 6.0;
        var totalPeriod = dashDegrees + gapDegrees;

        // 1. Draw the grey background dashes (Full Circle)
        dc.setColor(themeDashedColor, Graphics.COLOR_TRANSPARENT);
        var currentDegree = 90.0;
        for (var i = 0; i < 30; i++) { // 360 / 12 = 30
            var nextDegree = currentDegree - dashDegrees;
            dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, currentDegree, nextDegree);
            currentDegree -= totalPeriod;
        }

        // 2. Draw the colored progress dashes
        if (percent > 0) {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);

            var totalDegrees = percent * 360.0;
            currentDegree = 90.0; // Start at top
            var drawnDegrees = 0.0;

            while (drawnDegrees < totalDegrees) {
                var nextDegree = currentDegree - dashDegrees;

                // If the remaining percent is less than a full dash, truncate it
                if (drawnDegrees + dashDegrees > totalDegrees) {
                    var partialDash = totalDegrees - drawnDegrees;
                    nextDegree = currentDegree - partialDash;
                }

                dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, currentDegree, nextDegree);

                drawnDegrees += totalPeriod;
                currentDegree -= totalPeriod;
            }
        }
    }

    // Called when this View is removed from the screen
    function onHide() as Void {
    }

    function onExitSleep() as Void {
        isAwake = true;
    }

    function onEnterSleep() as Void {
        isAwake = false;
        WatchUi.requestUpdate(); // Force one last update to erase the second hand
    }
}