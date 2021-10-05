
import React, { Suspense } from "react";
import Controls from "./Controls";
import Provider from "./Provider";


const Environment = () => {
    console.log('env 3');
    
    return (
        <>
            <color attach="background" args={0xFFFFFF} /> //#184FC6  0x010620
            <ambientLight intensity= {0.5} />
        </>
    );
};

const Scene = () => {
    console.log('scene 2');

    return (
        <>
            <Environment />
            <Controls />
            <Suspense fallback={null}>
                <Provider /> 
            </Suspense>
        </>

    );
};

export default Scene;