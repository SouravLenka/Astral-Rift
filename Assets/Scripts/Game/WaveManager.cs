using UnityEngine;
using System.Collections;
using AstraRift.Enemy;
using AstraRift.Utilities;

namespace AstraRift.Game
{
    public class WaveManager : MonoBehaviour
    {
        public static WaveManager Instance { get; private set; }

        [SerializeField] private EnemySpawner spawner;
        [SerializeField] private float timeBetweenWaves = 8f;
        [SerializeField] private int currentWave = 0;

        private void Awake()
        {
            if (Instance != null && Instance != this) { Destroy(gameObject); return; }
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }

        private void Start()
        {
            StartCoroutine(WaveRoutine());
        }

        private IEnumerator WaveRoutine()
        {
            while (true)
            {
                yield return new WaitForSeconds(2f);
                currentWave++;
                MessageBroker.Publish(new WaveStartedEvent(currentWave));
                spawner?.SpawnWave();
                yield return new WaitForSeconds(timeBetweenWaves);
            }
        }
    }

    public readonly struct WaveStartedEvent
    {
        public int WaveNumber { get; }
        public WaveStartedEvent(int n) { WaveNumber = n; }
    }
}
