import { useGLTF, useTexture } from "@react-three/drei";
import Actors from "./Actors/Actors";

useTexture.preload('./assets/textures/env.jpg');
useGLTF.preload("/assets/gltf/lamp.glb");

const Provider = () => {
    console.log('provider 5');
    
    const assets = {
        env: useTexture('./assets/textures/env.jpg'),
        lamp: useGLTF("/assets/gltf/lamp.glb")
    };

    return (
        <>            
            <Actors assets={assets}/>
        </>
    );
};

export default Provider;