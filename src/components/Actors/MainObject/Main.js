
import * as THREE from 'three';
import vertex  from '!!raw-loader!./shaders/vertex.glsl';
import fragment  from '!!raw-loader!./shaders/fragment.glsl';
import { useFrame, useThree } from '@react-three/fiber';
import { useEffect, useMemo, useRef } from 'react';
import { changeTarget } from '../../../redux/actions/actionCreators'
import { connect } from 'react-redux';

const Main = (props) => {

    console.log('main object 7');

    const { texture, lampModel, setTarget } = props;
    const mainMesh = useRef(null);

    const get = useThree((state)=>state.get);


    const { camera, scene } = get();

    const shaderData = useMemo(()=>{
        console.log('main: memo shaderData');

        return {
            uniforms: {
                time: { value: 1.0 },
                resolution: { value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
                dpr: { value: window.devicePixelRatio },
                inverseWorld: { value: new THREE.Matrix4() },
                textureEnv: { type: "t", value: texture },
                cameraWorldMatrix: { value: camera.matrixWorld.clone() },
                cameraProjectionMatrixInverse: { value: camera.projectionMatrixInverse.clone() }
            },
            shaders: {
                vs: vertex,
                fs: fragment
            }
        };
    },[]);

    const lamp = useMemo(()=>{

        console.log('main: memo model');

        const scale = 0.05;
        const scaleModel = new THREE.Vector3(scale,scale,scale);

        console.log( lampModel);

        const bodyMat = new THREE.MeshPhysicalMaterial({color:'grey'});
        // bodyMat.roughness = 0.2;
        // bodyMat.metalness = 1.6;
        // bodyMat.reflectivity = 0.3;
        // bodyMat.clearcoat = 0.4;


        const glassGeom = lampModel.nodes.glass.geometry.clone();

        // glassGeom.computeBoundingBox()
        // glassGeom.computeBoundingSphere();
        // glassGeom.computeTangents();
        // glassGeom.computeVertexNormals();

        const bodyGeom = lampModel.nodes.body.geometry.clone();

        // bodyGeom.computeBoundingBox()
        // bodyGeom.computeBoundingSphere();
        // bodyGeom.computeTangents();
        // bodyGeom.computeVertexNormals();

        const center = new THREE.Vector3();
        bodyGeom.boundingBox.getCenter(center);

        const centerCamera = center.multiply(scaleModel);

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

    useFrame(( state ) => {

        camera.updateProjectionMatrix();
        camera.updateWorldMatrix();

        mainMesh.current.material.uniforms.resolution.value.x = window.innerWidth;
        mainMesh.current.material.uniforms.resolution.value.y = window.innerHeight;

        mainMesh.current.material.uniforms.dpr.value = window.devicePixelRatio;

        mainMesh.current.material.uniforms.inverseWorld.value = mainMesh.current.matrixWorld.invert();
        mainMesh.current.material.uniforms.time.value = state.clock.elapsedTime;

        mainMesh.current.material.uniforms.cameraWorldMatrix.value.copy(camera.matrixWorld);
        mainMesh.current.material.uniforms.cameraProjectionMatrixInverse.value.copy( camera.projectionMatrixInverse );

        // mainMesh.current.rotation.x += 0.01;
        // mainMesh.current.rotation.y += 0.01;

    });

    return (
        <>
            <group scale={lamp.scale}>
                <mesh geometry={lamp.body.g}  material={lamp.body.m} />
                {/* <mesh geometry={lamp.glassOut.g}  material={lamp.glassOut.m} visible={true}/> */}
                <mesh ref={mainMesh} geometry={lamp.glass.g} > 
                        <shaderMaterial attach='material' vertexShader={ shaderData.shaders.vs} fragmentShader={shaderData.shaders.fs} uniforms={shaderData.uniforms} transparent={true} />
                </mesh>
            </group>
            <mesh position = {[0,20,30]}> 
                <boxGeometry args={[10,10,10]}/>
                <meshBasicMaterial color='red' />
            </mesh>
        </>
    );
};

const mapDispatchToProps = (dispatch) => {
    return {
      setTarget: (payload) => dispatch(changeTarget(payload)) 
    };
};

export default connect(null, mapDispatchToProps)(Main);