using UnityEngine;

namespace AstraRift.PowerUps
{
    public enum PowerUpType
    {
        TripleShot,
        ShieldRestore,
        RapidFire,
        SpeedBoost,
        EMP,
        FreezeTime,
        DoubleDamage
    }

    [CreateAssetMenu(menuName = "AstraRift/PowerUps/PowerUpData")]
    public class PowerUpData : ScriptableObject
    {
        public string displayName = "Power-Up";
        public Sprite icon;
        public PowerUpType type;
        public float duration = 8f;
        public float multiplier = 1f;
        public int shieldRestore = 25;
        public bool stackable = false;
        public bool instantEffect = false;
    }
}
