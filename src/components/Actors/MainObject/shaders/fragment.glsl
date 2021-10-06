uniform float time;
uniform vec2 resolution;
uniform mat4 inverseWorld;
uniform float dpr;

			uniform mat4 cameraWorldMatrix;
			uniform mat4 cameraProjectionMatrixInverse;

uniform sampler2D textureEnv;

varying mat4 model;
varying vec3 world_Vertex;
varying vec3 world_Normal;

#define STEPS 96
#define STEP_SIZE 1.0 / 96.0
#define EPSILON 0.0001
#define MIN_DIST 0.0
#define MAX_DIST 100.0
#define MAX_MARCHING_STEPS 255

// -------------------------------------

vec3 glow = vec3(0.0);

float glow_intensity = .01;
vec3 glow_color = vec3(1.0);
vec3 background = vec3(0.0);

// ------------------------- Utils ----------------------------


float fresnel(float bias, float scale, float power, vec3 I, vec3 N){
    return bias + scale * pow(1.0 + dot(I, N), power);
}


// ------------------------- CAMERA ----------------------------

vec3 transformed(vec3 p){
    return (inverseWorld * vec4(p, 1.0)).xyz;
}

vec3 rayDirection(float fieldOfView, vec2 size, vec2 fragCoord) {
    vec2 xy = fragCoord - size / 2.0;
    float z = size.y / tan(radians(fieldOfView) / 2.0);
    return normalize(vec3(xy, -z));
}

mat3 viewMatrixBuild(vec3 eye, vec3 center, vec3 up) {
    // Based on gluLookAt man page
    vec3 f = normalize(center - eye);
    vec3 s = normalize(cross(f, up));
    vec3 u = cross(s, f);
    return mat3(s, u, -f);
}

// ------------------------- Raymarch objects ----------------------------

