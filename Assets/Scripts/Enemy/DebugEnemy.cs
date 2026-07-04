using UnityEngine;
using AstraRift.Interfaces;

namespace AstraRift.Enemy
{
    [RequireComponent(typeof(Collider2D))]
    public class DebugEnemy : MonoBehaviour, IDamageable
    {
        [SerializeField] private int maxHealth = 50;
        [SerializeField] private GameObject deathEffect;

        private int currentHealth;

        private void Awake()
        {
            currentHealth = maxHealth;
        }

        public void ApplyDamage(int amount)
        {
            if (amount <= 0) return;
            currentHealth -= amount;
            OnHit(amount);
            if (currentHealth <= 0)
                Die();
        }

        private void OnHit(int amount)
        {
            // simple visual feedback: tint briefly
            var sr = GetComponent<SpriteRenderer>();
            if (sr != null)
            {
                StopAllCoroutines();
                StartCoroutine(HitFlash(sr));
            }
        }

        private System.Collections.IEnumerator HitFlash(SpriteRenderer sr)
        {
            var original = sr.color;
            sr.color = Color.red;
            yield return new WaitForSeconds(0.08f);
            sr.color = original;
        }

        private void Die()
        {
            if (deathEffect != null)
                Instantiate(deathEffect, transform.position, Quaternion.identity);
            Destroy(gameObject);
        }
    }
}
