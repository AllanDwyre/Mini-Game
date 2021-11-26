using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class PlayerMovement : MonoBehaviour
{
    [SerializeField] float speed = 10.0f;
    [SerializeField] float runMultiplicator = 1.5f;

    Rigidbody rb;
    void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        OnScreenEdge();
        Vector3 movement = new Vector3(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"), 0).normalized * speed;
        rb.position += Input.GetKey(KeyCode.LeftShift) ?
            movement * runMultiplicator * Time.deltaTime :
            movement * Time.deltaTime;
    }

    void OnScreenEdge()
    {

        Vector3 pos = Camera.main.WorldToViewportPoint(transform.position);


        if (pos.x < 0.0)//I am right of the camera's view.
        {
            Vector3 x = Camera.main.ViewportToWorldPoint(new Vector3(1.0f, pos.y, pos.z));
            transform.position = x;
        }
        if (pos.x > 1.0)//I am left of the camera's view.
        {
            Vector3 x = Camera.main.ViewportToWorldPoint(new Vector3(0.0f, pos.y, pos.z));
            transform.position = x;
        }
        if (pos.y < 0.0)//I am top of the camera's view.
        {
            Vector3 x = Camera.main.ViewportToWorldPoint(new Vector3(pos.x, 1.0f, pos.z));
            transform.position = x;
        }
        if (pos.y > 1.0) //I am bottom of the camera's view.
        {
            Vector3 x = Camera.main.ViewportToWorldPoint(new Vector3(pos.x, 0.0f, pos.z));
            transform.position = x;
        }
    }
}
