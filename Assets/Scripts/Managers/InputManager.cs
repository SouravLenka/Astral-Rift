using UnityEngine;
using UnityEngine.InputSystem;

namespace AstraRift.Managers
{
    public class InputManager : MonoBehaviour
    {
        public static InputManager Instance { get; private set; }

        [SerializeField] private InputActionAsset inputActions;

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

        private void OnEnable()
        {
            inputActions?.Enable();
        }

        private void OnDisable()
        {
            inputActions?.Disable();
        }

        public InputActionMap GetActionMap(string mapName)
        {
            return inputActions?.FindActionMap(mapName);
        }

        // Allow assigning the InputActionAsset at runtime (used by Bootstrapper)
        public void SetInputActionAsset(InputActionAsset asset)
        {
            if (inputActions != null && inputActions.enabled)
                inputActions.Disable();

            inputActions = asset;

            if (isActiveAndEnabled)
                inputActions?.Enable();
        }
    }
}
