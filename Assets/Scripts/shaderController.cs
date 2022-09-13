using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class shaderController : MonoBehaviour
{
    //passed data
    public Shader shader;
    private Material material;
    private Camera cam;
    private RenderTexture lastFrame;

    //public vars
    public int basePrecision;
    public int passes;
    [Range(0.001f, 1.0f)]
    public float threshold;
    public float gridOffset;

    //temp RenderTexture for lastFrame data
    private RenderTexture temp;

    private void Awake()
    {
        //gets the camera component
        cam = GetComponent<Camera>();

        //sets up material
        material = new Material(shader);

        //instantiates middle rendertexture
        temp = RenderTexture.GetTemporary(cam.pixelWidth, cam.pixelHeight);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        setVars();

        //doesn't allow these values to change in realtime
        checkMinsAndMaxes();

        //gets rendertexture info and sets last frame as well for blurring effect
        Graphics.Blit(source, temp, material);
        Graphics.Blit(temp, destination);
        lastFrame = temp;

        //releases temp
        RenderTexture.ReleaseTemporary(temp);
    }

    private void checkMinsAndMaxes()
    {
        //doesn't allow the threshold to go outside 0 and 1
        threshold = (threshold <= 0) ? 0.001f : (threshold > 1) ? 1 : threshold;

        //doesn't allow passes to go outside 1 and 100
        passes = (passes < 1) ? 1 : (passes > 100) ? 100 : passes;

        //doesn't allow basePrecision to go below 1
        basePrecision = (basePrecision < 1) ? 1 : basePrecision;

        //doesn't allow gridOffset to go below 0
        gridOffset = (gridOffset < 0) ? 0 : gridOffset;
    }

    private void setVars()
    {
        //sets vars
        material.SetFloat("_GridOffset", gridOffset);
        material.SetTexture("_LastFrame", lastFrame);
        material.SetFloat("_Threshold", threshold);
        material.SetInt("_Passes", passes);
        material.SetInt("_Precision", basePrecision);
        material.SetFloat("_PassedTime", Time.time);
    }
}
