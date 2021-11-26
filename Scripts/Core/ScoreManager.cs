using System;
using System.Collections;
using UnityEngine;


public class ScoreManager : MonoBehaviour
{
    float timeSinceBeginning = 0f;
    int score = 0;
    void Start()
    {
    }
    void Update()
    {
        timeSinceBeginning += Time.deltaTime;
        score = (int)timeSinceBeginning;
        if (score % 10 == 0)
        {
            Display();
        }
    }

    private void Display()
    {
        print(score);
    }

}
