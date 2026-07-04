using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using AstraRift.Player;
using AstraRift.Utilities;

namespace AstraRift.PowerUps
{
    public class PowerUpManager : MonoBehaviour
    {
        public static PowerUpManager Instance { get; private set; }

        private readonly Dictionary<PowerUpType, Coroutine> activeEffects = new Dictionary<PowerUpType, Coroutine>();
        private readonly Dictionary<GameObject, ActivePowerUp> targetEffects = new Dictionary<GameObject, ActivePowerUp>();

        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }

        public void ActivatePowerUp(PowerUpData data, GameObject target)
        {
            if (data == null || target == null) return;

            if (data.instantEffect)
            {
                ApplyEffect(data, target);
                return;
            }

            if (data.stackable && targetEffects.ContainsKey(target))
            {
                var existing = targetEffects[target];
                if (existing.data.type == data.type)
                {
                    StopCoroutine(existing.coroutine);
                    activeEffects.Remove(data.type);
                }
            }

            var coroutine = StartCoroutine(EffectRoutine(data, target));
            targetEffects[target] = new ActivePowerUp(data, target, coroutine);
            MessageBroker.Publish(new PowerUpActivatedEvent(target, data));
        }

        private IEnumerator EffectRoutine(PowerUpData data, GameObject target)
        {
            ApplyEffect(data, target);
            var duration = data.duration;
            while (duration > 0f)
            {
                duration -= Time.deltaTime;
                yield return null;
            }
            RemoveEffect(data, target);
            if (targetEffects.ContainsKey(target))
                targetEffects.Remove(target);
        }

        private void ApplyEffect(PowerUpData data, GameObject target)
        {
            switch (data.type)
            {
                case PowerUpType.TripleShot:
                    var weapon = target.GetComponent<AstraRift.Weapons.WeaponBase>();
                    if (weapon != null)
                        weapon.SetTemporarySpread(15f);
                    break;
                case PowerUpType.ShieldRestore:
                    var health = target.GetComponent<PlayerHealth>();
                    if (health != null)
                        health.RestoreShield(data.shieldRestore);
                    break;
                case PowerUpType.RapidFire:
                    var wf = target.GetComponent<AstraRift.Weapons.WeaponBase>();
                    if (wf != null)
                        wf.SetTemporaryFireRateMultiplier(1.75f);
                    break;
                case PowerUpType.SpeedBoost:
                    var movement = target.GetComponent<PlayerMovement>();
                    if (movement != null)
                        movement.SetTemporarySpeedMultiplier(1.4f);
                    break;
                case PowerUpType.EMP:
                    MessageBroker.Publish(new EmpTriggeredEvent(target.transform.position));
                    break;
                case PowerUpType.FreezeTime:
                    Time.timeScale = 0.4f;
                    break;
                case PowerUpType.DoubleDamage:
                    var wdd = target.GetComponent<AstraRift.Weapons.WeaponBase>();
                    if (wdd != null)
                        wdd.SetTemporaryDamageMultiplier(2f);
                    break;
            }
        }

        private void RemoveEffect(PowerUpData data, GameObject target)
        {
            switch (data.type)
            {
                case PowerUpType.TripleShot:
                    var weapon = target.GetComponent<AstraRift.Weapons.WeaponBase>();
                    if (weapon != null)
                        weapon.ResetTemporarySpread();
                    break;
                case PowerUpType.RapidFire:
                    var wf = target.GetComponent<AstraRift.Weapons.WeaponBase>();
                    if (wf != null)
                        wf.ResetTemporaryFireRateMultiplier();
                    break;
                case PowerUpType.SpeedBoost:
                    var movement = target.GetComponent<PlayerMovement>();
                    if (movement != null)
                        movement.ResetTemporarySpeedMultiplier();
                    break;
                case PowerUpType.FreezeTime:
                    Time.timeScale = 1f;
                    break;
            }
            MessageBroker.Publish(new PowerUpExpiredEvent(target, data));
        }

        public void ClearAllEffects(GameObject target)
        {
            if (targetEffects.TryGetValue(target, out var active))
            {
                StopCoroutine(active.coroutine);
                RemoveEffect(active.data, target);
                targetEffects.Remove(target);
            }
        }

        private struct ActivePowerUp
        {
            public PowerUpData data;
            public GameObject target;
            public Coroutine coroutine;

            public ActivePowerUp(PowerUpData data, GameObject target, Coroutine coroutine)
            {
                this.data = data;
                this.target = target;
                this.coroutine = coroutine;
            }
        }
    }

    public readonly struct PowerUpActivatedEvent
    {
        public GameObject Target { get; }
        public PowerUpData Data { get; }
        public PowerUpActivatedEvent(GameObject target, PowerUpData data) { Target = target; Data = data; }
    }

    public readonly struct PowerUpExpiredEvent
    {
        public GameObject Target { get; }
        public PowerUpData Data { get; }
        public PowerUpExpiredEvent(GameObject target, PowerUpData data) { Target = target; Data = data; }
    }

    public readonly struct EmpTriggeredEvent
    {
        public Vector3 Position { get; }
        public EmpTriggeredEvent(Vector3 position) { Position = position; }
    }
}
