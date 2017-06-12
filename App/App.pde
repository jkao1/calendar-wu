import controlP5.*;
import java.util.*;
import java.text.*;
import java.io.*;
import javax.swing.*;

Calendar todayCal = Calendar.getInstance(); // keeps track of today
final int CAL_WIDTH = 1050;
final int CAL_HEIGHT = 642;
final int HEADER_HEIGHT = 120;
final int navButtonWidth = 70;
final int navButtonHeight = 20;
final int MONTH_EVENT_HEIGHT = 17;
final int labelWidth = 49;
final int timeLineThickness = 2;
final int sideMonthWidth = 400;
int boxWidth = (CAL_WIDTH - labelWidth) / 7;
int boxHeight = CAL_HEIGHT / 27; // 24 time slots + 3 slots for all-day


Helper helper;
Event focusedEvent = null;


// for mini month drawing
final int monthWidth = (CAL_WIDTH - 40) / 4;
final int monthHeight = CAL_HEIGHT / 3;  
final int dayWidth = 30;
final int dayHeight = 27;

boolean todayInWeek = false;
boolean wasJustOn = false;

// colors
final int gray = 120; // red is rgb(234, 76, 60)

PFont font40, font30, font24, font20, font15, font12, font10;
PFont fontbold15;
String fontName = "Avenir-Light";

String DATA_FILE = "events.dat";

Calendar testCal; // for rolling & adding when drawing the layouts (like a physics test charge xD we use it to do relative stuff)
MyBST events;
ArrayList<Day> days;
int layout;

String[] months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
String[] daysOfWeekLetter = {"S", "M", "T", "W", "T", "F", "S"};
String[] daysOfWeekAbbrv = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
String[] daysOfWeekFull = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};


public void settings() {
  size(1050, 762);
}

void setup() {
  days = new ArrayList<Day>();
  layout = 0; // default is month layout
  
  font40 = loadFont(fontName + "-40.vlw");
  font30 = loadFont(fontName + "-30.vlw");
  font24 = loadFont(fontName + "-24.vlw");
  font20 = loadFont(fontName + "-20.vlw");
  font15 = loadFont(fontName + "-15.vlw");
  font12 = loadFont(fontName + "-12.vlw");
  font10 = loadFont(fontName + "-10.vlw");
  
  fontbold15 = loadFont("Avenir-Heavy-15.vlw");
  
  
     
  events = new MyBST( loadStrings( DATA_FILE ));
  testCal = Calendar.getInstance();
  Day(0);
  
  helper = new Helper(this);
}

void drawHeader() {
  
  fill(0);
  textFont(font40, 40);
  
  if (layout == 0) { // month layout 
    int relX = 10;
    int relY = navButtonHeight + 55;
  
    // draw title
    text( months[ testCal.get( Calendar.MONTH ) + 1 ] + " " + testCal.get(Calendar.YEAR), relX, relY );
    
    // draw labels for days of week
    relY  += HEADER_HEIGHT - relY - 10;
    textFont(font20, 20);
    for (int dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++) {
      text( daysOfWeekAbbrv[ dayOfWeek ], relX + dayOfWeek * CAL_WIDTH / 7 + (27 * CAL_WIDTH / 7 / 40), relY );
    }
  } 
  else if (layout == 1){ // week
  
    text(months[ testCal.get(Calendar.MONTH) ] + " " + testCal.get(Calendar.YEAR), 0, 50 + navButtonHeight);
    textFont(font20, 20);
    for(int i = 0; i < 7; i++){
      text(daysOfWeekAbbrv[i] + " " + testCal.get(Calendar.DATE), labelWidth + ((CAL_WIDTH - labelWidth) / 7) * i + 40, 88 + navButtonHeight);
      testCal.add(Calendar.DATE, 1);
    }
    testCal.add(Calendar.DATE, -7);
  } else if (layout == 2) { // day
    text(months[testCal.get(Calendar.MONTH)] + " " + testCal.get(Calendar.DAY_OF_MONTH), 0, 50 + navButtonHeight);
    textFont(font30, 30);
    text(daysOfWeekFull[testCal.get(Calendar.DAY_OF_WEEK)-1], 0, 80 + navButtonHeight);
  } 
  else if (layout == 3) { // year
    text( testCal.get(Calendar.YEAR), 20, 50 + navButtonHeight);
  }
  fill(255);
}

