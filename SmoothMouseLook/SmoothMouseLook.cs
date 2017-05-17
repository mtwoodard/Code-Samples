/*
 * SmoothMouseLook.cs
 * Created by Michael Woodard -- www.michaelwoodard.net
 * Smooth Mouse Look - controls camera using mouse input can also rotate another game body
 * Also implements cursor lock functions
 * Licensed under the MIT license
 */
using UnityEngine;

[AddComponentMenu("Camera/Smooth Mouse Look")]
public class SmoothMouseLook : MonoBehaviour
{
    public bool cursorLock = true;
    public int inverted = -1; // must be either 1 or -1
    public float sensitivityX = 2.0f;
    public float sensitivityY = 2.0f;
    public float pitchClamp = 80f;
    public float yawClamp = 360f;
    public float smooth = 3.0f;
    public GameObject character;

    Vector2 smoothMouse;
    Vector2 finalMouse;

    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
    }

    void Update()
    {
        if (Cursor.lockState == CursorLockMode.Locked){
            float mouseX = Input.GetAxisRaw("Mouse X") * sensitivityX * smooth;
            float mouseY = Input.GetAxisRaw("Mouse Y") * sensitivityY * smooth * inverted;

            //smooth out our raw values and previous values using 1/smooth as the t
            smoothMouse.x = Mathf.Lerp(smoothMouse.x, mouseX, 1f / smooth);
            smoothMouse.y = Mathf.Lerp(smoothMouse.y, mouseY, 1f / smooth);

            //add the smoothed value to our current rotation value
            finalMouse += smoothMouse;
            
            //either simplify x if we allow complete turning or clamp it and clamp our pitch
            if(yawClamp != 360f)
                finalMouse.x = Mathf.Clamp(finalMouse.x, -yawClamp, yawClamp);
            else
                finalMouse.x = SimplifyAngle(finalMouse.x);
            finalMouse.y = Mathf.Clamp(finalMouse.y, -pitchClamp, pitchClamp);

            //if we have a body rotate the body on y axis and camera on x axis
            //otherwise apply both rotations to the camera
            if (character){
                transform.localRotation = Quaternion.AngleAxis(finalMouse.y, Vector3.right); //pitch
                character.transform.localRotation = Quaternion.AngleAxis(finalMouse.x, character.transform.up); //yaw
            }
            else
                transform.localRotation = Quaternion.Euler(finalMouse.y, finalMouse.x, 0);
        }
    }
    /// <summary>
    /// Unlocks the cursor to be inside the game window - Useful for in game windows
    /// </summary>
    public void UnlockCursor()
    {
        Cursor.lockState = CursorLockMode.Confined;
    }
    /// <summary>
    /// Locks the cursor - helpful if you need to lock the cursor back after unlocking it
    /// </summary>
    public void LockCursor()
    {
        Cursor.lockState = CursorLockMode.Locked;
    }
    /// <summary>
    /// Takes the angle and tries to recursively lower it back inside the range [-360 , 360]
    /// </summary>
    /// <param name="xVal">Angle we want to lower</param>
    /// <returns>Angle inside range [-360, 360]</returns>
    static float SimplifyAngle(float xVal)
    {
        bool keepGoing = false;
        if (xVal >= 360f){
            keepGoing = true;
            xVal -= 360f;
        }
        else if (xVal <= -360f){
            keepGoing = true;
            xVal += 360f;
        }
        if (keepGoing)
            return SimplifyAngle(xVal);
        else
            return xVal;
    }
}