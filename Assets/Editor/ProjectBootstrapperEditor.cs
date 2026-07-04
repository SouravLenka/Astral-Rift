#if UNITY_EDITOR
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;
using AstraRift.Managers;
using AstraRift.Player;
using AstraRift.Weapons;
using AstraRift.Enemy;

public static class ProjectBootstrapperEditor
{
    [MenuItem("Tools/AstraRift/Setup Project (Create Bootstrap Scene & Prefabs)")]
    public static void SetupProject()
    {
        // Create a new scene
        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
        scene.name = "Bootstrap";

        // Create Bootstrapper
        var bootstrapGO = new GameObject("Bootstrapper");
        var bootstrap = bootstrapGO.AddComponent(typeof(AstraRift.Core.Bootstrapper));

        // Ensure Resources/Input/PlayerControls.inputactions exists
        var inputText = AssetDatabase.LoadAssetAtPath<TextAsset>("Assets/Resources/Input/PlayerControls.inputactions.json");
        if (inputText != null)
        {
            var comp = bootstrapGO.GetComponent(typeof(AstraRift.Core.Bootstrapper));
            var field = comp.GetType().GetField("inputActionsJson", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Public);
            if (field != null)
                field.SetValue(comp, inputText);
        }

        // Create Managers
        CreateManager<GameManager>("GameManager");
        CreateManager<AudioManager>("AudioManager", go => {
            var music = go.AddComponent<AudioSource>(); music.playOnAwake = false; music.loop = true;
            var sfx = go.AddComponent<AudioSource>(); sfx.playOnAwake = false;
            var ambient = go.AddComponent<AudioSource>(); ambient.playOnAwake = false;
            var ui = go.AddComponent<AudioSource>(); ui.playOnAwake = false;

            var audioManager = go.GetComponent<AudioManager>();
            var musicField = typeof(AudioManager).GetField("musicSource", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
            var sfxField = typeof(AudioManager).GetField("sfxSource", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
            var ambientField = typeof(AudioManager).GetField("ambientSource", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
            var uiField = typeof(AudioManager).GetField("uiSource", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);

            musicField?.SetValue(audioManager, music);
            sfxField?.SetValue(audioManager, sfx);
            ambientField?.SetValue(audioManager, ambient);
            uiField?.SetValue(audioManager, ui);
        });
        CreateManager<UIManager>("UIManager");
        CreateManager<AstraRift.Managers.InputManager>("InputManager");
        CreateManager<AstraRift.Managers.SceneTransitionManager>("SceneTransitionManager");
        CreateManager<SaveManager>("SaveManager");
        CreateManager<AstraRift.PowerUps.PowerUpManager>("PowerUpManager");
        CreateManager<AstraRift.Player.ReviveSystem>("ReviveSystem");

        // Pool Manager
        var poolGO = new GameObject("PoolManager");
        poolGO.AddComponent<PoolManager>();
        Object.DontDestroyOnLoad(poolGO);

        // Create Projectile prefab
        var projGO = new GameObject("Projectile");
        var sr = projGO.AddComponent<SpriteRenderer>();
        // Note: no sprite assigned; assign in editor later
        var collider = projGO.AddComponent<CircleCollider2D>(); collider.isTrigger = true;
        var projComp = projGO.AddComponent<Projectile>();
        projComp.lifetime = 5f;

        var projectilePrefabPath = "Assets/Prefabs/Projectile.prefab";
        System.IO.Directory.CreateDirectory("Assets/Prefabs");
        var projectilePrefab = PrefabUtility.SaveAsPrefabAsset(projGO, projectilePrefabPath);
        Object.DestroyImmediate(projGO);

        // Create WeaponData assets
        System.IO.Directory.CreateDirectory("Assets/ScriptableObjects/Weapons");

        CreateWeaponAsset("Laser", 8, 8f, projectilePrefab, 14f, 0f);
        CreateWeaponAsset("Plasma", 18, 1.5f, projectilePrefab, 9f, 12f);
        CreateWeaponAsset("MachineBlaster", 5, 12f, projectilePrefab, 16f, 6f);

        // Create PlayerShipStats asset
        System.IO.Directory.CreateDirectory("Assets/ScriptableObjects/Player");
        var stats = ScriptableObject.CreateInstance<PlayerShipStats>();
        stats.shipName = "Nova";
        stats.maxHealth = 100;
        stats.maxShield = 50;
        stats.lives = 3;
        stats.moveSpeed = 6f;
        stats.acceleration = 20f;
        stats.deceleration = 15f;
        AssetDatabase.CreateAsset(stats, "Assets/ScriptableObjects/Player/NovaStats.asset");

        // Create Player prefab
        var playerGO = new GameObject("Player_Prefab");
        var spr = playerGO.AddComponent<SpriteRenderer>();
        spr.sortingLayerName = "Default";
        playerGO.AddComponent<BoxCollider2D>();
        var pc = playerGO.AddComponent<AstraRift.Player.PlayerController>();
        var pm = playerGO.AddComponent<AstraRift.Player.PlayerMovement>();
        var ph = playerGO.AddComponent<AstraRift.Player.PlayerHealth>();

        // assign stats to components
        var statsAsset = AssetDatabase.LoadAssetAtPath<PlayerShipStats>("Assets/ScriptableObjects/Player/NovaStats.asset");
        pm.GetType().GetField("stats", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Public)?.SetValue(pm, statsAsset);
        ph.GetType().GetField("stats", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Public)?.SetValue(ph, statsAsset);

        // add WeaponBase and fire point
        var weaponBase = playerGO.AddComponent<AstraRift.Weapons.WeaponBase>();
        var firePoint = new GameObject("FirePoint");
        firePoint.transform.SetParent(playerGO.transform, false);
        firePoint.transform.localPosition = new Vector3(0, 0.6f, 0);
        weaponBase.GetType().GetField("firePoint", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Public)?.SetValue(weaponBase, firePoint.transform);

        // assign weapon data (Laser)
        var laser = AssetDatabase.LoadAssetAtPath<WeaponData>("Assets/ScriptableObjects/Weapons/Laser.asset");
        weaponBase.GetType().GetField("data", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Public)?.SetValue(weaponBase, laser);

        var playerPrefabPath = "Assets/Prefabs/Player.prefab";
        var playerPrefab = PrefabUtility.SaveAsPrefabAsset(playerGO, playerPrefabPath);
        Object.DestroyImmediate(playerGO);

        // Create Enemy prefab
        var enemyGO = new GameObject("Enemy_Prefab");
        var esr = enemyGO.AddComponent<SpriteRenderer>();
        enemyGO.AddComponent<CircleCollider2D>().isTrigger = true;
        var debugEnemy = enemyGO.AddComponent<AstraRift.Enemy.DebugEnemy>();
        var enemyPrefabPath = "Assets/Prefabs/Enemy.prefab";
        var enemyPrefab = PrefabUtility.SaveAsPrefabAsset(enemyGO, enemyPrefabPath);
        Object.DestroyImmediate(enemyGO);

        // Add spawner to scene
        var spawnerGO = new GameObject("EnemySpawner");
        var spawner = spawnerGO.AddComponent<AstraRift.Enemy.EnemySpawner>();
        spawner.GetType().GetField("enemyPrefab", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Public)?.SetValue(spawner, enemyPrefab);

        // Add WaveManager and wire the spawner
        var waveGO = new GameObject("WaveManager");
        var waveManager = waveGO.AddComponent<AstraRift.Game.WaveManager>();
        Object.DontDestroyOnLoad(waveGO);
        var spawnerField = typeof(AstraRift.Game.WaveManager).GetField("spawner", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Public);
        spawnerField?.SetValue(waveManager, spawner);

        // Save scene to Assets/Scenes/Bootstrap.unity
        System.IO.Directory.CreateDirectory("Assets/Scenes");
        EditorSceneManager.SaveScene(scene, "Assets/Scenes/Bootstrap.unity");

        EditorBuildSettingsScene[] enabledScenes = EditorBuildSettings.scenes;
        if (!enabledScenes.Any(s => s.path == "Assets/Scenes/Bootstrap.unity"))
        {
            var newScene = new EditorBuildSettingsScene("Assets/Scenes/Bootstrap.unity", true);
            var scenes = enabledScenes.Append(newScene).ToArray();
            EditorBuildSettings.scenes = scenes;
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        EditorUtility.DisplayDialog("AstraRift Setup", "Bootstrap scene, prefabs, and starter assets created. Open Unity and run the Bootstrap scene.", "OK");
    }

    private static void CreateManager<T>(string name, System.Action<GameObject> configure = null) where T : MonoBehaviour
    {
        var go = new GameObject(name);
        go.AddComponent<T>();
        configure?.Invoke(go);
        Object.DontDestroyOnLoad(go);
    }

    private static void CreateWeaponAsset(string name, int damage, float fireRate, GameObject projectilePrefab, float projSpeed, float spread)
    {
        var asset = ScriptableObject.CreateInstance<WeaponData>();
        asset.weaponName = name;
        asset.damage = damage;
        asset.fireRate = fireRate;
        asset.projectilePrefab = projectilePrefab;
        asset.projectileSpeed = projSpeed;
        asset.spreadAngle = spread;
        var path = $"Assets/ScriptableObjects/Weapons/{name}.asset";
        AssetDatabase.CreateAsset(asset, path);
    }
}
#endif
