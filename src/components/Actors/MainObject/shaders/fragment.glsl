uniform float time;
uniform vec2 resolution;
uniform mat4 inverseWorld;
uniform float dpr;
uniform vec3 lightColor;

uniform mat4 cameraWorldMatrix;
uniform mat4 cameraProjectionMatrixInverse;

uniform samplerCube envMap;


varying mat4 model;
varying vec3 world_Vertex;
varying vec3 world_Normal;

#define STEPS 1.0
#define STEP_SIZE 1.0 / 1.0
#define EPSILON 0.0001
#define MIN_DIST 0.0
#define MAX_DIST 200.0
#define MAX_MARCHING_STEPS 512




// ------------------------- Utils ----------------------------


float fresnel(float bias, float scale, float power, vec3 I, vec3 N){
    return bias + scale * pow(1.0 + dot(I, N), power);
}

   // Indices of refraction
const float Air = 1.0;
const float Ice = 1.33;

// Air to glass ratio of the indices of refraction (Eta)
const float Eta = Air / Ice;
const float EtaDelta = 1.0 - Eta;

// see http://en.wikipedia.org/wiki/Refractive_index Reflectivity
const float R0 = ((Air - Ice) * (Air - Ice)) / ((Air + Ice) * (Air + Ice));

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

float v33(vec3 samplePoint){

    float speed = 7.0;
    float refTime = 12.0;

    float bias = 4.0;
    float up = bias + 13.5;
    float middle = (up - bias)/2.0 + bias;
    float Rbias = 0.3;


    vec3 A = vec3(1.0, ((up - bias)/2.0 ) * 0.8, 0.9 );

    vec3 R1 = vec3(0.5 - cos(time/speed) * 0.1, 0.6 + cos(time/speed) * 0.1, 0.4 + sin(time/speed*2.0) * 0.2);
    R1 += Rbias;


    float elUp = sdEllipsoid((samplePoint),vec3(0.0,up,0.0),vec3(5.0,3.0,5.0));
    float elDwn = sdEllipsoid((samplePoint),vec3(0.0,bias,0.0),vec3(5.0,4.0,5.0));

    float el1 = sdEllipsoid((samplePoint),vec3(0.0, cos(time/(speed*2.0)) * (-A.y) + middle ,0.0),R1);

    float dist = opSmoothUnion(elUp,elDwn,0.45);
    dist = opSmoothUnion(dist,el1,0.55);

    if (time >= refTime){

        vec3 pos = vec3(cos((time-refTime)/(speed*3.0))*A.x,
                        (cos((time-refTime)/(speed*3.0))*(-A.y))+ middle,
                        cos((time-refTime)/(speed*5.0))*A.z);

        vec3 R2 = vec3(0.55 + sin(time/speed) * 0.1, 0.6 - sin(time/speed) * 0.1, 0.5 - cos(time/speed) * 0.2);
            R2 += Rbias;


        float el2 = sdEllipsoid(samplePoint,pos,R2); 
        dist = opSmoothUnion(dist,el2,0.6);

        if (time >= refTime * 2.0){

            vec3 R3 = vec3(0.45 + cos(time/speed) * 0.1, 0.6 - cos(time/speed) * 0.1, 0.5 + sin(time/speed*3.0) * 0.1);
                R3 += Rbias;

            pos = vec3(sin((-time-refTime*2.0)/(speed*5.0))*A.x,
                            (cos((time-refTime*2.0)/(speed*5.0))*(-A.y))+ middle,
                            cos((-time-refTime*2.0)/(speed*3.0))*A.z);

            float el3 = sdEllipsoid((samplePoint),pos,R3);
            dist = opSmoothUnion(dist,el3,0.65);

            if (time >= refTime * 3.0){

                vec3 R4 = vec3(0.6 - cos(time/speed) * 0.1, 0.6 + cos(time/speed) * 0.1, 0.5 - cos(time/speed) * 0.2);
                    R4 += Rbias;

                pos = vec3(cos((time-refTime*3.0)/(speed*6.0))*A.x,
                            (cos((time-refTime*3.0)/(speed*2.0))*(-A.y))+ middle,
                            cos((time-refTime*3.0)/(speed*6.0))*A.z);

                float el4 = sdEllipsoid((samplePoint),pos,R4);
                dist = opSmoothUnion(dist,el4,0.55);

                if (time >= refTime * 4.0){

                    vec3 R5 = vec3(0.5 - sin(time/speed) * 0.1, 0.6 + sin(time/speed) * 0.1, 0.5 - sin(time/speed) * 0.1);
                        R5 += Rbias;

                    pos = vec3(sin((-time-refTime*4.0)/(speed*2.0))*A.x,
                            (cos((time-refTime*4.0)/(speed*6.0))*(-A.y))+ middle,
                            cos((-time-refTime*4.0)/(speed*2.0))*A.z);

                    float el5 = sdEllipsoid((samplePoint),pos,R5);
                    dist = opSmoothUnion(dist,el5,0.6); 
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

    return v33(samplePoint);

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

    vec2 newResolution = resolution.xy * 1.0;
    
    vec3 eye = cameraPosition; // позиция камеры 

    // screen position
	vec2 screenPos = ( gl_FragCoord.xy * 2.0 - newResolution.xy ) / newResolution ;

	// ray direction in normalized device coordinate
	vec4 ndcRay = vec4( screenPos, 1.0, 1.0 );

	// convert ray direction from normalized device coordinate to world coordinate
	vec3 ray = ( cameraWorldMatrix * cameraProjectionMatrixInverse * ndcRay ).xyz;

// ---------------------------------------------------------------

    float dist = shortestDistanceToSurface(eye, ray, MIN_DIST, MAX_DIST); // ret +depth or 100

    if (dist > MAX_DIST - EPSILON) {
        // Didn't hit anything
        return vec4(0.0);
    } 


// --------------------------------------------------------------

    vec3 pos = eye + dist * ray; 

    vec3 normal = sceneNormal(pos);

    vec3 baseColor = lightColor;


    vec3 I2 = normalize(pos - eye);
    float R2 = fresnel(0.02, 4.0, 4.0, I2, normal);

    vec3 viewDirection = normalize(pos - eye);
    vec3 refl = reflect(viewDirection, normal) * vec3(-1.0, 1.0, 1.0) ;

    vec3 refr = refract(viewDirection, normal, 1.0/1.18) * vec3(-1.0, 1.0, 1.0);

    vec4 envColor = textureCube(envMap, refr);
    vec4 envColor2 = textureCube(envMap, refl);

    vec4 rsltColor = mix(envColor, envColor2, R2);


    rsltColor.rgb *= baseColor;
    rsltColor.rgb += R2 * 0.6 * ((cos(time/4.0) + 0.7)/2.0);

    return rsltColor; 
}


// ------------------------- Main ----------------------------

void main( void ) {

    vec4 color = raymarch(1.0);

    vec3 I = normalize(world_Vertex - cameraPosition);
    float R = fresnel(0.02, 4.0, 4.0, I, world_Normal);

    vec3 viewDirection = normalize(world_Vertex - cameraPosition);
    vec3 refl = reflect(viewDirection, world_Normal) * vec3(-1.0, 1.0, 1.0) ;

 // see http://en.wikipedia.org/wiki/Schlick%27s_approximation
	float v_fresnel_ratio = (R0 + ((1.0 - R0) * pow(R, 1.0)));

    vec3 refr = refract(viewDirection, world_Normal,1.33) * vec3(-1.0, 1.0, 1.0);

    vec4 envColor = textureCube(envMap, refr);
    vec4 envColor2 = textureCube(envMap, refl);

    vec4 insideColor = mix(mix(envColor,vec4(0.0),1.0-v_fresnel_ratio), color, color.a);

    vec4 rsltColor = mix(insideColor, envColor2, R);
    rsltColor += R*0.7;
 
    gl_FragColor = rsltColor;
}


