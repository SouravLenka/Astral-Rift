using UnityEngine;
using AstraRift.Interfaces;

namespace AstraRift.Weapons
{
    public class Projectile : MonoBehaviour
    {
        public GameObject prefabReference; // the source prefab used for pooling
        public float speed = 12f;
        public int damage = 10;
        public float lifetime = 5f;

        private float lifeTimer;
        private Vector3 direction;

        private void OnEnable()
        {
            lifeTimer = lifetime;
        }

        private void Update()
        {
            transform.position += direction * speed * Time.deltaTime;
            lifeTimer -= Time.deltaTime;
            if (lifeTimer <= 0f)
                ReturnToPool();
        }

        public void Initialize(Vector3 dir, float spd, int dmg, float life, GameObject prefab)
        {
            direction = dir.normalized;
            speed = spd;
            damage = dmg;
            lifetime = life;
            prefabReference = prefab;
            lifeTimer = lifetime;
        }

        private void OnTriggerEnter2D(Collider2D other)
        {
            var dmg = other.GetComponent<IDamageable>();
            if (dmg != null)
            {
                dmg.ApplyDamage(damage);
                ReturnToPool();
                return;
            }

            // optionally collide with environment
        }

        private void ReturnToPool()
        {
            if (prefabReference != null && PoolManager.Instance != null)
            {
                PoolManager.Instance.Release(prefabReference, this.gameObject);
            }
            else
            {
                Destroy(this.gameObject);
            }
        }
    }
}
