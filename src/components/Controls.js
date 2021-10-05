import { OrbitControls } from "@react-three/drei";
import { useThree } from "@react-three/fiber";
import { useEffect } from "react";
import { connect } from "react-redux";

const Controls = (props) => {
    console.log('controls 4');

    const { target } = props;
    const get = useThree(state => state.get);

    useEffect(()=>{
      console.log('controls: target update');

      const { camera } = get();
      camera.position.y = target[1];
      
    },[target]);
    
    return (
        <OrbitControls enableDamping={true} enablePan={false} target={target}/>
    );
};

const mapStateToProps = (state) => {

    const { target } = state;

    return {
      target,
    };
  };


export default connect(mapStateToProps)(Controls);