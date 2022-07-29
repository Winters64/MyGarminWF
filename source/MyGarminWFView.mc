using Toybox.Application;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Time.Gregorian;
using Toybox.System;
using Toybox.Weather;
using Toybox.ActivityMonitor;

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
        var height = 28;
        var margin = 4;
        var width = widthScreen-(height+margin)*2-20*2;
        var radius = 2;
        var x = 20;
        var y = (heightScreen/2) - height - margin;        

        // Hours
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(widthScreen/2,20,IconsolasBlack,timeString,Graphics.TEXT_JUSTIFY_CENTER);

        // Horizontal datafields (x3)
        for(var i=1; i<=3; i++){
            var valueCurrentMax = getDataFieldDatas(getApp().getProperty("Jauge"+i+"DataField")) as Array<Float>;
            var result = valueCurrentMax[1].toFloat() <= valueCurrentMax[2].toFloat() ? valueCurrentMax[1].toFloat()/valueCurrentMax[2].toFloat() : 1.00;           
            dc.setColor(getApp().getProperty("Jauge"+i+"BackgroundColor"), Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(x,y,width, height,radius);
            dc.setColor(getApp().getProperty("Jauge"+i+"ForegroundColor"), Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(x,y,width*result,height,radius);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x+4,y+4,Icons,getApp().getProperty("Jauge"+i+"DataField"),Graphics.TEXT_JUSTIFY_LEFT);
            dc.drawText(x+4+20+4,y+1,IconsolasSmall,valueCurrentMax[1].toString(),Graphics.TEXT_JUSTIFY_LEFT);
            y += height+4;
        }

        // Vertical datafields (x2)
        x += width + margin;
        y = (heightScreen/2) - height - margin;
        width = height;
        height = (height*3)+(margin*2);
        for(var i=4; i<=5; i++){
            var valueCurrentMax = getDataFieldDatas(getApp().getProperty("Jauge"+i+"DataField")) as Array<Float>;
            var result = valueCurrentMax[1].toFloat() <= valueCurrentMax[2].toFloat() ? valueCurrentMax[1].toFloat()/valueCurrentMax[2].toFloat() : 1.00;  
            dc.setColor(getApp().getProperty("Jauge"+i+"BackgroundColor"), Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(x,y,width,height,radius);
            dc.setColor(getApp().getProperty("Jauge"+i+"ForegroundColor"), Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(x,y,width,height,radius);
            dc.setColor(getApp().getProperty("Jauge"+i+"BackgroundColor"), Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(x,y,width,height*(1-result),radius);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            var y2 = y + height - margin - margin;
            dc.drawText(x+4,y2-17,Icons,getApp().getProperty("Jauge"+i+"DataField"),Graphics.TEXT_JUSTIFY_LEFT);
            y2 = y2 - 20 - 4;
            for( var j = 0; j < (valueCurrentMax[1].toString()).length(); j++ ) {
                y2 -= 9;
                var char = (valueCurrentMax[1].toString()).substring(j,j+1);
                dc.drawText(x+8, y2, IconsolasRotate, char, Graphics.TEXT_JUSTIFY_LEFT);
            }
            x += width+4;
        }

        // Date + weather
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(widthScreen/2,y+height+10,IconsolasMedium,dateString+" | "+temperatureString,Graphics.TEXT_JUSTIFY_CENTER);

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
                datas[1] = stepsString;
                datas[2] = stepsGoalString;
                break;
            case 3 : //Active Minutes (Weekly)
                var activeMinutesString = monitoring.activeMinutesWeek.total;
                var activeMinutesGoalString = monitoring.activeMinutesWeekGoal;
                datas[1] = activeMinutesString;
                datas[2] = activeMinutesGoalString;
                break;
            case 4 : //Floors Climbed
                var floorsClimbedString = monitoring.floorsClimbed;
                var floorsClimbedGoalString = monitoring.floorsClimbedGoal;
                datas[1] = floorsClimbedString;
                datas[2] = floorsClimbedGoalString;
                break;
            case 5 : //Calories                
                var caloriesString = monitoring.calories;
                var caloriesGoalString = getApp().getProperty("CaloriesGoal");
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
