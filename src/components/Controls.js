import { OrbitControls } from "@react-three/drei";
import { useThree } from "@react-three/fiber";
import { connect } from "react-redux";

const Controls = (props) => {


    const { target } = props;
    const get = useThree(state => state.get);

    const { camera } = get();
    camera.position.y = target[1]+8;

    return (
        <OrbitControls enableDamping={false} enablePan={false} target={target} maxDistance={20} minDistance={5} minPolarAngle={Math.PI/3} maxPolarAngle={Math.PI/1.7} e/>
    );
};

const mapStateToProps = (state) => {
  
    const { target } = state;

    return {
      target,
    };
};


export default connect(mapStateToProps)(Controls);