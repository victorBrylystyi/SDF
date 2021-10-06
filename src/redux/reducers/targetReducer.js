
import { CHANGE } from "../actions/actionTypes";

export const targetReducer =  (prevState = [0,0,0], action) => {

    switch (action.type) {
        case CHANGE:
            {
                const nextState = action.payload.slice();

                return nextState;
            }
  
        default: return prevState;
    };

};