using Sirenix.OdinInspector;
using UnityEngine;

namespace Playground
{
    [SelectionBase]
    public class WaveShaderController : MonoBehaviour
    {
        [Title("References")]
        [Tooltip("We need this for applying light to our unlit shader")]
        [SerializeField] private Light directionalLight;
        [SerializeField] private Transform dissolveStartingPos;

        [Title("Vertex Deform Coefficients")]
        [Tooltip("Deforming loop speed")]
        [SerializeField] private float animationSpeed;

        [Tooltip("Vertex displacement amount")]
        [SerializeField] private float deformAmount;

        [SerializeField] [Range(0,2)] private float transparencyDistance;

        #region Shader Property IDs

        private static readonly int DissolveStartingPosID = Shader.PropertyToID("_dissolveStartingPos");
        private static readonly int TransparencyDistanceID = Shader.PropertyToID("_transparencyDistance");
        private static readonly int AnimationSpeedID = Shader.PropertyToID("_animationSpeed");
        private static readonly int DeformAmountID = Shader.PropertyToID("_deformAmount");
        private static readonly int LightColorID = Shader.PropertyToID("_lightColor");
        private static readonly int LightDirectionID = Shader.PropertyToID("_lightDirection");

        #endregion
        
        private Renderer rend;

        private void Awake()
        {
            rend = GetComponentInChildren<Renderer>();
        }

        private void Start()
        {
            SetLightPos();
            SetDissolveStartingPos();
        }

        private void Update()
        {
            SetLightColor();
            SetDeformCoeffs();
            SetTransparencyDistance();
        }

        private void SetDissolveStartingPos()
        {
            rend.material.SetVector(DissolveStartingPosID, dissolveStartingPos.position);
        }

        private void SetTransparencyDistance()
        {
            rend.material.SetFloat(TransparencyDistanceID, transparencyDistance);
        }

        private void SetDeformCoeffs()
        {
            rend.material.SetFloat(AnimationSpeedID, animationSpeed);
            rend.material.SetFloat(DeformAmountID, deformAmount);
        }

        private void SetLightColor()
        {
            rend.material.SetColor(LightColorID,directionalLight.color);
        }

        private void SetLightPos()
        {
            rend.material.SetVector(LightDirectionID, directionalLight.transform.forward);
        }
    }
}