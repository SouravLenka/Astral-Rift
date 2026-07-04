using UnityEngine;
using AstraRift.Interfaces;

namespace AstraRift.Player
{
    public class PlayerHealth : MonoBehaviour, IDamageable
    {
        [SerializeField] private PlayerShipStats stats;

        private int currentHealth;
        private int currentShield;
        private int livesLeft;

        private void Awake()
        {
            if (stats == null) return;
            currentHealth = stats.maxHealth;
            currentShield = stats.maxShield;
            livesLeft = stats.lives;
        }

        public void ApplyDamage(int amount)
        {
            if (amount <= 0) return;

            if (currentShield > 0)
            {
                var remaining = Mathf.Max(0, currentShield - amount);
                var absorbed = currentShield - remaining;
                currentShield = remaining;
                amount -= absorbed;
            }

            if (amount > 0)
            {
                currentHealth -= amount;
                if (currentHealth <= 0)
                {
                    livesLeft--;
                    if (livesLeft > 0)
                    {
                        Respawn();
                    }
                    else
                    {
                        Die();
                    }
                }
            }

            MessageBroker.Publish(new PlayerDamagedEvent(this, amount));
        }

        private void Respawn()
        {
            currentHealth = stats.maxHealth;
            currentShield = stats.maxShield;
            MessageBroker.Publish(new PlayerRespawnedEvent(this));
        }

        private void Die()
        {
            MessageBroker.Publish(new PlayerKilledEvent(this));
            // Disable visual representation - handled by other systems
            gameObject.SetActive(false);
        }

        public int GetHealth() => currentHealth;
        public int GetShield() => currentShield;
        public int GetLives() => livesLeft;
    }

    public readonly struct PlayerDamagedEvent
    {
        public PlayerHealth Player { get; }
        public int DamageAmount { get; }
        public PlayerDamagedEvent(PlayerHealth p, int amount) { Player = p; DamageAmount = amount; }
    }

    public readonly struct PlayerRespawnedEvent
    {
        public PlayerHealth Player { get; }
        public PlayerRespawnedEvent(PlayerHealth p) { Player = p; }
    }

    public readonly struct PlayerKilledEvent
    {
        public PlayerHealth Player { get; }
        public PlayerKilledEvent(PlayerHealth p) { Player = p; }
    }
}
