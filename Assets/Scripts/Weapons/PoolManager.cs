using System.Collections.Generic;
using UnityEngine;

namespace AstraRift.Weapons
{
    public class PoolManager : MonoBehaviour
    {
        public static PoolManager Instance { get; private set; }

        private readonly Dictionary<GameObject, Queue<GameObject>> pools = new Dictionary<GameObject, Queue<GameObject>>();

        private void Awake()
        {
            if (Instance != null && Instance != this) { Destroy(gameObject); return; }
            Instance = this; DontDestroyOnLoad(gameObject);
        }

        public GameObject Spawn(GameObject prefab, Vector3 position, Quaternion rotation)
        {
            if (prefab == null)
                return null;

            if (!pools.TryGetValue(prefab, out var queue))
            {
                queue = new Queue<GameObject>();
                pools[prefab] = queue;
            }

            GameObject instance = null;
            while (queue.Count > 0)
            {
                var candidate = queue.Dequeue();
                if (candidate != null)
                {
                    instance = candidate;
                    break;
                }
            }

            if (instance == null)
            {
                instance = GameObject.Instantiate(prefab, position, rotation);
            }
            else
            {
                instance.transform.position = position;
                instance.transform.rotation = rotation;
                instance.SetActive(true);
            }

            return instance;
        }

        public void Release(GameObject prefab, GameObject instance)
        {
            if (prefab == null || instance == null) return;
            instance.SetActive(false);
            if (!pools.TryGetValue(prefab, out var queue))
            {
                queue = new Queue<GameObject>();
                pools[prefab] = queue;
            }
            queue.Enqueue(instance);
        }
    }
}
