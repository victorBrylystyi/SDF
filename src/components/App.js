
import Scene from "./Scene";
import { Provider } from "react-redux";
import { Canvas } from '@react-three/fiber';
import store from '../redux';

const CanvasSpace = () => {
    console.log('canvas space 1');
    return (
        <div className='canvasContainer'> 
            <Canvas camera={{position:[0,0,10]}}>
                <Provider store={store}>
                    <Scene />
                </Provider>
            </Canvas>
        </div>
    );
};


const App = () => {
    console.log('main app');
    return (
        <div className='App'>
            <CanvasSpace />
        </div>
    );
};

export default App;
