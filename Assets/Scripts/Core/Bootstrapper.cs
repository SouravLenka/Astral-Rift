using UnityEngine;
using UnityEngine.InputSystem;
using AstraRift.Managers;

namespace AstraRift.Core
{
    public class Bootstrapper : MonoBehaviour
    {
        [SerializeField] private TextAsset inputActionsJson;

        private void Awake()
        {
            EnsureManagersExist();
            LoadInputActions();
        }

        private void EnsureManagersExist()
        {
            if (GameManager.Instance == null)
            {
                var gm = new GameObject("GameManager");
                gm.AddComponent<GameManager>();
            }

            if (AudioManager.Instance == null)
            {
                var am = new GameObject("AudioManager");
                am.AddComponent<AudioManager>();
            }

            if (UIManager.Instance == null)
            {
                var ui = new GameObject("UIManager");
                ui.AddComponent<UIManager>();
            }

            if (InputManager.Instance == null)
            {
                var im = new GameObject("InputManager");
                im.AddComponent<InputManager>();
            }

            if (SceneTransitionManager.Instance == null)
            {
                var sm = new GameObject("SceneTransitionManager");
                sm.AddComponent<SceneTransitionManager>();
            }

            if (SaveManager.Instance == null)
            {
                var sm = new GameObject("SaveManager");
                sm.AddComponent<SaveManager>();
            }
        }

        private void LoadInputActions()
        {
            if (inputActionsJson == null)
            {
                var ta = Resources.Load<TextAsset>("Input/PlayerControls.inputactions");
                inputActionsJson = ta;
            }

            if (inputActionsJson == null)
                return;

            var inputAsset = InputActionAsset.FromJson(inputActionsJson.text);
            if (InputManager.Instance != null && inputAsset != null)
            {
                InputManager.Instance.SetInputActionAsset(inputAsset);
            }
        }
    }
}
