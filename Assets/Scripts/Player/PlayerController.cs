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

        private InputActionMap actionMap;
        private InputAction shootAction;
        private InputAction ultimateAction;
        private InputAction interactAction;
        private bool actionsBound;

        private void OnEnable()
        {
            BindInput();
        }

        private void Start()
        {
            if (!actionsBound)
                BindInput();
        }

        private void OnDisable()
        {
            UnbindInput();
        }

        private void BindInput()
        {
            if (actionsBound)
                return;

            if (InputManager.Instance == null)
                return;

            var mapName = playerIndex == 1 ? "PlayerOne" : "PlayerTwo";
            actionMap = InputManager.Instance.GetActionMap(mapName);
            if (actionMap == null)
                return;

            actionMap.Enable();
            shootAction = actionMap.FindAction("Shoot");
            ultimateAction = actionMap.FindAction("Ultimate");
            interactAction = actionMap.FindAction("Interact");

            if (shootAction != null)
                shootAction.performed += OnShoot;
            if (ultimateAction != null)
                ultimateAction.performed += OnUltimate;
            if (interactAction != null)
                interactAction.performed += OnInteract;

            actionsBound = true;
        }

        private void UnbindInput()
        {
            if (!actionsBound)
                return;

            if (shootAction != null)
                shootAction.performed -= OnShoot;
            if (ultimateAction != null)
                ultimateAction.performed -= OnUltimate;
            if (interactAction != null)
                interactAction.performed -= OnInteract;

            actionMap?.Disable();
            actionMap = null;
            shootAction = null;
            ultimateAction = null;
            interactAction = null;
            actionsBound = false;
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
