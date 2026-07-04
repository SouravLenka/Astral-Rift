using UnityEngine;
using AstraRift.PowerUps;

namespace AstraRift.PowerUps
{
    [RequireComponent(typeof(Collider2D))]
    public class PowerUpPickup : MonoBehaviour
    {
        [SerializeField] private PowerUpData powerUpData;
        [SerializeField] private AudioClip pickupSfx;

        private void Awake()
        {
            var collider = GetComponent<Collider2D>();
            collider.isTrigger = true;
        }

        private void OnTriggerEnter2D(Collider2D other)
        {
            var player = other.GetComponent<AstraRift.Player.PlayerController>();
            if (player != null)
            {
                PowerUpManager.Instance?.ActivatePowerUp(powerUpData, player.gameObject);
                if (pickupSfx != null)
                    AstraRift.Managers.AudioManager.Instance?.PlaySfx(pickupSfx);
                Destroy(gameObject);
            }
        }
    }
}
