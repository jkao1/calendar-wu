import java.util.*;

public class EventCollection {

    private ArrayList<Event> events;

    public EventCollection() {
        events = new ArrayList<Event>();
    }

    public ArrayList<Event> getEventsInRange(Date d1, Date d2)
    {
        ArrayList<Event> output = new ArrayList<Event>();
        for ()
        return output;
    }

    public void add(Event e) {
        events.add(e);
    }

    public void delete(Event e) {
        events.remove( indexOf( e ));
    }

    public int indexOf(Event e)
    {
        for (int i = 0; i < events.size(); i++) {
            if ( events.get(i).compareTo( e ) == 0 ) {
                return i;
            }
        }
        return -1;
    }

    // do iterator
}