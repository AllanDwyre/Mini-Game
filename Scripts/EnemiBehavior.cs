using UnityEngine;

public abstract class EnemiBehavior : MonoBehaviour
{
    [SerializeField]
    Vector2 speedRange = new Vector2(2f, 2.5f);
    float speed;

    void Start()
    {
        speed = Random.Range(speedRange.x, speedRange.y);

        float x = Random.Range(-1f, 1f), y = Random.Range(1f, 1f);
        float epsilon = 0.0001f;

        Vector3 pos = Camera.main.WorldToViewportPoint(transform.position);

        if (Mathf.Abs(pos.x) < epsilon)//gauche -> droite
            x = 1f;
        else if (Mathf.Abs(pos.x - 1f) < epsilon)//droite -> gauche
            x = -1f;
        else if (Mathf.Abs(pos.y) < epsilon)//bas -> haut
            y = 1f;
        else if (Mathf.Abs(pos.y - 1f) < epsilon)//haut -> bas
            y = -1f;

        transform.rotation = Quaternion.FromToRotation(transform.forward, new Vector3(x, y, 0f));
        transform.rotation = Quaternion.Euler(transform.rotation.eulerAngles.x, transform.rotation.eulerAngles.y, 0f);
    }

    protected virtual void Update()
    {
        transform.position += transform.forward * speed * Time.deltaTime;
        Vector3 pos = Camera.main.WorldToViewportPoint(transform.position);
        if (pos.x < -.5f || pos.x > 1.5f || pos.y < -.5f || pos.y > 1.5f)
        {
            Destroy(this.gameObject);
        }
    }

    protected abstract void Skill();

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            Destroy(other.gameObject);
            GameManager.isDead();
        }
    }
}
