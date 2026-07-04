using UnityEngine;

namespace AstraRift.Managers
{
    public enum GameState
    {
        MainMenu,
        Loading,
        Gameplay,
        Paused,
        UpgradeSelection,
        BossIntro,
        Victory,
        GameOver,
        Transition
    }

    public class GameManager : MonoBehaviour
    {
        public static GameManager Instance { get; private set; }

        public GameState CurrentState { get; private set; } = GameState.MainMenu;

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

        private void Start()
        {
            SetState(GameState.MainMenu);
        }

        public void SetState(GameState newState)
        {
            if (CurrentState == newState)
                return;

            CurrentState = newState;
            MessageBroker.Publish(new GameStateChangedEvent(newState));
        }
    }

    public readonly struct GameStateChangedEvent
    {
        public GameState NewState { get; }

        public GameStateChangedEvent(GameState newState)
        {
            NewState = newState;
        }
    }
}
