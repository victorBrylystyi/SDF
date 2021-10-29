
import Scene from "./Scene";
import { Provider } from "react-redux";
import { Canvas } from '@react-three/fiber';
import store from '../redux';

const CanvasSpace = () => {

    return (
        <div className='canvasContainer'> 
            <Canvas camera={{position:[0,0,20]}} gl={{antialias:true}} flat={true} linear={true}>
                <Provider store={store}>
                    <Scene />
                </Provider>
            </Canvas>
        </div>
    );
};


const App = () => {

    return (
        <div className='App'>
            <CanvasSpace />
        </div>
    );
};

export default App;
