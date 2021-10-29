
varying vec3 world_Vertex;
varying vec3 world_Normal;


void main(){
    vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );
    gl_Position = projectionMatrix * mvPosition;
    world_Vertex = (modelMatrix * vec4( position.xyz,1.0)).xyz;
    world_Normal = normalize( vec3(modelMatrix * vec4(normal, 0.0)) ); 
}

