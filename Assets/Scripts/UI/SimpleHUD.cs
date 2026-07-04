using UnityEngine;
using UnityEngine.UI;
using AstraRift.Player;
using AstraRift.Utilities;

namespace AstraRift.UI
{
    public class SimpleHUD : MonoBehaviour
    {
        [SerializeField] private PlayerController player;
        [SerializeField] private Text healthText;
        [SerializeField] private Text shieldText;

        private PlayerHealth playerHealthComp;

        private void Start()
        {
            if (player != null)
                playerHealthComp = player.GetComponent<PlayerHealth>();

            MessageBroker.Subscribe<AstraRift.Player.PlayerDamagedEvent>(OnPlayerDamaged);
            MessageBroker.Subscribe<AstraRift.Player.PlayerRespawnedEvent>(OnPlayerRespawned);
        }

        private void OnDestroy()
        {
            MessageBroker.Unsubscribe<AstraRift.Player.PlayerDamagedEvent>(OnPlayerDamaged);
            MessageBroker.Unsubscribe<AstraRift.Player.PlayerRespawnedEvent>(OnPlayerRespawned);
        }

        private void Update()
        {
            if (playerHealthComp != null)
            {
                healthText.text = $"HP: {playerHealthComp.GetHealth()}";
                shieldText.text = $"SH: {playerHealthComp.GetShield()}";
            }
        }

        private void OnPlayerDamaged(AstraRift.Player.PlayerDamagedEvent evt)
        {
            if (evt.Player == playerHealthComp)
            {
                // could trigger flash
            }
        }

        private void OnPlayerRespawned(AstraRift.Player.PlayerRespawnedEvent evt)
        {
            if (evt.Player == playerHealthComp)
            {
                // update UI
            }
        }
    }
}