float sdBox( vec3 p, vec3 b ){
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdSphere( vec3 p, float s ){
    return length(p)-(s);
}

float sdf_sphere2 (vec3 p, vec3 c, float r){
    return distance(p,c) - (r);
}


    // ------------- Raymarch operations -----------

    float opUnion( float d1, float d2 ) { 
        return min(d1,d2); 
    }

    float opSmoothUnion( float d1, float d2, float k ){
        float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
        return mix( d2, d1, h ) - k*h*(1.0-h); 
    }

    float sdEllipsoid( vec3 p, vec3 center, vec3 r ){
        vec3 point = p - center;
        float k0 = length(point/r);
        float k1 = length(point/(r*r));
        return k0*(k0-1.0)/k1;
    }

// ------------------------- Scene ----------------------------

float v1 (vec3 samplePoint){

    float A = 0.2;
    float Ax = 0.4;
    

    float dist1 = sdf_sphere2((samplePoint),vec3((sin(-time/5.0)) * Ax + 0.2, (cos(-time/5.0)) * A + 0.3, (sin(-time/5.0) * A)),0.16);
    float dist2 = sdf_sphere2((samplePoint),vec3((cos(time/4.0))  * Ax - 0.1, (cos(time/2.0)) * A - 0.2,(sin(time/2.0) * A)),0.15);
    float dist3 = sdf_sphere2((samplePoint),vec3((sin(time/8.0))  * Ax - 0.2, (sin(time/3.0)) * A + 0.1,(cos(-time/2.0) * A)),0.14);
    float dist4 = sdf_sphere2((samplePoint),vec3((cos(-time/3.0)) * Ax + 0.1, (cos(time/5.0)) * A - 0.1,(sin(time/3.0) * A)),0.17);
    float dist5 = sdf_sphere2((samplePoint),vec3((cos(time/4.0))  * Ax,       (sin(-time/10.0)) * A - 0.3,(cos(time/10.0) * A)),0.12);
    float dist6 = sdf_sphere2((samplePoint),vec3((sin(-time/10.0)) * Ax,      (cos(-time/7.0)) * A + 0.2,(sin(-time/1.0) * A)),0.11);

    float dist7 = sdf_sphere2((samplePoint),vec3((sin(time/3.0)) * Ax + 0.2, (cos(time/4.0)) * A + 0.3, (sin(time/5.0) * A)),0.16);
    float dist8 = sdf_sphere2((samplePoint),vec3((cos(-time/2.0))  * Ax - 0.1, (cos(-time/7.0)) * A - 0.2,(sin(-time/4.0) * A)),0.15);
    float dist9 = sdf_sphere2((samplePoint),vec3((sin(time/8.0))  * Ax - 0.2, (sin(time/6.0)) * A + 0.1,(cos(-time/2.0) * A)),0.14);

    float dist = opSmoothUnion(dist1,dist2,0.15);
    dist = opSmoothUnion(dist,dist3,0.15);
    dist = opSmoothUnion(dist,dist4,0.11);
    dist = opSmoothUnion(dist,dist5,0.12);
    dist = opSmoothUnion(dist,dist6,0.13);
    dist = opSmoothUnion(dist,dist7,0.2);
    dist = opSmoothUnion(dist,dist8,0.12);
    dist = opSmoothUnion(dist,dist9,0.13);

    return dist;
}

float v2(vec3 samplePoint){

    float A = 1.4;
    float speed = 2.0;
    

    float dist1 = sdEllipsoid((samplePoint),vec3(0.0,1.618,0.0),vec3(2.0,0.5,1.0));
    float dist2 = sdEllipsoid((samplePoint),vec3(0.0,-1.618,0.0),vec3(2.0,0.5,1.0));

    float dist3 = sdf_sphere2((samplePoint),vec3(sin(time/(speed/3.0))*(-0.4),(cos(time/speed)*-A)-0.4,0.0),0.2); 
    float dist4 = sdf_sphere2((samplePoint),vec3(sin(time/(speed/3.0))*0.4,(cos(time/speed)* A)+0.4,0.0),0.2); 

    float dist5 = sdf_sphere2((samplePoint),vec3(-0.5,(cos(time/speed)*-A),0.0),0.2); 
    float dist6 = sdf_sphere2((samplePoint),vec3(0.5,(cos(time/speed)* A),0.0),0.2); 

    // float dist7 = sdf_sphere2((samplePoint),vec3(-0.5,(cos(time/speed)*-A),0.0),0.2); 
    // float dist8 = sdf_sphere2((samplePoint),vec3(0.5,(cos(time/speed)* A),0.0),0.2); 

    float dist34 = opSmoothUnion(dist3,dist4,0.6);

    float dist = opSmoothUnion(dist1,dist2,0.15);
    float dist125 = opSmoothUnion(dist,dist5,0.6);
    float dist126 = opSmoothUnion(dist,dist6,0.6);

    dist = opSmoothUnion(dist,dist34,0.15);
    dist = opSmoothUnion(dist,dist125,0.15);
    dist = opSmoothUnion(dist,dist126,0.15);

    return dist;
}

float v3(vec3 samplePoint){

    // if ((time-prevTime) >= DELTA){

    // }

    float A = 1.4;
    float speed = 2.0;
    float refTime = 10.0;

    float elUp = sdEllipsoid((samplePoint),vec3(0.0,1.618,0.0),vec3(2.0,0.5,1.0));
    float elDwn = sdEllipsoid((samplePoint),vec3(0.0,-1.618,0.0),vec3(2.0,0.5,1.0));

    // float x = sin(time/(speed*5.0));
    float r = ((cos((time/speed))+1.0)*0.15 + 0.15);
    float dist1 = sdEllipsoid((samplePoint),vec3(sin(time/(speed*5.0)),(cos(time/speed)*(-A))-0.5,0.0),vec3((0.4),0.2,0.2));//+ (cos (time)+1.0)






    // float dist8 = sdf_sphere2((samplePoint),vec3(0.0,(cos(time/speed)*(-A))-0.4,0.0),0.2);       
    // float dist9 = sdf_sphere2((samplePoint),vec3(0.0,(cos(time/speed)*(-A))-0.4,0.0),0.2);
    // float dist10 = sdf_sphere2((samplePoint),vec3(0.0,(cos(time/speed)*(-A))-0.4,0.0),0.2);
    // float dist11 = sdf_sphere2((samplePoint),vec3(0.0,(cos(time/speed)*(-A))-0.4,0.0),0.2);
    // float dist12 = sdf_sphere2((samplePoint),vec3(0.0,(cos(time/speed)*(-A))-0.4,0.0),0.2);   

    float AA = 0.5;


    float dist = opSmoothUnion(elUp,elDwn,0.15);
        dist = opSmoothUnion(dist,dist1,0.15);
    if (time >= refTime){
    float dist2 = sdf_sphere2((samplePoint),vec3(cos((time-refTime)/(speed*3.0))*AA,(cos((time-refTime)/(speed*3.0))*(-A))-0.5,cos((time-refTime)/(speed*5.0))*AA),((cos(((time-refTime)/speed))+1.0)*0.15 + 0.15)); 
        dist = opSmoothUnion(dist,dist2,0.15);
        if (time>=refTime*2.0){
            float dist3 = sdf_sphere2((samplePoint),vec3(sin((-time-refTime*2.0)/(speed*5.0))*AA,(cos((time-refTime*2.0)/(speed*5.0))*(-A))-0.5,cos((-time-refTime*2.0)/(speed*3.0))*AA),((cos(((time-refTime*2.0)/speed))+1.0)*0.15 + 0.15));
            dist = opSmoothUnion(dist,dist3,0.15);
            if (time>=refTime*3.0){
                float dist4 = sdf_sphere2((samplePoint),vec3(cos((time-refTime*3.0)/(speed*6.0))*AA,(cos((time-refTime*3.0)/(speed*2.0))*(-A))-0.5,cos((time-refTime*3.0)/(speed*6.0))*AA),((cos(((time-refTime*3.0)/speed))+1.0)*0.15 + 0.15));
                dist = opSmoothUnion(dist,dist4,0.15);
                if (time>=refTime*4.0){
                        float dist5 = sdf_sphere2((samplePoint),vec3(sin((-time-refTime*4.0)/(speed*2.0))*AA,(cos((time-refTime*4.0)/(speed*6.0))*(-A))-0.5,cos((-time-refTime*4.0)/(speed*2.0))*AA),((cos(((time-refTime*4.0)/speed))+1.0)*0.15 + 0.15));
                        dist = opSmoothUnion(dist,dist5,0.15); 
                    // if (time>=refTime*5.0){
            
                    // }
                }
            }
        }





  
    }


    return dist;
}

float v33(vec3 samplePoint){

    float speed = 5.0;
    float refTime = 12.0;

    float bias = 6.0;
    float up = bias + 10.0;
    float middle = (up - bias)/2.0 + bias;


    vec3 A = vec3(1.0, ((up - bias)/2.0 ) * 0.8, 0.9 );

    vec3 R1 = vec3(0.5 - cos(time/speed) * 0.1, 0.6 + cos(time/speed) * 0.1, 0.4 + sin(time/speed*2.0) * 0.2);


    float elUp = sdEllipsoid((samplePoint),vec3(0.0,up,0.0),vec3(5.0,1.5,4.0));
    float elDwn = sdEllipsoid((samplePoint),vec3(0.0,bias,0.0),vec3(5.0,2.0,4.0));

    float el1 = sdEllipsoid((samplePoint),vec3(0.0, cos(time/(speed*2.0)) * (-A.y) + middle ,0.0),R1);

    float dist = opSmoothUnion(elUp,elDwn,0.25);
    dist = opSmoothUnion(dist,el1,0.15);

    if (time >= refTime){

        vec3 pos = vec3(cos((time-refTime)/(speed*3.0))*A.x,
                        (cos((time-refTime)/(speed*3.0))*(-A.y))+ middle,
                        cos((time-refTime)/(speed*5.0))*A.z);

        vec3 R2 = vec3(0.55 + sin(time/speed) * 0.1, 0.6 - sin(time/speed) * 0.1, 0.5 - cos(time/speed) * 0.2);


        float el2 = sdEllipsoid(samplePoint,pos,R2); 
        dist = opSmoothUnion(dist,el2,0.2);

        if (time >= refTime * 2.0){

            vec3 R3 = vec3(0.45 + cos(time/speed) * 0.1, 0.6 - cos(time/speed) * 0.1, 0.5 + sin(time/speed*3.0) * 0.1);

            pos = vec3(sin((-time-refTime*2.0)/(speed*5.0))*A.x,
                            (cos((time-refTime*2.0)/(speed*5.0))*(-A.y))+ middle,
                            cos((-time-refTime*2.0)/(speed*3.0))*A.z);

            float el3 = sdEllipsoid((samplePoint),pos,R3);
            dist = opSmoothUnion(dist,el3,0.3);

            if (time >= refTime * 3.0){

                vec3 R4 = vec3(0.6 - cos(time/speed) * 0.1, 0.6 + cos(time/speed) * 0.1, 0.5 - cos(time/speed) * 0.2);

                pos = vec3(cos((time-refTime*3.0)/(speed*6.0))*A.x,
                            (cos((time-refTime*3.0)/(speed*2.0))*(-A.y))+ middle,
                            cos((time-refTime*3.0)/(speed*6.0))*A.z);

                float el4 = sdEllipsoid((samplePoint),pos,R4);
                dist = opSmoothUnion(dist,el4,0.15);

                if (time >= refTime * 4.0){

                    vec3 R5 = vec3(0.5 - sin(time/speed) * 0.1, 0.6 + sin(time/speed) * 0.1, 0.5 - sin(time/speed) * 0.1);

                    pos = vec3(sin((-time-refTime*4.0)/(speed*2.0))*A.x,
                            (cos((time-refTime*4.0)/(speed*6.0))*(-A.y))+ middle,
                            cos((-time-refTime*4.0)/(speed*2.0))*A.z);

                    float el5 = sdEllipsoid((samplePoint),pos,R5);
                    dist = opSmoothUnion(dist,el5,0.4); 
                }
            }
        }
    }

    return dist;
}

float v4(vec3 samplePoint){
    float dist = sdf_sphere2(samplePoint,vec3(0.0,0.0,0.0),0.3); 
    return dist;
}



float sceneSDF(vec3 samplePoint) {

    float dist = v33(samplePoint);

    return dist;
}

vec3 sceneNormal(vec3 p) {
    return normalize(vec3(
        sceneSDF(vec3(p.x + EPSILON, p.y, p.z)) - sceneSDF(vec3(p.x - EPSILON, p.y, p.z)),
        sceneSDF(vec3(p.x, p.y + EPSILON, p.z)) - sceneSDF(vec3(p.x, p.y - EPSILON, p.z)),
        sceneSDF(vec3(p.x, p.y, p.z + EPSILON)) - sceneSDF(vec3(p.x, p.y, p.z - EPSILON))
    ));
}


float shortestDistanceToSurface(vec3 eye, vec3 marchingDirection, float start, float end) {
    float depth = start;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        float dist = sceneSDF(eye + depth * marchingDirection);
        if (dist < EPSILON) {
            return depth;
        }
        depth += dist;
        if (depth >= end) {
            return end;
        }
    }
    return end;
}