void drawDay() {
  layout = 2;
  int originalYear = testCal.get( Calendar.YEAR );
  int originalMonth = testCal.get( Calendar.MONTH );
  int originalDate = testCal.get( Calendar.DATE );
  background(255);
  drawHeader();
  fill(0);

  Day day = new Day( originalYear, originalMonth, originalDate );
  days.add( day );
    
  int dayX = 0;
  int dayY = 0;
  fill(230);
  rect(dayX, dayY, sideMonthWidth, HEADER_HEIGHT + CAL_HEIGHT);
  fill(0);
  dayX += 20;
  dayY += navButtonHeight + 30;
  drawSmallMonth( dayX, dayY, false );
  drawTimeLabels( sideMonthWidth + 20, HEADER_HEIGHT);  
  fill(255);
  day.display();
} 

void drawWeek() {
  int originalYear = testCal.get( Calendar.YEAR );
  int originalMonth = testCal.get( Calendar.MONTH );
  int originalDate = testCal.get( Calendar.DATE );
  int currentYear, currentMonth, currentDate;
  background(255);
  layout = 1;
  drawHeader();  
  textFont(font12, 12);
  fill( 0 );
  
  drawTimeLabels( 7, HEADER_HEIGHT);
    
  fill( 0 );
  int dayNum = 0;
  while ( dayNum < 7) {
    currentYear = testCal.get( Calendar.YEAR );
    currentMonth = testCal.get( Calendar.MONTH );
    currentDate = testCal.get( Calendar.DATE );    
    if (currentYear == todayCal.get( Calendar.YEAR ) && currentMonth == todayCal.get( Calendar.MONTH ) && currentDate == todayCal.get( Calendar.DATE )) {
      todayInWeek = true;
    }
    Day day = new Day( currentYear, currentMonth, currentDate, dayNum, 0 );
    day.display();
    days.add(day);
    testCal.add( Calendar.DATE, 1 );
    dayNum++;
  }
  testCal.add( Calendar.DATE, -7 );

}

void drawTimeLabels(int relX, int relY) {  
  text("all-day", relX, relY + 20);

  // draw labels from 12a to 11a
  relY += 3 * boxHeight;
  relY += 10; // to adjust for time label
  text("12 AM", relX, relY );
  for (int t = 1; t < 12; t++) {
    if (t < 10) {
      text("   " + t + " AM", relX, relY + boxHeight * t);
    } else {
      text(" " + t + " AM", relX, relY + boxHeight * t);
    }
  }
  
  // draw labels from 12p to 11p
  text("12 PM", relX, relY  + boxHeight * 12);
  for (int t = 1; t < 12; t++) {
    if (t < 10) {
      text("   " + t + " PM", relX, relY + boxHeight * (t + 12));
    } else {
      text(" " + t + " PM", relX, relY + boxHeight * (t + 12));
    }
  }
}

void drawMonth() {
  layout = 0;
  int originalYear = testCal.get( Calendar.YEAR );
  int originalMonth = testCal.get( Calendar.MONTH );
  int originalDate = testCal.get( Calendar.DATE );
    
  // set to previous month's Sunday
  testCal.add( Calendar.DATE, -testCal.get( Calendar.DATE ));
  testCal.add( Calendar.DATE, 1 - testCal.get( Calendar.DAY_OF_WEEK ));
  
  int currentYear, currentMonth, currentDate;
  background(255);
  drawHeader();
  layout = 0;
    
  boolean onFocusMonth = false;  
  int currentColor = gray;  
  int dayNum = 0;
  int eventTracker = 0;
  
  while ( dayNum < 42) {
    currentYear = testCal.get( Calendar.YEAR );
    currentMonth = testCal.get( Calendar.MONTH );
    currentDate = testCal.get( Calendar.DATE );
    
    if ( currentDate == 1 ) { // if at the beginning of the month
      if ( onFocusMonth ) {
        currentColor = gray; // out of focus month, so change back to gray
      } else {
        currentColor = 0; // in focus month now, so change to black
        onFocusMonth = true;
      }
    }
    
    Day day = new Day( currentYear, currentMonth, currentDate, dayNum, currentColor );
    day.display();
    days.add(day);
    testCal.add( Calendar.DATE, 1 );
    dayNum++;
  }
  currentYear = testCal.get( Calendar.YEAR );
  currentMonth = testCal.get( Calendar.MONTH );
  currentDate = testCal.get( Calendar.DATE );
  testCal.add( Calendar.YEAR, originalYear - currentYear ); 
  testCal.add( Calendar.MONTH, originalMonth - currentMonth ); 
  testCal.add( Calendar.DATE, originalDate - currentDate ); 
}

