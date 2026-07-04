using UnityEngine;

namespace AstraRift.Player
{
    [CreateAssetMenu(menuName = "AstraRift/Player/ShipStats")]
    public class PlayerShipStats : ScriptableObject
    {
        public string shipName = "Nova";
        public int maxHealth = 100;
        public int maxShield = 50;
        public int lives = 3;
        public float moveSpeed = 6f;
        public float acceleration = 20f;
        public float deceleration = 15f;
        public float dashDistance = 6f;
        public float dashCooldown = 2f;
        public float dashInvulnerability = 0.4f;
    }
}