vec4 raymarch(float s) {

    vec2 newResolution = resolution.xy * dpr;

    vec3 viewDir = rayDirection(70.0, newResolution.xy, gl_FragCoord.xy); // направление от камеры к пикселю на экране 
    vec3 eye = cameraPosition; // позиция камеры 

    mat3 viewToWorld = viewMatrixBuild(eye, vec3(0.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0)); // построение матрицы камеры 

    vec3 worldDir = viewToWorld * viewDir; //направление в мировых координатах 


    				// screen position
				vec2 screenPos = ( gl_FragCoord.xy * 2.0 - newResolution.xy ) / newResolution;

				// ray direction in normalized device coordinate
				vec4 ndcRay = vec4( screenPos, 1.0, 1.0 );

				// convert ray direction from normalized device coordinate to world coordinate
				vec3 ray = ( cameraWorldMatrix * cameraProjectionMatrixInverse * ndcRay ).xyz;

// ---------------------------------------------------------------

    float dist = shortestDistanceToSurface(eye, ray, MIN_DIST, MAX_DIST); // ret +depth or 100

    vec3 I = normalize(world_Vertex - eye);
    float R = fresnel(0.02, 4.0, 4.0, I, world_Normal);


    if (dist > MAX_DIST - EPSILON) {

        float rr = ((sin(time/30.0) + 1.0) / 2.0);
        float gg = ((cos(-time/10.0) + 1.0) / 2.0);
        float bb = ((sin(time/20.0) + 1.0) / 2.0);

        // Didn't hit anything
        // return vec3(rr, gg, bb);
        vec4 c = vec4(0.0, 0.0, 0.0, 0.0);
        c+=R*0.7;
        return c;
        // return world_Vertex;
        // return vec3(0.105, 0.121, 0.164);
        

    } 

    // else {
    //     return normalize(vec3(0.0, 73.0, 255.0));
    // }


    // vec3 baseColor = vec3(r,g,b);
    // vec3 baseColor = vec3(1.0,0.0,0.0);

// ------------------------ Normals ------------------------------

    // vec3 pos = eye + dist * worldDir; // dist - sdf
    vec3 pos = eye + dist * ray; // dist - sdf

    vec3 normal = sceneNormal(pos);

    // float r = ((cos(time/30.0) + 1.0) / 2.0) * normal.r;
    // float g = ((sin(time/10.0) + 1.0) / 2.0) * normal.g;
    // float b = ((sin(time/20.0) + 1.0) / 2.0) * normal.b;

    float r = ((cos(time/30.0) + 1.0) / 2.0) ;
    float g = ((sin(time/10.0) + 1.0) / 2.0) ;
    float b = ((sin(time/20.0) + 1.0) / 2.0) ;

    vec3 baseColor = vec3(r, g, b);

    // return normal;

// ---------------------------------------------------------------


// ------------------------------

    vec3 ambColor = vec3(1.0,1.0,1.0);
    vec3 lightColor = vec3(1.0,1.0,1.0);
    vec3 specColor =  vec3(1.0,1.0,1.0);

    float abmInt = 0.2;
    float lightInt = 0.8;
    float specInt = 0.5;

    vec3 lightDir = normalize(vec3(0.5, 0.7, 1.0));

    vec3 diffuse = max ( (dot ( normal, normalize(eye) )), 0.0) * lightColor * lightInt;

    vec3 halfVector = normalize((pos-eye) );

// ---------------

//float fresnel(float bias, float scale, float power, vec3 I, vec3 N){
//----------------

    vec3 spec = (pow(dot(normal, halfVector), 100.0) * specColor) * specInt;

    // vec3 specRay = reflect(transformed(worldDir), normal);
    vec3 specRay = reflect(transformed(ray), normal);
    // vec3 colorTexture = texture2D(textureEnv, transformed(specRay).xy).rgb;


    // vec4 color = ambColor * abmInt ;
    // color += baseColor * diffuse; //
    // color += spec;
    // color += R*0.4;

    vec4 color = vec4( baseColor, 1.0 );
    color += R*1.4;

    return color; 



    // vec3 diff1Color = vec3 ( 1.0, 0.1, 0.1 );
    // vec3 diff2Color = vec3 ( 0.0, 0.5, 1.0 );

    // vec3 light1Dir = normalize(vec3(0.0, 0.0, 0.0));
    // float diffuse1 = max ( dot ( normal, light1Dir ), 0.0 );

    // vec3 light2Dir = normalize(vec3(-0.2, 0.2, 0.4));
    // float diffuse2 = max ( dot ( normal, light2Dir ), 0.0 );

    // float spec1 = pow(diffuse1, 2.0);
    // float spec2 = pow(diffuse2, 128.);

    // float diffuseMain = max ( dot ( normal, -worldDir ), 0.0 );

    // vec3 I = normalize(pos - eye);
    // float R = fresnel(0.05, 4.0, 4.0, I, normal);

    // // vec3 light_color = vec3(0.99, 0.8, 0.4);
    //   vec3 light_color = vec3(0.99, 0.9, 0.9);

    // vec3 diffResult = vec3(light_color*diffuse1 + light_color*diffuse2) * 0.2;


    // vec3 specRay = reflect(transformed(worldDir), normal);

    // vec3 colorTexture = texture2D(textureEnv, transformed(specRay).xy).rgb;

    //             vec3 to_light = k * world_Vertex - u_lightWorldPosition;

    //             to_light = normalize(to_light);

    //             float cos_angle = dot(normal,to_light); 
    //             cos_angle = clamp(cos_angle, 0.0, 1.0);

    //         diffuse_color = cos_angle * u_lightColor * u_intensity;  


    // color = 

    // vec3 result = vec3(
    //     glow*glow_intensity*diff2Color*diffuse2 +
    //     // glow*glow_intensity*diff1Color*diffuse1 +
    //     // diffResult*diffuse1*diffuse2 +
    //     // spec1 * colorTexture * 0.99 +
    //     // spec2 * colorTexture * 0.99 +
    //     R*0.9
    // );

    // return result;
}


// ------------------------- Main ----------------------------

void main( void ) {

    // vec2 newResolution = resolution.xy * dpr;

    // vec2 p = (-newResolution.xy + 2.0*gl_FragCoord.xy) / newResolution.y; // точка на экране [-1;1]

    vec4 color = raymarch(1.0);

    gl_FragColor = color;
}


