using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{

    [Header("Viewport point")]
    [SerializeField] private Vector2 toFrame = new Vector2(0, 0);
    [SerializeField] private Vector2 fromFrame = new Vector2(0, 0);
    [Header("Cam Setting")]
    [SerializeField] private Vector3 camOffset = new Vector3(0, 0, 0);
    [SerializeField] private float smoothSpeed = 0.125f;


    private Vector3 target;
    private Vector3 targetViewportPos;

    private Vector3 velocity = Vector3.zero;


    private void Start()
    {
    }

    void FixedUpdate()
    {
        target = GameObject.FindGameObjectWithTag("Player").transform.position;
        targetViewportPos = Camera.main.WorldToViewportPoint(target);
        if (!( targetViewportPos.x > toFrame.x
            && targetViewportPos.y < toFrame.y
            && targetViewportPos.x < fromFrame.x
            && targetViewportPos.y > fromFrame.y )
            )
        {
            Vector3 desiredPosition = target + camOffset;
            Vector3 smoothedPosition = Vector3.Lerp(transform.position, desiredPosition, smoothSpeed * Time.fixedDeltaTime);
            transform.position = smoothedPosition;
        }
    }
}
