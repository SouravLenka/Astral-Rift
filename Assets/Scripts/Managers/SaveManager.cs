using UnityEngine;
using System.IO;

namespace AstraRift.Managers
{
    public class SaveManager : MonoBehaviour
    {
        public static SaveManager Instance { get; private set; }

        private string savePath;

        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }
            Instance = this;
            DontDestroyOnLoad(gameObject);

            savePath = Path.Combine(Application.persistentDataPath, "save.json");
        }

        public void Save(object data)
        {
            try
            {
                var json = JsonUtility.ToJson(data);
                File.WriteAllText(savePath, json);
            }
            catch (System.Exception ex)
            {
                Debug.LogError($"Failed to save: {ex}");
            }
        }

        public T Load<T>() where T : new()
        {
            try
            {
                if (!File.Exists(savePath))
                    return new T();

                var json = File.ReadAllText(savePath);
                return JsonUtility.FromJson<T>(json);
            }
            catch (System.Exception ex)
            {
                Debug.LogError($"Failed to load: {ex}");
                return new T();
            }
        }
    }
}
