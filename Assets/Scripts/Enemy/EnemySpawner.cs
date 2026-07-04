using UnityEngine;

namespace AstraRift.Enemy
{
    public class EnemySpawner : MonoBehaviour
    {
        [SerializeField] private GameObject enemyPrefab;
        [SerializeField] private int spawnCount = 5;
        [SerializeField] private float spawnRadius = 8f;

        public void SpawnWave()
        {
            for (int i = 0; i < spawnCount; i++)
            {
                var angle = (float)i / spawnCount * Mathf.PI * 2f;
                var pos = transform.position + new Vector3(Mathf.Cos(angle), Mathf.Sin(angle), 0f) * spawnRadius * Random.Range(0.6f, 1f);
                Instantiate(enemyPrefab, pos, Quaternion.identity);
            }
        }

        private void OnDrawGizmosSelected()
        {
            Gizmos.color = Color.yellow;
            Gizmos.DrawWireSphere(transform.position, spawnRadius);
        }
    }
}
