import { CHANGE } from "./actionTypes"

const changeTarget = payload => {
    return {
        type: CHANGE,
        payload
    };
};


export { changeTarget };
