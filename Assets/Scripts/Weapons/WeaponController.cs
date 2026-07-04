using UnityEngine;

namespace AstraRift.Weapons
{
    [RequireComponent(typeof(WeaponBase))]
    public class WeaponController : MonoBehaviour
    {
        [SerializeField] private WeaponData weaponData;
        private WeaponBase weaponBase;

        private void Awake()
        {
            weaponBase = GetComponent<WeaponBase>();
        }

        private void Start()
        {
            // Assign data to weapon base if not null
            if (weaponData != null && weaponBase != null)
            {
                // reflection or direct field not accessible; rely on inspector to set WeaponBase's data
            }
        }

        public void SetWeapon(WeaponData data)
        {
            weaponData = data;
            // If needed, we could add a method on WeaponBase to accept the data; for now use inspector
        }
    }
}
