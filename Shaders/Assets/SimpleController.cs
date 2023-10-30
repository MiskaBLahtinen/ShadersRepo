using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class SimpleController : MonoBehaviour
{
    [SerializeField]
    private Material m_Material;
    private static int playerPosId = Shader.PropertyToID(name: "_PlayerPosition");

    // Update is called once per frame
    void Update()
    {
        Vector3 movement = Vector3.zero;

        if (Input.GetKey(KeyCode.A))
            movement += Vector3.left;
        if (Input.GetKey(KeyCode.D))
            movement += Vector3.right;
        if (Input.GetKey(KeyCode.W))
            movement += Vector3.forward;
        if (Input.GetKey(KeyCode.S))
            movement += Vector3.back;

        transform.Translate(Time.deltaTime * 5 * movement.normalized, relativeTo:Space.World);

        m_Material.SetVector(playerPosId, transform.position);
    }
}
