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

        // Set the background color then call to clear the screen
        dc.setColor(Graphics.COLOR_TRANSPARENT, getApp().getProperty("BackgroundColor") as Number);
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

         // Get and show the battery in day
        var battery = System.getSystemStats();
        var batteryVal = null;
        switch (getApp().getProperty("BatteryRemainingMode")){
            case 1 : 
                batteryVal = battery.battery.format("%d")+"%";
                break;
            case 2 :
                batteryVal = battery.batteryInDays.format("%d")+"D";
                break;
            default:
                batteryVal = "ERROR";
                break;
        }
        var batteryString = batteryVal;        
        
        // Get and show the weather in day
        var weather = Weather.getCurrentConditions();
        var temperatureString = weather.temperature.format("%d")+"°";
        var precipitationString = weather.precipitationChance.format("%d")+"%";

        // Get and show monitoring infos
        var monitoring = ActivityMonitor.getInfo();
        var stepsString = monitoring.steps;
        var stepsGoalString = monitoring.stepGoal;
        var activeMinutesString = monitoring.activeMinutesWeek.total;
        var activeMinutesGoalString = monitoring.activeMinutesWeekGoal;
        var floorsClimbedString = monitoring.floorsClimbed;
        var floorsClimbedGoalString = monitoring.floorsClimbedGoal;
        var caloriesString = monitoring.calories;
        var caloriesGoalString = 3000;

        // FOR TESTING /!\
        stepsString = 2500;
        activeMinutesString = 100;
        floorsClimbedString = 7;
        caloriesString = 1000;

        //-----------------------
        // Update the view
        //-----------------------
        var viewTime = View.findDrawableById("TimeLabel") as Text;
        viewTime.setColor(getApp().getProperty("ForegroundColor") as Number);
        viewTime.setText(timeString);
        
        var viewDate = View.findDrawableById("DateLabel") as Text;
        viewDate.setColor(getApp().getProperty("ForegroundColor") as Number);
        viewDate.setText(dateString);

        var viewBattery = View.findDrawableById("BatteryLabel") as Text;
        viewBattery.setColor(getApp().getProperty("ForegroundColor") as Number);
        viewBattery.setText(batteryString);

        var viewWeather = View.findDrawableById("WeatherLabel") as Text;
        viewWeather.setColor(getApp().getProperty("ForegroundColor") as Number);
        viewWeather.setText(temperatureString + " - " + precipitationString);

        var viewSteps = View.findDrawableById("StepsLabel") as Text;
        viewSteps.setColor(getApp().getProperty("ForegroundColor") as Number);
        viewSteps.setText(stepsString + " / " + stepsGoalString);

        var viewActiveMinutes = View.findDrawableById("ActiveMinutesLabel") as Text;
        viewActiveMinutes.setColor(getApp().getProperty("ForegroundColor") as Number);
        viewActiveMinutes.setText(activeMinutesString + " / " + activeMinutesGoalString);

        // Call the parent onUpdate function to redraw the layout
        //View.onUpdate(dc);

        var widthScreen = dc.getWidth();
        var heightScreen = dc.getHeight();
        var width = 152;
        var height = 20;
        var radius = 2;
        var x = 30;
        var y = (heightScreen/2) - height - 2;        

        // Hours
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x-1,40,Graphics.FONT_NUMBER_MEDIUM,timeString,Graphics.TEXT_JUSTIFY_LEFT);

        // Data field 1
        dc.setColor(getApp().getProperty("Jauge1BackgroundColor"), Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x-1,y-1,width+2, height+2,radius);
        dc.setColor(getApp().getProperty("Jauge1ForegroundColor"), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x,y,width*(battery.battery/100),height);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawBitmap(x+5, y, WatchUi.loadResource(Rez.Drawables.battery));
        //dc.drawText(x+5,y,Graphics.FONT_XTINY,battery.battery.format("%d")+"%",Graphics.TEXT_JUSTIFY_LEFT);
        
        // Data field 2
        y += height+4;
        dc.setColor(getApp().getProperty("Jauge2BackgroundColor"), Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x-1,y-1,width+2, height+2,radius);
        dc.setColor(getApp().getProperty("Jauge2ForegroundColor"), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x,y,width*(stepsString.toFloat() / stepsGoalString.toFloat()),height);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawBitmap(x+5, y, WatchUi.loadResource(Rez.Drawables.steps));
        //dc.drawText(x+5,y,Graphics.FONT_XTINY,stepsString + " / " + stepsGoalString,Graphics.TEXT_JUSTIFY_LEFT);

        // Data field 3
        y += height+4;
        dc.setColor(getApp().getProperty("Jauge3BackgroundColor"), Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x-1,y-1,width+2, height+2,radius);
        dc.setColor(getApp().getProperty("Jauge3ForegroundColor"), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x,y,width*(activeMinutesString.toFloat() / activeMinutesGoalString.toFloat()),height);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x+5,y,Graphics.FONT_XTINY,activeMinutesString + " / " + activeMinutesGoalString,Graphics.TEXT_JUSTIFY_LEFT);

        // Data fiels 4
        x += width+4;
        y = (heightScreen/2) - height - 2;
        width = height;
        height = (height*3)+4+4;
        dc.setColor(getApp().getProperty("Jauge4BackgroundColor"), Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x-1,y-1,width+2,height+2,radius);
        dc.setColor(getApp().getProperty("Jauge4ForegroundColor"), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x,y,width,height*(floorsClimbedString.toFloat() / floorsClimbedGoalString.toFloat()));
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawBitmap(x, y+5, WatchUi.loadResource(Rez.Drawables.stairs));
        //dc.drawText(x,y+5,Graphics.FONT_XTINY,floorsClimbedString + " / " + floorsClimbedGoalString,Graphics.TEXT_JUSTIFY_LEFT);

        // Data field 5
        x += width+4;
        dc.setColor(getApp().getProperty("Jauge5BackgroundColor"), Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x-1,y-1,width+2,height+2,radius);
        dc.setColor(getApp().getProperty("Jauge5ForegroundColor"), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x,y,width,height*(caloriesString.toFloat() / caloriesGoalString.toFloat()));
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x,y+5,Graphics.FONT_XTINY,caloriesString + " / " + caloriesGoalString,Graphics.TEXT_JUSTIFY_LEFT);
    
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

}
