using UnityEngine;

namespace AstraRift.Managers
{
    public class AudioManager : MonoBehaviour
    {
        public static AudioManager Instance { get; private set; }

        [SerializeField] private AudioSource musicSource;
        [SerializeField] private AudioSource sfxSource;
        [SerializeField] private AudioSource ambientSource;
        [SerializeField] private AudioSource uiSource;

        public float MasterVolume { get; private set; } = 1f;
        public float MusicVolume { get; private set; } = 1f;
        public float SfxVolume { get; private set; } = 1f;
        public float AmbientVolume { get; private set; } = 1f;
        public float UiVolume { get; private set; } = 1f;

        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }

        public void PlayMusic(AudioClip clip, bool loop = true)
        {
            if (musicSource == null || clip == null)
                return;

            musicSource.clip = clip;
            musicSource.loop = loop;
            musicSource.volume = MusicVolume * MasterVolume;
            musicSource.Play();
        }

        public void PlaySfx(AudioClip clip)
        {
            if (sfxSource == null || clip == null)
                return;

            sfxSource.PlayOneShot(clip, SfxVolume * MasterVolume);
        }

        public void SetMasterVolume(float value)
        {
            MasterVolume = Mathf.Clamp01(value);
            RefreshVolumes();
        }

        public void SetMusicVolume(float value)
        {
            MusicVolume = Mathf.Clamp01(value);
            RefreshVolumes();
        }

        public void SetSfxVolume(float value)
        {
            SfxVolume = Mathf.Clamp01(value);
        }

        public void SetAmbientVolume(float value)
        {
            AmbientVolume = Mathf.Clamp01(value);
            if (ambientSource != null)
                ambientSource.volume = AmbientVolume * MasterVolume;
        }

        public void SetUiVolume(float value)
        {
            UiVolume = Mathf.Clamp01(value);
        }

        private void RefreshVolumes()
        {
            if (musicSource != null)
                musicSource.volume = MusicVolume * MasterVolume;
            if (ambientSource != null)
                ambientSource.volume = AmbientVolume * MasterVolume;
        }
    }
}
