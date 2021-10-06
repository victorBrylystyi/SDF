import { useGLTF, useTexture } from "@react-three/drei";
import Actors from "./Actors/Actors";

useGLTF.preload("/assets/gltf/lamp.glb");
useTexture.preload('./assets/textures/env.jpg');
// useTexture.preload('./assets/textures/Metal/Metal028_1K_Color.png');
// useTexture.preload('./assets/textures/Metal/Metal028_1K_Metalness.png');
// useTexture.preload('./assets/textures/Metal/Metal028_1K_NormalGL.png');
// useTexture.preload('./assets/textures/Metal/Metal028_1K_Roughness.png');
// useTexture.preload('./assets/textures/Metal/Metal028_1K_Displacement.png');

const Provider = () => {
    console.log('provider 5');
    
    const assets = {
        env: useTexture('./assets/textures/env.jpg'),
        lamp: useGLTF("/assets/gltf/lamp.glb"),
        // metal:{
        //     color: useTexture('./assets/textures/Metal/Metal028_1K_Color.png'),
        //     metalness: useTexture('./assets/textures/Metal/Metal028_1K_Metalness.png'), 
        //     normal: useTexture('./assets/textures/Metal/Metal028_1K_NormalGL.png'),
        //     roughness: useTexture('./assets/textures/Metal/Metal028_1K_Roughness.png'),
        //     displ: useTexture('./assets/textures/Metal/Metal028_1K_Displacement.png'),
        // } 

    };

    // console.log(assets);

    return (
        <>            
            <Actors assets={assets}/>
        </>
    );
};

export default Provider;

/*
{
            baseColor: bc,
            metalness: useTexture('./assets/textures/Metal/Metal028_1K_Metalness.png'), 
            normal: useTexture('./assets/textures/Metal/Metal028_1K_NormalGL.png'),
            roughness: useTexture('./assets/textures/Metal/Metal028_1K_Roughness.png'),
        }
*/