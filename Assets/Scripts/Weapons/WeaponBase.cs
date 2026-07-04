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
        private float temporarySpread;
        private float temporaryFireRateMultiplier = 1f;
        private float temporaryDamageMultiplier = 1f;

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
            var effectiveFireRate = data.fireRate * temporaryFireRateMultiplier;
            cooldownTimer = 1f / Mathf.Max(0.0001f, effectiveFireRate);
        }

        private void FireOnce()
        {
            if (data.projectilePrefab == null || firePoint == null) return;

            var rot = firePoint.rotation;
            var dir = firePoint.up; // assuming up is forward

            var effectiveSpread = Mathf.Max(0f, data.spreadAngle + temporarySpread);
            var finalDamage = Mathf.Max(1, Mathf.RoundToInt(data.damage * temporaryDamageMultiplier));

            var instance = PoolManager.Instance.Spawn(data.projectilePrefab, firePoint.position, rot);
            var proj = instance.GetComponent<Projectile>();
            if (proj != null)
            {
                var angle = (effectiveSpread / 2f) * (Random.value * 2f - 1f);
                var rotatedDir = Quaternion.Euler(0, 0, angle) * dir;
                proj.Initialize(rotatedDir, data.projectileSpeed, finalDamage, projectileLifetime, data.projectilePrefab);
            }
        }

        public void SetTemporarySpread(float spread)
        {
            temporarySpread = spread;
        }

        public void ResetTemporarySpread()
        {
            temporarySpread = 0f;
        }

        public void SetTemporaryFireRateMultiplier(float multiplier)
        {
            temporaryFireRateMultiplier = Mathf.Max(0.01f, multiplier);
        }

        public void ResetTemporaryFireRateMultiplier()
        {
            temporaryFireRateMultiplier = 1f;
        }

        public void SetTemporaryDamageMultiplier(float multiplier)
        {
            temporaryDamageMultiplier = Mathf.Max(0.01f, multiplier);
        }

        public void ResetTemporaryDamageMultiplier()
        {
            temporaryDamageMultiplier = 1f;
        }
    }
}
