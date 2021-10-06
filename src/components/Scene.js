

import { useHelper } from "@react-three/drei";
import { useFrame } from "@react-three/fiber";
import React, { Suspense, useRef } from "react";
import { PointLightHelper } from "three";
import Controls from "./Controls";
import Provider from "./Provider";


const Environment = () => {
    console.log('env 3');

    const pointLight = useRef(null);
    useHelper(pointLight, PointLightHelper, 2.5, "hotpink");

    useFrame(({clock}) => {

        pointLight.current.position.x = Math.sin(clock.elapsedTime) * 10;
        pointLight.current.position.z = Math.cos(clock.elapsedTime) * 10;

    });

    return (
        <>
            <color attach="background" args={0x071D59 } /> //#184FC6  0x010620 0x1B1F2A
            {/* <fog attach="fog" args={['#101010', -100, 50]} />  //#101010 */}
            <ambientLight intensity= {0.5} />
            <pointLight ref={pointLight} intensity={2.0} position={[10,20,0]} color='red'/>
        </>
    );
};

const Scene = () => {
    console.log('scene 2');

    return (
        <>
            <Suspense fallback={null}>
            <Environment />
            <Controls />
                <Provider /> 
            </Suspense>
        </>

    );
};

export default Scene;