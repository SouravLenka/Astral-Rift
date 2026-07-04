using UnityEngine;
using System.Collections;
using AstraRift.Interfaces;
using AstraRift.Player;

namespace AstraRift.Enemy
{
    [RequireComponent(typeof(Rigidbody2D))]
    public class EnemyBase : MonoBehaviour, IDamageable
    {
        public enum State { Spawning, Idle, Patrol, Chase, Attack, Stunned, Dead }

        [Header("Stats")]
        public int maxHealth = 50;
        public float moveSpeed = 2.5f;
        public float detectionRadius = 6f;
        public float attackRange = 1.2f;
        public int contactDamage = 10;

        private int currentHealth;
        private State currentState = State.Spawning;
        private Transform targetPlayer;
        private Rigidbody2D rb;

        private void Awake()
        {
            currentHealth = maxHealth;
            rb = GetComponent<Rigidbody2D>();
            StartCoroutine(StateRoutine());
        }

        private IEnumerator StateRoutine()
        {
            yield return new WaitForSeconds(0.1f);
            currentState = State.Idle;

            while (currentState != State.Dead)
            {
                switch (currentState)
                {
                    case State.Idle:
                        FindTarget();
                        if (targetPlayer != null) currentState = State.Chase;
                        break;
                    case State.Patrol:
                        PatrolBehavior();
                        FindTarget();
                        if (targetPlayer != null) currentState = State.Chase;
                        break;
                    case State.Chase:
                        if (targetPlayer == null) { currentState = State.Idle; break; }
                        var dist = Vector2.Distance(transform.position, targetPlayer.position);
                        if (dist <= attackRange) currentState = State.Attack;
                        else ChaseBehavior();
                        break;
                    case State.Attack:
                        if (targetPlayer == null) { currentState = State.Idle; break; }
                        var d = Vector2.Distance(transform.position, targetPlayer.position);
                        if (d > attackRange) currentState = State.Chase;
                        else AttackBehavior();
                        break;
                    case State.Stunned:
                        // skip for now
                        break;
                }
                yield return null;
            }
        }

        private void FindTarget()
        {
            var players = FindObjectsOfType<PlayerController>();
            Transform closest = null;
            float best = float.MaxValue;
            foreach (var p in players)
            {
                if (p == null) continue;
                var dist = Vector2.Distance(transform.position, p.transform.position);
                if (dist < best && dist <= detectionRadius)
                {
                    best = dist;
                    closest = p.transform;
                }
            }
            targetPlayer = closest;
        }

        private void PatrolBehavior()
        {
            // Simple idle/patrol placeholder
            rb.velocity = Vector2.zero;
        }

        private void ChaseBehavior()
        {
            if (targetPlayer == null) return;
            var dir = (targetPlayer.position - transform.position).normalized;
            rb.velocity = dir * moveSpeed;
            var angle = Mathf.Atan2(dir.y, dir.x) * Mathf.Rad2Deg;
            transform.rotation = Quaternion.Lerp(transform.rotation, Quaternion.Euler(0,0,angle-90f), 10f * Time.deltaTime);
        }

        private void AttackBehavior()
        {
            // simple contact attack: move slowly towards player
            if (targetPlayer == null) return;
            var dir = (targetPlayer.position - transform.position).normalized;
            rb.velocity = dir * (moveSpeed * 0.6f);
        }

        public void ApplyDamage(int amount)
        {
            if (currentState == State.Dead) return;
            currentHealth -= amount;
            if (currentHealth <= 0) Die();
        }

        private void Die()
        {
            currentState = State.Dead;
            // play death effects, drop loot, etc.
            Destroy(gameObject);
        }

        private void OnCollisionEnter2D(Collision2D collision)
        {
            var player = collision.collider.GetComponent<PlayerController>();
            if (player != null)
            {
                var hp = player.GetComponent<PlayerHealth>();
                if (hp != null)
                {
                    hp.ApplyDamage(contactDamage);
                }
            }
        }
    }
}
