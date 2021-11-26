using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeSpawner : MonoBehaviour
{
    [SerializeField] List<GameObject> enemies = new List<GameObject>();
    [SerializeField] float time = 5.0f;
    bool canSpawn = true;
    GameObject spawnFolder;

    void Start()
    {
        spawnFolder = new GameObject("spawnFolder");
    }

    private void Update()
    {
        SpawnEnemie();
    }

    void SpawnEnemie()
    {
        if (canSpawn)
            StartCoroutine(Timer());
    }

    IEnumerator Timer()
    {
        canSpawn = false;
        yield return new WaitForSeconds(time);
        Instantiate(enemies[Random.Range(0, 100) % enemies.Count], RandomEdgePos(), Quaternion.identity, spawnFolder.transform);
        canSpawn = true;
    }

    Vector3 RandomEdgePos()
    {
        float x = 0, y = 0;
        if (Random.Range(0, 2) == 1) // Horizontal
        {
            if (Random.Range(0, 2) == 1)// Top
            {
                x = Random.Range(0f, 1f);
                y = 1f;
            }
            else// Bottom
            {
                x = Random.Range(0f, 1f);
                y = 0;
            }
        }
        else                         // Vertical
        {
            if (Random.Range(0, 2) == 1)// left
            {
                x = 0f;
                y = Random.Range(0f, 1f);
            }
            else// right
            {
                x = 1f;
                y = Random.Range(0f, 1f);
            }
        }
        return Camera.main.ViewportToWorldPoint(new Vector3(x, y, 10)); ;
    }
}
