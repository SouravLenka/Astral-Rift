using UnityEngine;
using AstraRift.Player;
using AstraRift.Utilities;

namespace AstraRift.Weapons
{
    [RequireComponent(typeof(Player.PlayerController))]
    public class WeaponBase : MonoBehaviour
    {
        [SerializeField] private WeaponData data;
        [SerializeField] private Transform firePoint;
        [SerializeField] private float projectileLifetime = 5f;

        private float cooldownTimer;
        private Player.PlayerController controller;

        private void Awake()
        {
            controller = GetComponent<Player.PlayerController>();
        }

        private void OnEnable()
        {
            MessageBroker.Subscribe<Player.PlayerShootEvent>(OnPlayerShoot);
        }

        private void OnDisable()
        {
            MessageBroker.Unsubscribe<Player.PlayerShootEvent>(OnPlayerShoot);
        }

        private void Update()
        {
            cooldownTimer -= Time.deltaTime;
        }

        private void OnPlayerShoot(Player.PlayerShootEvent evt)
        {
            if (evt.Player != controller) return;
            TryFire();
        }

        public void TryFire()
        {
            if (data == null || cooldownTimer > 0f) return;

            FireOnce();
            cooldownTimer = 1f / Mathf.Max(0.0001f, data.fireRate);
        }

        private void FireOnce()
        {
            if (data.projectilePrefab == null || firePoint == null) return;

            var rot = firePoint.rotation;
            var dir = firePoint.up; // assuming up is forward

            var instance = PoolManager.Instance.Spawn(data.projectilePrefab, firePoint.position, rot);
            var proj = instance.GetComponent<Projectile>();
            if (proj != null)
            {
                // apply spread
                var angle = (data.spreadAngle / 2f) * (Random.value * 2f - 1f);
                var rotatedDir = Quaternion.Euler(0, 0, angle) * dir;
                proj.Initialize(rotatedDir, data.projectileSpeed, data.damage, projectileLifetime, data.projectilePrefab);
            }
        }
    }
}
