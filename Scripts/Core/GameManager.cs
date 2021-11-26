using System;
using UnityEngine;
using UnityEngine.SceneManagement;
static class GameManager
{
    public static void isDead()
    {
        SceneManager.LoadScene("InGame");
    }

    public static void Difficulty(int increase = 1)
    {

    }

}
