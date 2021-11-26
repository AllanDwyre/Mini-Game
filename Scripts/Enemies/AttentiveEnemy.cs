using System.Collections;
using UnityEngine;

public class AttentiveEnemy : EnemiBehavior
{
    [SerializeField]
    float detectionRadius = 2.0f;

    [SerializeField]
    float rotationSpeed = 2.0f;

    protected override void Update()
    {
        base.Update();
        Skill();
    }

    protected override void Skill()
    {
        GameObject player = GameObject.FindGameObjectWithTag("Player");
        if (player != null)
        {
            float distance = Vector3.Distance(player.transform.position, transform.position);
            if (distance <= detectionRadius)
            {

                Vector3 newDirection = Vector3.RotateTowards(transform.forward,
                    player.transform.position - transform.position, rotationSpeed * Time.deltaTime, 0.0f);
                transform.rotation = Quaternion.LookRotation(newDirection);
            }
        }
    }
}
