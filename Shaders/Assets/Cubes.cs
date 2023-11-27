using UnityEngine;
using UnityEngine.Rendering;

public class Cubes : MonoBehaviour
{
    [SerializeField, Range(0f, 360f)] float angle;
    [SerializeField, Range(0f, 40f)] float frequence;
    [SerializeField] ComputeShader cubeShader;
    [SerializeField] Mesh cubeMesh;
    [SerializeField] Material cubeMaterial;

    static int SimulationKernel;

    static readonly int direction = Shader.PropertyToID("dir");
    static readonly int positions = Shader.PropertyToID("positions");
    static readonly int time = Shader.PropertyToID("time");
    static readonly int freq = Shader.PropertyToID("frequency");

    private const int cubeAmount = 128 * 128;
    Vector4[] cubePositions = new Vector4[cubeAmount];
    Matrix4x4[] cubeMatrices = new Matrix4x4[cubeAmount];

    ComputeBuffer cubeBuffer;
    AsyncGPUReadbackRequest GPURequest;

    void PopulateCubes(Vector4[] positions)
    {
        for(uint x = 0; x < 128; ++x)
            for(uint y = 0; y < 128; ++y)
            {
                uint idx = x * 128 + y;
                positions[idx] = new Vector4(x / 128.0f, 0, y / 128.0f);
            }
    }

    // Start is called before the first frame update
    void Start()
    {
        SimulationKernel = cubeShader.FindKernel("Simulate");
        cubeBuffer = new ComputeBuffer(cubeAmount, 4 * sizeof(float));
        PopulateCubes(cubePositions);
        cubeBuffer.SetData(cubePositions);

        cubeShader.SetBuffer(SimulationKernel, positions, cubeBuffer);
        DispatchCubes();

        GPURequest = AsyncGPUReadback.Request(cubeBuffer);
    }

    void DispatchCubes()
    {
        Vector2 dir = new Vector2(Mathf.Cos(Mathf.Deg2Rad * angle), Mathf.Sin(Mathf.Deg2Rad * angle));
        cubeShader.SetFloat(time, Time.time);
        cubeShader.SetFloat(freq, frequence);
        cubeShader.SetVector(direction, dir);

        cubeShader.Dispatch(SimulationKernel, 128 / 8, 128 / 8, 1);
    }

    // Update is called once per frame
    void Update()
    {
        if(GPURequest.done)
        {
            cubePositions = GPURequest.GetData<Vector4>().ToArray();
            for (int i = 0; i < cubeAmount; ++i)
                cubeMatrices[i] = Matrix4x4.TRS((Vector3)cubePositions[i] + transform.position, Quaternion.identity, Vector3.one * (1 / 128f));

            GPURequest = AsyncGPUReadback.Request(cubeBuffer);
        }

        DispatchCubes();
        
        Graphics.DrawMeshInstanced(cubeMesh, 0, cubeMaterial, cubeMatrices);
    }

    private void OnDisable()
    {
        cubeBuffer.Release();
    }

    private void OnDestroy()
    {
        cubeBuffer.Release();
    }
}
