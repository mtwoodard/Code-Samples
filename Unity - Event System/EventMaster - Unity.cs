using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EventMaster : MonoBehaviour {
	public List<Event> registeredEvents;
	PriorityQueue<Event> readyEvents;
	Event activeEvent;
	bool isEventActive;

	void Start(){
		activeEvent = null;
		readyEvents = new PriorityQueue<Event>();
		isEventActive = false;
	}

	// Update is called once per frame
	void Update () {
		//Check registered events 
		for(int i = 0; i < registeredEvents.Count; i++){
			if(registeredEvents[i].ReadyToActivate()){
				readyEvents.Add(registeredEvents[i]);
				registeredEvents.RemoveAt(i);
			}
		}

		//Get the highest priority event from ready events
		if(!isEventActive && !readyEvents.IsEmpty){
			isEventActive = true;
			activeEvent = readyEvents.Pop();
			activeEvent.StartEvent();
		}

		//Poll active event to see if its finished
		if(activeEvent != null && !activeEvent.eventRunning){
			activeEvent.EndEvent();
			isEventActive = false;
			activeEvent = null;
		}
	}

	//Add new event into our registered list
	public void RegisterEvent(Event e){
		registeredEvents.Add(e);
	}
}
