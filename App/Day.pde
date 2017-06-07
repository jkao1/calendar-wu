import java.util.*;

PFont font;

class Day {

  int year, month, date;
  int xpos, ypos;
  MyHeap events;

  Day(int year, int month, int date) {
    this.year = year;
    this.month = month;
    this.date = date;
    events = new MyHeap();
  }
  
  void display(int i, int layout, int col) {
    if (layout == 0) { // month layout
      xpos = (i % 7) * CAL_WIDTH / 7;
      ypos = 120 + ((i / 7) * (CAL_HEIGHT) / 6);
      rect(xpos, ypos, CAL_WIDTH / 7, CAL_HEIGHT / 6);
      fill(col);
      font = loadFont("ArialHebrew-120.vlw");
      textFont(font, 20);
      text(Integer.toString(date), xpos + 20, ypos + 30);
      if (!events.isEmpty()) {
        text(events.toString(), xpos + 20, ypos + 60);
      }
      fill(255);
      
    } else if(layout == 1) { // week layout
      
    } else { // day layout
      
    }
  }
  
  void addEvent(Event e) {
    events.add(e);
  }
  
  int getYear() {
    return year;
  }
  
  int getMonth() {
    return month;
  }

  int getDate() {
    return date;
  }
  
  String toString() {
    return month + "/" + date + "/" + year;
  }

}