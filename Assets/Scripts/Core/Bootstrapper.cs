using UnityEngine;
using UnityEngine.InputSystem;
using AstraRift.Enemy;
using AstraRift.Game;
using AstraRift.Managers;
using AstraRift.Player;
using AstraRift.PowerUps;
using AstraRift.Weapons;

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

            if (WaveManager.Instance == null)
            {
                var wm = new GameObject("WaveManager");
                wm.AddComponent<WaveManager>();
            }

            if (PowerUpManager.Instance == null)
            {
                var pm = new GameObject("PowerUpManager");
                pm.AddComponent<PowerUpManager>();
            }

            if (FindObjectOfType<ReviveSystem>() == null)
            {
                var rs = new GameObject("ReviveSystem");
                rs.AddComponent<ReviveSystem>();
            }

            if (FindObjectOfType<PoolManager>() == null)
            {
                var pool = new GameObject("PoolManager");
                pool.AddComponent<PoolManager>();
            }

            if (AudioManager.Instance != null)
            {
                AssignAudioSources(AudioManager.Instance);
            }
        }

        private void AssignAudioSources(AudioManager audioManager)
        {
            if (audioManager == null)
                return;

            if (audioManager.GetType().GetField("musicSource", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.GetValue(audioManager) == null)
                CreateAndAssignAudioSource(audioManager, "musicSource", true, true);
            if (audioManager.GetType().GetField("sfxSource", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.GetValue(audioManager) == null)
                CreateAndAssignAudioSource(audioManager, "sfxSource", false, false);
            if (audioManager.GetType().GetField("ambientSource", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.GetValue(audioManager) == null)
                CreateAndAssignAudioSource(audioManager, "ambientSource", false, false);
            if (audioManager.GetType().GetField("uiSource", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.GetValue(audioManager) == null)
                CreateAndAssignAudioSource(audioManager, "uiSource", false, false);
        }

        private void CreateAndAssignAudioSource(AudioManager audioManager, string fieldName, bool loop, bool playOnAwake)
        {
            var sourceGO = new GameObject(fieldName + "Source");
            sourceGO.transform.SetParent(audioManager.transform, false);
            var source = sourceGO.AddComponent<AudioSource>();
            source.loop = loop;
            source.playOnAwake = playOnAwake;
            var field = audioManager.GetType().GetField(fieldName, System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
            field?.SetValue(audioManager, source);
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

        private void Start()
        {
            EnsureRuntimeEntities();
        }

        private void EnsureRuntimeEntities()
        {
            defaultPlayerStats ??= CreateDefaultPlayerStats();
            defaultProjectilePrefab ??= CreateDefaultProjectilePrefab();
            defaultEnemyPrefab ??= CreateDefaultEnemyPrefab();
            defaultWeaponData ??= CreateDefaultWeaponData();

            if (FindObjectOfType<PlayerController>() == null)
            {
                CreateDefaultPlayer();
            }

            if (FindObjectOfType<EnemySpawner>() == null)
            {
                CreateDefaultEnemySpawner();
            }
        }

        private void CreateDefaultPlayer()
        {
            var playerGO = new GameObject("Player");
            var renderer = playerGO.AddComponent<SpriteRenderer>();
            renderer.sortingLayerName = "Default";
            renderer.color = Color.cyan;

            var rb = playerGO.AddComponent<Rigidbody2D>();
            rb.gravityScale = 0f;
            rb.freezeRotation = true;

            playerGO.AddComponent<BoxCollider2D>();
            var pc = playerGO.AddComponent<PlayerController>();
            var pm = playerGO.AddComponent<PlayerMovement>();
            var ph = playerGO.AddComponent<PlayerHealth>();

            SetPrivateField(pm, "stats", defaultPlayerStats);
            SetPrivateField(ph, "stats", defaultPlayerStats);

            var weaponBase = playerGO.AddComponent<WeaponBase>();
            var firePoint = new GameObject("FirePoint");
            firePoint.transform.SetParent(playerGO.transform, false);
            firePoint.transform.localPosition = new Vector3(0f, 0.6f, 0f);
            SetPrivateField(weaponBase, "firePoint", firePoint.transform);
            SetPrivateField(weaponBase, "data", defaultWeaponData);

            playerGO.transform.position = Vector3.zero;
        }

        private void CreateDefaultEnemySpawner()
        {
            var spawnerGO = new GameObject("EnemySpawner");
            var spawner = spawnerGO.AddComponent<EnemySpawner>();
            SetPrivateField(spawner, "enemyPrefab", defaultEnemyPrefab);

            if (WaveManager.Instance != null)
            {
                var spawnerField = typeof(WaveManager).GetField("spawner", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Public);
                spawnerField?.SetValue(WaveManager.Instance, spawner);
            }
        }

        private GameObject CreateDefaultProjectilePrefab()
        {
            var projGO = new GameObject("DefaultProjectilePrefab");
            var renderer = projGO.AddComponent<SpriteRenderer>();
            renderer.color = Color.yellow;
            var collider = projGO.AddComponent<CircleCollider2D>();
            collider.isTrigger = true;
            var rb = projGO.AddComponent<Rigidbody2D>();
            rb.gravityScale = 0f;
            rb.bodyType = RigidbodyType2D.Kinematic;
            rb.freezeRotation = true;
            var projComp = projGO.AddComponent<Projectile>();
            projComp.lifetime = 5f;
            projGO.SetActive(false);
            DontDestroyOnLoad(projGO);
            return projGO;
        }

        private GameObject CreateDefaultEnemyPrefab()
        {
            var enemyGO = new GameObject("DefaultEnemyPrefab");
            var renderer = enemyGO.AddComponent<SpriteRenderer>();
            renderer.color = Color.red;
            enemyGO.AddComponent<CircleCollider2D>();
            var rb = enemyGO.AddComponent<Rigidbody2D>();
            rb.gravityScale = 0f;
            rb.freezeRotation = true;
            enemyGO.AddComponent<DebugEnemy>();
            enemyGO.SetActive(false);
            DontDestroyOnLoad(enemyGO);
            return enemyGO;
        }

        private PlayerShipStats CreateDefaultPlayerStats()
        {
            var stats = ScriptableObject.CreateInstance<PlayerShipStats>();
            stats.shipName = "Nova";
            stats.maxHealth = 100;
            stats.maxShield = 50;
            stats.lives = 3;
            stats.moveSpeed = 6f;
            stats.acceleration = 20f;
            stats.deceleration = 15f;
            stats.dashDistance = 6f;
            stats.dashCooldown = 2f;
            stats.dashInvulnerability = 0.4f;
            return stats;
        }

        private WeaponData CreateDefaultWeaponData()
        {
            var data = ScriptableObject.CreateInstance<WeaponData>();
            data.weaponName = "Laser";
            data.damage = 8;
            data.fireRate = 8f;
            data.projectilePrefab = defaultProjectilePrefab;
            data.projectileSpeed = 14f;
            data.spreadAngle = 0f;
            return data;
        }

        private void SetPrivateField(object target, string fieldName, object value)
        {
            var field = target.GetType().GetField(fieldName, System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Public);
            if (field != null)
                field.SetValue(target, value);
        }
    }
}
