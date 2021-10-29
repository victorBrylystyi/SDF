import { useCubeTexture, useGLTF } from "@react-three/drei";
import { useThree } from "@react-three/fiber";
import { useMemo } from "react";
import Actors from "./Actors/Actors";

useCubeTexture.preload(['px.png', 'nx.png', 'py.png', 'ny.png', 'pz.png', 'nz.png'],
    {path:'/assets/textures/env/'});
useGLTF.preload('/assets/gltf/lamp.glb');



const Store = () => {

    const store = {
        lamp: useGLTF('./assets/gltf/lamp.glb'),
        envMap: useCubeTexture(['px.png', 'nx.png', 'py.png', 'ny.png', 'pz.png', 'nz.png'],
            {path:'./assets/textures/env/'}),
    };

    const get = useThree(state => state.get);


    useMemo(()=>{

        const { scene } = get();
        scene.background = store.envMap;

    },[store.envMap]);



    return (
        <>        
            <Actors assets={store}/>
        </>
    );
};


export default Store;