void drawYear() {
  layout = 3;
  int originalYear = testCal.get( Calendar.YEAR );
  int originalMonth = testCal.get( Calendar.MONTH );
  int originalDate = testCal.get( Calendar.DATE );

  background(255);
  drawHeader();
  
  int xpos = 40;
  int ypos = HEADER_HEIGHT;  
  
  testCal.add( Calendar.MONTH, -testCal.get( Calendar.MONTH ));
  noStroke();
  int trackerY, trackerM, trackerD;
  
  for(int monthNum = 0; monthNum < 12; monthNum++) {
    
    drawSmallMonth(xpos + (monthNum % 4) * monthWidth, ypos + (monthNum / 4) * monthHeight, true);
    fill(255);
  }
  
  int currentYear = testCal.get( Calendar.YEAR );
  int currentMonth = testCal.get( Calendar.MONTH );
  int currentDate = testCal.get( Calendar.DATE );
  testCal.add( Calendar.YEAR, originalYear - currentYear ); 
  testCal.add( Calendar.MONTH, originalMonth - currentMonth ); 
  testCal.add( Calendar.DATE, originalDate - currentDate ); 
}

void drawSmallMonth(int xpos, int ypos, boolean drawMonthHeader) {
  int originalYear = testCal.get( Calendar.YEAR );
  int originalMonth = testCal.get( Calendar.MONTH );
  int originalDate = testCal.get( Calendar.DATE );
  
  boolean colorSwitched = false;
  int currentColor = gray;
  
  int relX = xpos;
  int relY = ypos;

  if (drawMonthHeader) {
    fill( 234, 76, 60 );
    textFont( font20, 20 );
    text( months[ testCal.get( Calendar.MONTH ) ], relX, relY ); // write month name
    relY += dayHeight;
  }
    
  // begin drawing numbers  
  textFont( font12, 12 );
  fill( gray );
  for (int dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++) {
    text( daysOfWeekLetter[ dayOfWeek ], relX + dayOfWeek * 30, relY );
  }
  
  testCal.add( Calendar.DATE, -testCal.get( Calendar.DATE ));
  testCal.add( Calendar.DATE, 1 - testCal.get( Calendar.DAY_OF_WEEK ));
  
  int trackerY = testCal.get( Calendar.YEAR );
  int trackerM = testCal.get( Calendar.MONTH );
  int trackerD = testCal.get( Calendar.DATE );
  
  // drawing dates    
  fill( 0 );
  relY += dayHeight;
  for(int dayNum = 0; dayNum < 42; dayNum++) {
    if ( testCal.get(Calendar.DATE) == 1 ) {
      if ( colorSwitched ) {
        currentColor = gray;
      } else {
        currentColor = 0;
        colorSwitched = true;
      }
    }
    
    if ( currentColor == 0 && // make sure we are on the focus month
         testCal.get( Calendar.YEAR) == todayCal.get( Calendar.YEAR) &&
         testCal.get( Calendar.MONTH) == todayCal.get( Calendar.MONTH) &&
         testCal.get( Calendar.DATE) == todayCal.get( Calendar.DATE) ) {
      fill(255, 0, 0);
      if ( testCal.get( Calendar.DATE ) < 10 ) {
        ellipse(relX + (dayNum % 7) * dayWidth + 3.5, relY + (dayNum / 7) * dayHeight - 5.8, 20, 20);
      } else {
        ellipse(relX + (dayNum % 7) * dayWidth + 6.5, relY + (dayNum / 7) * dayHeight - 5, 20, 20);
      }
      fill(255);
      text( testCal.get(Calendar.DATE), relX + (dayNum % 7) * dayWidth, relY + (dayNum / 7) *dayHeight );
      fill( currentColor );
    } else {        
      fill(currentColor);
      text( testCal.get(Calendar.DATE), relX + (dayNum % 7) * dayWidth, relY + (dayNum / 7) *dayHeight );
    }
    testCal.add(Calendar.DATE, 1);
  }    
  int currentYear = testCal.get( Calendar.YEAR );
  int currentMonth = testCal.get( Calendar.MONTH );
  int currentDate = testCal.get( Calendar.DATE );
  
  if (layout != 3) { // only in year layout do we not reset months after every draw
    testCal.add( Calendar.YEAR, originalYear - currentYear ); 
    testCal.add( Calendar.MONTH, originalMonth - currentMonth ); 
    testCal.add( Calendar.DATE, originalDate - currentDate );
  }
}

void printCal() {
  println(testCal.get(Calendar.DAY_OF_WEEK)+", " + testCal.get(Calendar.MONTH)+"/"+testCal.get(Calendar.DATE)+"/"+testCal.get(Calendar.YEAR));
}

