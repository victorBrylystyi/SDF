
import * as THREE from 'three';
import vertex  from '!!raw-loader!./shaders/vertex.glsl';
import fragment  from '!!raw-loader!./shaders/fragment.glsl';
import { useFrame, useThree } from '@react-three/fiber';
import { useEffect, useMemo, useRef, useCallback } from 'react';
import { changeTarget } from '../../../redux/actions/actionCreators'
import { connect } from 'react-redux';


const Main = (props) => {

    const { texture, lampModel, setTarget, envMap } = props;
    const mainMesh = useRef(null);

    const get = useThree((state)=>state.get);

    const { camera, scene } = get();

    const shaderData = useMemo(()=>{

        envMap.wrapS = THREE.RepeatWrapping;
        envMap.wrapT = THREE.RepeatWrapping;

        return {
            uniforms: {
                time: { value: 1.0 },
                resolution: { value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
                dpr: { value: window.devicePixelRatio },
                inverseWorld: { value: new THREE.Matrix4() },
                textureEnv: { value: texture },
                cameraWorldMatrix: { value: camera.matrixWorld.clone() },
                cameraProjectionMatrixInverse: { value: camera.projectionMatrixInverse.clone() },
                envMap: { value: envMap },
                lightColor: {value: new THREE.Color()}
            },
            shaders: {
                vs: vertex,
                fs: fragment
            }
        };
    },[]); 

    const lamp = useMemo(()=>{

        const scale = 0.05;
        const scaleModel = new THREE.Vector3(scale,scale,scale);

        const bodyMat = new THREE.MeshPhysicalMaterial({color:'grey'});
        bodyMat.roughness = 0.15;
        bodyMat.metalness = 0.5;
        bodyMat.envMapIntensity = 1.4;
        // bodyMat.sheen= 0.5

        bodyMat.envMap = envMap;
        // bodyMat.reflectivity = 0.3;
        // bodyMat.clearcoat = 0.4;


        const glassGeom = lampModel?.nodes.glass.geometry.clone();

        // glassGeom.computeBoundingBox()
        // glassGeom.computeBoundingSphere();
        // glassGeom.computeTangents();
        // glassGeom.computeVertexNormals();

        const bodyGeom = lampModel?.nodes.body.geometry.clone();

        bodyGeom.computeBoundingBox()
        bodyGeom.computeBoundingSphere();
        bodyGeom.computeTangents();
        // bodyGeom.computeVertexNormals();

        const center = new THREE.Vector3();
        bodyGeom?.boundingBox.getCenter(center);

        const centerCamera = center.multiply(scaleModel);


        // console.log(window);


        return {
            body:{
                g:bodyGeom,
                m:bodyMat,
            },
            glass:{
                g:glassGeom
            },
            scale: scaleModel,
            centerCamera 
        };
        
    },[lampModel]);

    useEffect(()=>{

        setTarget([lamp.centerCamera.x,lamp.centerCamera.y,lamp.centerCamera.z]);

    },[lamp]);

    const getSceneLight = useCallback((scene) =>{

        const pointlight = scene.children.find( item => item.isPointLight)

        return pointlight.color;
    },[]);

    useFrame(( state ) => {

        camera.updateProjectionMatrix();
        camera.updateWorldMatrix();

        mainMesh.current.material.uniforms.resolution.value.x = window.innerWidth;
        mainMesh.current.material.uniforms.resolution.value.y = window.innerHeight;

        mainMesh.current.material.uniforms.dpr.value = window.devicePixelRatio;

        mainMesh.current.material.uniforms.inverseWorld.value = mainMesh.current.matrixWorld.invert();
        mainMesh.current.material.uniforms.time.value = state.clock.elapsedTime;

        mainMesh.current.material.uniforms.lightColor.value.copy(getSceneLight(scene));

        mainMesh.current.material.uniforms.cameraWorldMatrix.value.copy(camera.matrixWorld);
        mainMesh.current.material.uniforms.cameraProjectionMatrixInverse.value.copy( camera.projectionMatrixInverse );

    });

    return (
        <>
            <group scale={lamp.scale} >
                <mesh geometry={lamp.body.g}  material={lamp.body.m}  />
                <mesh ref={mainMesh} geometry={lamp.glass.g} > 
                    <shaderMaterial attach='material' vertexShader={ shaderData.shaders.vs} fragmentShader={shaderData.shaders.fs} uniforms={shaderData.uniforms} transparent={true} fog={true} />
                </mesh>
            </group>
        </>
    );
};

const mapDispatchToProps = (dispatch) => {
    return {
      setTarget: (payload) => dispatch(changeTarget(payload)) 
    };
};

export default connect(null, mapDispatchToProps)(Main);