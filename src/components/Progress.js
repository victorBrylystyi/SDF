import { Html, useProgress } from "@react-three/drei";

const Progress = () => {
    const { progress } = useProgress();

    return (
        <Html center> {Math.floor(progress)} % loaded </Html> 
    );
};

export default Progress;