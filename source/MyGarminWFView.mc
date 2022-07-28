import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;
import Toybox.System;
import Toybox.Weather;
import Toybox.ActivityMonitor;

class MyGarminWFView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {

        //Fonts
        var IconsolasSmall = WatchUi.loadResource(Rez.Fonts.IconsolasSmall);
        var IconsolasBlack = WatchUi.loadResource(Rez.Fonts.IconsolasBlack);
        var IconsolasMedium = WatchUi.loadResource(Rez.Fonts.IconsolasMedium);
        var IconsolasRotate = WatchUi.loadResource(Rez.Fonts.IconsolasRotate);
        var Icons = WatchUi.loadResource(Rez.Fonts.Icons);

        // Set the background color then call to clear the screen
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK as Number);
        dc.clear();

        // Get the current time and format it correctly
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (getApp().getProperty("UseMilitaryFormat")) {
                timeFormat = "$1$$2$";
                hours = hours.format("%02d");
            }
        }
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);

        // Get the current time and format it correctly
        var today = Gregorian.info(Time.now(), Time.FORMAT_LONG);
        var dateString = Lang.format("$1$ $2$", [today.day_of_week, today.day]);                
        
        // Get and show the weather in day
        var weather = Weather.getCurrentConditions();
        var temperatureString = weather.temperature.format("%d")+"°";
        var precipitationString = weather.precipitationChance.format("%d")+"%";

        // Calcul Initial position
        var widthScreen = dc.getWidth();
        var heightScreen = dc.getHeight();
        var height = 20;
        var width = widthScreen-(20+4)*2-30*2;
        var radius = 2;
        var x = 30;
        var y = (heightScreen/2) - height - 2;        

        // Hours
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(widthScreen/2,30,IconsolasBlack,timeString,Graphics.TEXT_JUSTIFY_CENTER);

        // Horizontal datafields (x3)
        for(var i=1; i<=3; i++){
            var valueCurrentMax = getDataFieldDatas(getApp().getProperty("Jauge"+i+"DataField")) as Array<Float>;
            var result = valueCurrentMax[1].toFloat() <= valueCurrentMax[2].toFloat() ? valueCurrentMax[1].toFloat()/valueCurrentMax[2].toFloat() : 1.00;           
            dc.setColor(getApp().getProperty("Jauge"+i+"BackgroundColor"), Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(x-1,y-1,width+2, height+2,radius);
            dc.setColor(getApp().getProperty("Jauge"+i+"ForegroundColor"), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x,y,width*result,height);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x+4,y,Icons,getApp().getProperty("Jauge"+i+"DataField"),Graphics.TEXT_JUSTIFY_LEFT);
            dc.drawText(x+4+16+2,y,IconsolasSmall,valueCurrentMax[1].toString(),Graphics.TEXT_JUSTIFY_LEFT);
            y += height+4;
        }

        // Vertical datafields (x2)
        x += width+4;
        y = (heightScreen/2) - height - 2;
        width = height;
        height = (height*3)+4+4;
        for(var i=4; i<=5; i++){
            var valueCurrentMax = getDataFieldDatas(getApp().getProperty("Jauge"+i+"DataField")) as Array<Float>;
            var result = valueCurrentMax[1].toFloat() <= valueCurrentMax[2].toFloat() ? valueCurrentMax[1].toFloat()/valueCurrentMax[2].toFloat() : 1.00;  
            dc.setColor(getApp().getProperty("Jauge"+i+"BackgroundColor"), Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(x-1,y-1,width+2,height+2,radius);
            dc.setColor(getApp().getProperty("Jauge"+i+"ForegroundColor"), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x,y,width,height);
            dc.setColor(getApp().getProperty("Jauge"+i+"BackgroundColor"), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x,y,width,height*(1-result));
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            var y2 = y + height - 4 -4;
            dc.drawText(x+2,y2-16,Icons,getApp().getProperty("Jauge"+i+"DataField"),Graphics.TEXT_JUSTIFY_LEFT);
            y2 = y2 - 16-8;
            for( var j = 0; j < (valueCurrentMax[1].toString()).length(); j++ ) {
                y2 -= 7;
                var char = (valueCurrentMax[1].toString()).substring(j,j+1);
                dc.drawText(x+5, y2, IconsolasRotate, char, Graphics.TEXT_JUSTIFY_LEFT);
            }
            x += width+4;
        }

        // Date
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(widthScreen/2,y+height+10,IconsolasMedium,dateString,Graphics.TEXT_JUSTIFY_CENTER);

    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    // Get data field datas
    function getDataFieldDatas(dataField) {
        var datas = {};
        var monitoring = ActivityMonitor.getInfo();
        switch (dataField) {
            case 1 : //Battery
                var battery = System.getSystemStats();
                var batteryString = battery.battery.format("%d").toNumber();
                datas[1] = batteryString;
                datas[2] = 100;
                break;
            case 2 : //Steps
                var stepsString = monitoring.steps;
                var stepsGoalString = monitoring.stepGoal;
                stepsString = 2500; //for test
                datas[1] = stepsString;
                datas[2] = stepsGoalString;
                break;
            case 3 : //Active Minutes (Weekly)
                var activeMinutesString = monitoring.activeMinutesWeek.total;
                var activeMinutesGoalString = monitoring.activeMinutesWeekGoal;
                activeMinutesString = 100;
                datas[1] = activeMinutesString;
                datas[2] = activeMinutesGoalString;
                break;
            case 4 : //Floors Climbed
                var floorsClimbedString = monitoring.floorsClimbed;
                var floorsClimbedGoalString = monitoring.floorsClimbedGoal;
                floorsClimbedString = 7;
                datas[1] = floorsClimbedString;
                datas[2] = floorsClimbedGoalString;
                break;
            case 5 : //Calories                
                var caloriesString = monitoring.calories;
                var caloriesGoalString = getApp().getProperty("CaloriesGoal");
                caloriesString = 1000;
                datas[1] = caloriesString;
                datas[2] = caloriesGoalString;
                break;
            default :
                datas[1] = 0;
                datas[2] = 0;
                break;
        }
        return datas;
    }

}
