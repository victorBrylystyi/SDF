
import Main from "./MainObject/Main";

const Actors = (props) => {

    console.log('actors 6');

    const { assets } = props;

    // console.log(assets);

    return (
        <Main texture ={assets.env} lampModel={assets.lamp} />
    );
};

export default Actors;