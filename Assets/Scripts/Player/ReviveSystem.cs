using UnityEngine;
using AstraRift.Player;
using AstraRift.Utilities;

namespace AstraRift.Player
{
    public class ReviveSystem : MonoBehaviour
    {
        [SerializeField] private float reviveRange = 2f;

        private void OnEnable()
        {
            MessageBroker.Subscribe<PlayerInteractEvent>(OnPlayerInteract);
        }

        private void OnDisable()
        {
            MessageBroker.Unsubscribe<PlayerInteractEvent>(OnPlayerInteract);
        }

        private void OnPlayerInteract(PlayerInteractEvent evt)
        {
            var reviver = evt.Player;
            var allPlayers = FindObjectsOfType<PlayerController>();
            foreach (var p in allPlayers)
            {
                if (p == null || p == reviver) continue;
                var health = p.GetComponent<PlayerHealth>();
                if (health == null) continue;

                var dist = Vector2.Distance(reviver.transform.position, p.transform.position);
                if (dist <= reviveRange)
                {
                    // attempt revive
                    health.Revive();
                    MessageBroker.Publish(new PlayerRevivedByEvent(reviver, p));
                    return;
                }
            }
        }
    }

    public readonly struct PlayerRevivedByEvent
    {
        public PlayerController Reviver { get; }
        public PlayerController Revived { get; }
        public PlayerRevivedByEvent(PlayerController r, PlayerController v) { Reviver = r; Revived = v; }
    }
}
