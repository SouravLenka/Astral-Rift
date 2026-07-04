using UnityEngine;
using UnityEngine.InputSystem;
using AstraRift.Managers;

namespace AstraRift.Player
{
    [RequireComponent(typeof(PlayerMovement))]
    [RequireComponent(typeof(PlayerHealth))]
    public class PlayerController : MonoBehaviour
    {
        public int playerIndex = 1;
        private PlayerMovement movement;
        private PlayerHealth health;

        private void Awake()
        {
            movement = GetComponent<PlayerMovement>();
            health = GetComponent<PlayerHealth>();
        }

        private void OnEnable()
        {
            var mapName = playerIndex == 1 ? "PlayerOne" : "PlayerTwo";
            var map = InputManager.Instance?.GetActionMap(mapName);
            map?.Enable();

            var shoot = map?.FindAction("Shoot");
            shoot?.performed += OnShoot;

            var ult = map?.FindAction("Ultimate");
            ult?.performed += OnUltimate;

            var interact = map?.FindAction("Interact");
            interact?.performed += OnInteract;
        }

        private void OnDisable()
        {
            var mapName = playerIndex == 1 ? "PlayerOne" : "PlayerTwo";
            var map = InputManager.Instance?.GetActionMap(mapName);

            var shoot = map?.FindAction("Shoot");
            if (shoot != null) shoot.performed -= OnShoot;

            var ult = map?.FindAction("Ultimate");
            if (ult != null) ult.performed -= OnUltimate;

            var interact = map?.FindAction("Interact");
            if (interact != null) interact.performed -= OnInteract;

            map?.Disable();
        }

        private void OnShoot(InputAction.CallbackContext ctx)
        {
            // Wire to weapon system later; publish event for now
            MessageBroker.Publish(new PlayerShootEvent(this));
        }

        private void OnUltimate(InputAction.CallbackContext ctx)
        {
            MessageBroker.Publish(new PlayerUltimateEvent(this));
        }

        private void OnInteract(InputAction.CallbackContext ctx)
        {
            MessageBroker.Publish(new PlayerInteractEvent(this));
        }
    }

    public readonly struct PlayerShootEvent
    {
        public PlayerController Player { get; }
        public PlayerShootEvent(PlayerController p) { Player = p; }
    }

    public readonly struct PlayerUltimateEvent
    {
        public PlayerController Player { get; }
        public PlayerUltimateEvent(PlayerController p) { Player = p; }
    }

    public readonly struct PlayerInteractEvent
    {
        public PlayerController Player { get; }
        public PlayerInteractEvent(PlayerController p) { Player = p; }
    }
}
