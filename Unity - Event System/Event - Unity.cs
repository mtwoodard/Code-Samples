using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Event : MonoBehaviour, System.IComparable<Event> {
	public int priority;
	public bool eventRunning;

	protected virtual void Start () {eventRunning=false;}
	
	protected virtual void Update () {	}

	public abstract bool ReadyToActivate();

	public virtual void StartEvent(){eventRunning = true;}
	public virtual void EndEvent(){eventRunning = false;}

	public int CompareTo(Event otherEvent){
		if(otherEvent != null)
			return priority.CompareTo(otherEvent.priority);
		else
			throw new System.ArgumentException("Object is not an Event");
	}
}
