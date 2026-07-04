using UnityEngine;

namespace AstraRift.Managers
{
    public class UIManager : MonoBehaviour
    {
        public static UIManager Instance { get; private set; }

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

        public void TogglePauseMenu(bool isVisible)
        {
            MessageBroker.Publish(new PauseMenuToggledEvent(isVisible));
        }
    }

    public readonly struct PauseMenuToggledEvent
    {
        public bool IsVisible { get; }

        public PauseMenuToggledEvent(bool isVisible)
        {
            IsVisible = isVisible;
        }
    }
}
