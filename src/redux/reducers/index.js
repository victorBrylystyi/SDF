
import { combineReducers } from 'redux';
import { targetReducer } from './targetReducer';

const rootReducer = combineReducers({
    target: targetReducer
});

export default rootReducer;

