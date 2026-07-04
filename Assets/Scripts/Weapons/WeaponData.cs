using UnityEngine;

namespace AstraRift.Weapons
{
    [CreateAssetMenu(menuName = "AstraRift/Weapons/WeaponData")]
    public class WeaponData : ScriptableObject
    {
        public string weaponName = "New Weapon";
        public int damage = 10;
        public float fireRate = 5f; // shots per second
        public GameObject projectilePrefab;
        public float projectileSpeed = 12f;
        public float spreadAngle = 0f;
        public bool isAutomatic = true;
    }
}
