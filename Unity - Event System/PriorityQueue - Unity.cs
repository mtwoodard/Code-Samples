using System;
using System.Collections.Generic;

public class PriorityQueue<T> where T : IComparable<T>
{
	private List <T> data;

	public PriorityQueue(){
		this.data = new List<T>();
	}
	
	/// <summary>
	///	Adds element to priority queue and orders it based on its CompareTo implementation.
	/// </summary>
	public void Add(T t){
		data.Add(t);
		data.Sort();
	}

	/// <summary>
	///	Removes the top most element from the priority queue (i.e. the highest priority element).
	/// </summary>
	public T Pop(){
		T t = data[0];
		data.RemoveAt(0);
		return t;
	}

	/// <summary>
	///	Clears all elements of the priority queue
	/// </summary>
	public void Clear(){
		data.Clear();
	}

	/// <summary>
	///	Returns the highest priority element.
	/// </summary>
	public T Peek(){
		try{
			return data[0];
		}
		catch(ArgumentOutOfRangeException e){
			Console.WriteLine("Index out of bounds: " + e.Message);
			throw new ArgumentOutOfRangeException();
		}
	}

	/// <summary>
	///	Returns the element at the given index
	/// </summary>
	public T ElementAt(int index){
		try{
			return data[index];
		}
		catch(ArgumentOutOfRangeException e){
			Console.WriteLine("Index out of bounds: " + e.Message);
			throw new ArgumentOutOfRangeException();
		}
	}

	/// <summary>
	///	Checks to see if the queue is empty
	/// </summary>
	public bool IsEmpty{
		get{
			if(data.Count == 0) return true;
			else return false;
		}
	}

	void Sort(){
		data.Sort();
	}

}
