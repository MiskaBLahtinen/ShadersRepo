using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

public class GameOfLife : MonoBehaviour
{
    public enum Init { RPentomino, Acorn, GosperGun, FullTexture }

    [SerializeField] private ComputeShader  Simulator;
    [SerializeField] private Material planeMaterial;
    [SerializeField] Color cellCol;
    [SerializeField] Init seed;
    [SerializeField, Range(0f, 2f)] float updateInterval;

    private float nextUpdate = 2f;
    static readonly Vector2Int textureSize = new Vector2Int(512, 512);

    private RenderTexture State1;
    private RenderTexture State2;
    bool isState1;

    private static int Update1Kernel;
    private static int Update2Kernel;

    private static int RPentominoKernel;
    private static int AcornKernel;
    private static int GosperGunKernel;
    private static int FullTextureKernel;

    private static readonly int BaseMap = Shader.PropertyToID("_BaseMap");
    private static readonly int CellColour = Shader.PropertyToID("cellColor");
    private static readonly int State1Tex = Shader.PropertyToID("State1");
    private static readonly int State2Tex = Shader.PropertyToID("State2");


    // Start is called before the first frame update
    void Start()
    {
        State1 = new RenderTexture(textureSize.x, textureSize.y, 0, DefaultFormat.LDR)
        {
            enableRandomWrite = true, filterMode = FilterMode.Point
        };

        State1.Create();

        State2 = new RenderTexture(textureSize.x, textureSize.y, 0, DefaultFormat.LDR)
        {
            enableRandomWrite = true,
            filterMode = FilterMode.Point
        };

        State2.Create();

        //Update1Kernel = Simulator.FindKernel("Update1");
        //Update2Kernel = Simulator.FindKernel("Update2");
        //RPentominoKernel = Simulator.FindKernel("InitRPentomino");
        //AcornKernel = Simulator.FindKernel("InitAcorn");
        //GosperGunKernel = Simulator.FindKernel("InitGun");
        //FullTextureKernel = Simulator.FindKernel("InitFullTexture");

        Simulator.SetTexture(Update1Kernel, State1Tex, State1);
        Simulator.SetTexture(Update1Kernel, State2Tex, State2);

        Simulator.SetTexture(Update2Kernel, State1Tex, State1);
        Simulator.SetTexture(Update2Kernel, State2Tex, State2);

        Simulator.SetTexture(RPentominoKernel, State1Tex, State1);
        Simulator.SetTexture(AcornKernel, State1Tex, State1);
        Simulator.SetTexture(GosperGunKernel, State1Tex, State1);
        Simulator.SetTexture(FullTextureKernel, State1Tex, State1);

        Simulator.SetVector(CellColour, cellCol);

        switch(seed)
        {
            case Init.Acorn:
                Simulator.Dispatch(AcornKernel, 512 / 8, 512 / 8, 1);
                break;
            case Init.RPentomino:
                Simulator.Dispatch(RPentominoKernel, 512 / 8, 512 / 8, 1);
                break;
            case Init.GosperGun:
                Simulator.Dispatch(GosperGunKernel, 512 / 8, 512 / 8, 1);
                break;
            case Init.FullTexture:
                Simulator.Dispatch(FullTextureKernel, 512 / 8, 512 / 8, 1);
                break;
        }
    }

    void Update()
    {
        if (Time.time < nextUpdate) return;

        isState1 = !isState1;

        planeMaterial.SetTexture(BaseMap, isState1 ? State1 : State2);
        nextUpdate = Time.time + updateInterval;
    }

    private void OnDisable()
    {
        State1.Release();
        State2.Release();
    }

    private void OnDestroy()
    {
        State1.Release();
        State2.Release();
    }
}

