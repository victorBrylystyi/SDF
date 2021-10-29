
import { useFrame, useThree } from "@react-three/fiber";
import React, { Suspense, useCallback, useMemo, useRef, useState } from "react";

import Controls from "./Controls";
import Progress from "./Progress";
import Store from "./Store";


const Env = () => {

    const pointLight = useRef(null);

    useFrame(({clock}) => {
        
        pointLight.current.position.x = Math.sin(clock.elapsedTime/3) * 10;
        pointLight.current.position.z = Math.cos(clock.elapsedTime/3) * 10;

        pointLight.current.color.r = (Math.sin(clock.elapsedTime/20) + 1) / 2;
        pointLight.current.color.g = (Math.cos(clock.elapsedTime/30) + 1) / 2;
        pointLight.current.color.b = (Math.sin(clock.elapsedTime/40) + 1) / 2;

    });

    return (
        <>
            <color attach="background" args={ 0x184FC6 } /> //#184FC6  0x010620 0x1B1F2A 0x071D59
            <ambientLight intensity= {0.5} />
            <pointLight ref={pointLight} intensity={1.0} position={[0,10,10]} color='red'/>
        </>
    );
};

const Scene = () => {

    return (
        <>
            <Env />
            <Controls />
            <Suspense fallback={null}>
                <Store /> 
            </Suspense>
        </>

    );
};

export default Scene;