void draw() {
  fill(255);
  todayCal = Calendar.getInstance();
  if (layout == 1) {
      fill(255, 0, 0);
      rect(labelWidth,
           HEADER_HEIGHT + 3 * boxHeight + (todayCal.get(Calendar.HOUR_OF_DAY) * 60 + todayCal.get(Calendar.MINUTE)) / 60.0 * boxHeight, 
           CAL_WIDTH, 
           timeLineThickness);
  }
  else if (layout == 2) {
      fill(255, 0, 0);
      rect(sideMonthWidth + 3 * labelWidth / 2,
           HEADER_HEIGHT + 3 * boxHeight + (todayCal.get(Calendar.HOUR_OF_DAY) * 60 + todayCal.get(Calendar.MINUTE)) / 60.0 * boxHeight, 
           CAL_WIDTH - (sideMonthWidth + 3 * labelWidth / 2) - 20, 
           timeLineThickness);
  }
}

String getTime() {
  String hour;
  if ( todayCal.get(Calendar.HOUR) == 0) {
      hour = "12";
  } else {
      hour = "" + todayCal.get(Calendar.HOUR);
  }
  String minute;
  if ( todayCal.get(Calendar.MINUTE) < 10) {
      minute = "0" + todayCal.get(Calendar.MINUTE) % 60;
  } else {
      minute = "" + todayCal.get(Calendar.MINUTE) % 60;
  }
  String meridiem;
  if (todayCal.get(Calendar.HOUR_OF_DAY) < 12) {
      meridiem = "a";
  } else {
      meridiem = "p";
  }
  return hour + ":" + minute + meridiem;
}
  

void mousePressed() {
  Day editMe;
  if (mouseY > HEADER_HEIGHT) {
      if (layout == 0) {
        int calCol = mouseX / (CAL_WIDTH / 7);
        int calRow = (mouseY - HEADER_HEIGHT) / ((CAL_HEIGHT)/ 6);
        int dayNum = calRow * 7 + calCol;
        editMe = days.get( days.size() - (42 - dayNum ));
        boolean mouseOnEvent = editMe.hasMouseOnEvent();
        if (mouseOnEvent) {
          if (mouseButton == RIGHT) {   
            editMe.editEvent(false);
          } else {
            focusedEvent = editMe.editEvent(true);
            showFocusedEvent();
          }
        } else {
          editMe.newEventWindow();
        }
        editMe.display();
      }
      if (layout == 1) {
        int calCol = (mouseX - 50) / (CAL_WIDTH / 7);
        editMe = days.get( days.size() - (7 - calCol));
        
        if ( !editMe.tryEditingEvent() ) { // an event can be edited
          editMe.newEventWindow();
        }
        
        editMe.display();
      }
  }
}

void keyPressed() {
  if (key == '-') {
    focusedEvent = events.findEvents( 2017, 5, 3 ).get(0);
    showFocusedEvent();
  }
}

void showFocusedEvent() {
  // make the event brighter?
  // then,
  println(focusedEvent);  helper.showFocusedEvent();
}

public void Day(int value) {
  drawDay();
}

public void Week(int value) {
  drawWeek();
}

public void Month(int value) {
  drawMonth();
}

public void Year(int value) {
  drawYear();
}

public void Previous(int value) {
  if (layout == 0) {
    testCal.add( Calendar.MONTH, -1 );
    drawMonth();
  }
  if (layout == 1) { // week
    testCal.add( Calendar.DATE, -7 );
    drawWeek();
  }
  if (layout == 2) { // day
    testCal.add( Calendar.DATE, -1 );
  }
  if (layout == 3) {
    testCal.add( Calendar.YEAR, -1 );
    drawYear();
  }
}

public void Next(int value) {
  if (layout == 0) {
    testCal.add( Calendar.MONTH, 1 );
    drawMonth();
  }
  if (layout == 1) { // week
    testCal.add( Calendar.DATE, 7 );
    drawWeek();
  }
  if (layout == 2) { // day
    testCal.add( Calendar.DATE, 1 );
  }
  if (layout == 3) {
    testCal.add( Calendar.YEAR, 1 );
    drawYear();
  }
}

public void Today(int value) {
  testCal = Calendar.getInstance();
  if (layout == 0) {
    drawMonth();
  }
  if (layout == 1) { // week
    drawWeek();
  }
  if (layout == 2) { // day
  }
  if (layout == 3) {
    drawYear();
  }
}

void exit() {
  Event[] eventAry = events.getAllEvents();
  String[] output = new String[ eventAry.length ];
  for (int i = 0; i < eventAry.length; i++) {
    output[i] = eventAry[i].toString();
  }    
  saveStrings( DATA_FILE, output );
}