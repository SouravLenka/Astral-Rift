using UnityEngine;
using UnityEngine.InputSystem;
using System.Collections;
using AstraRift.Managers;

namespace AstraRift.Player
{
    [RequireComponent(typeof(Collider2D))]
    public class PlayerMovement : UnityEngine.MonoBehaviour
    {
        public int playerIndex = 1; // 1 or 2
        [SerializeField] private PlayerShipStats stats;
        [Header("Movement Area")]
        [Tooltip("World-space rectangle representing allowed play area: x,y,width,height")]
        public Rect playArea = new Rect(-12f, -6f, 24f, 12f);

        private PlayerHealth healthComp;
        private float temporarySpeedMultiplier = 1f;

        private Vector2 inputMove;
        private Vector2 velocity;
        private bool isDashing;
        private float dashCooldownTimer;

        private void Awake()
        {
            healthComp = GetComponent<PlayerHealth>();
        }

        private void OnEnable()
        {
            var mapName = playerIndex == 1 ? "PlayerOne" : "PlayerTwo";
            var map = AstraRift.Managers.InputManager.Instance?.GetActionMap(mapName);
            map?.Enable();
            var moveAction = map?.FindAction("Move");
            moveAction?.performed += OnMovePerformed;
            moveAction?.canceled += OnMoveCanceled;
            var dashAction = map?.FindAction("Dash");
            dashAction?.performed += OnDashPerformed;
        }

        private void OnDisable()
        {
            var mapName = playerIndex == 1 ? "PlayerOne" : "PlayerTwo";
            var map = AstraRift.Managers.InputManager.Instance?.GetActionMap(mapName);
            var moveAction = map?.FindAction("Move");
            moveAction?.performed -= OnMovePerformed;
            moveAction?.canceled -= OnMoveCanceled;
            var dashAction = map?.FindAction("Dash");
            dashAction?.performed -= OnDashPerformed;
            map?.Disable();
        }

        private void OnMovePerformed(InputAction.CallbackContext ctx)
        {
            inputMove = ctx.ReadValue<Vector2>();
        }

        private void OnMoveCanceled(InputAction.CallbackContext ctx)
        {
            inputMove = Vector2.zero;
        }

        private void OnDashPerformed(InputAction.CallbackContext ctx)
        {
            TryDash();
        }

        private void Update()
        {
            if (stats == null) return;

            dashCooldownTimer -= Time.deltaTime;

            if (!isDashing)
            {
                var targetVel = inputMove.normalized * stats.moveSpeed * temporarySpeedMultiplier;
                velocity = Vector2.MoveTowards(velocity, targetVel, stats.acceleration * Time.deltaTime);
                transform.Translate((Vector3)velocity * Time.deltaTime);

                // enforce play area bounds
                var pos = transform.position;
                pos.x = Mathf.Clamp(pos.x, playArea.xMin, playArea.xMax);
                pos.y = Mathf.Clamp(pos.y, playArea.yMin, playArea.yMax);
                transform.position = pos;

                if (inputMove.sqrMagnitude > 0.01f)
                {
                    var angle = Mathf.Atan2(inputMove.y, inputMove.x) * Mathf.Rad2Deg;
                    transform.rotation = Quaternion.Lerp(transform.rotation, Quaternion.Euler(0, 0, angle - 90f), 10f * Time.deltaTime);
                }
            }
        }

        private void TryDash()
        {
            if (dashCooldownTimer > 0f || isDashing || stats == null) return;
            StartCoroutine(DashRoutine());
        }

        private IEnumerator DashRoutine()
        {
            isDashing = true;
            dashCooldownTimer = stats.dashCooldown;

            healthComp?.SetInvulnerable(true);

            var dir = inputMove.sqrMagnitude > 0.01f ? inputMove.normalized : transform.up;
            var start = transform.position;
            var end = start + (Vector3)dir * stats.dashDistance;
            var elapsed = 0f;
            var duration = stats.dashInvulnerability;

            MessageBroker.Publish(new PlayerDashEvent(this));

            while (elapsed < duration)
            {
                transform.position = Vector3.Lerp(start, end, elapsed / duration);
                elapsed += Time.deltaTime;
                yield return null;
            }

            transform.position = end;
            isDashing = false;

            healthComp?.SetInvulnerable(false);
        }

        public void SetTemporarySpeedMultiplier(float multiplier)
        {
            temporarySpeedMultiplier = Mathf.Max(0.01f, multiplier);
        }

        public void ResetTemporarySpeedMultiplier()
        {
            temporarySpeedMultiplier = 1f;
        }
    }

    public readonly struct PlayerDashEvent
    {
        public PlayerMovement Player { get; }
        public PlayerDashEvent(PlayerMovement player) { Player = player; }
    }
}
