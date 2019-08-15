layout(triangle_strip, max_vertices=102) out;

out float width;
out float intensity;
out float min_intensity;
out vec3 uvl;

void quad(vec2 P0, vec2 P1, float thickness) {
    /*
         1------3
         | \    |
         |   \  |
         |     \|
         0------2
    */
    vec2 dir = P1-P0;
    float dl = length(dir);
    // If the segment is too short, just draw a square
    dir = normalize(dir);
    vec2 norm = vec2(-dir.y, dir.x);

    uvl = vec3(dl+thickness, -thickness, dl);
    gl_Position = vec4(P0+(-dir-norm)*thickness, 0., 1.);
    EmitVertex(); // 0

    uvl = vec3(dl+thickness, thickness, dl);
    gl_Position = vec4(P0+(-dir+norm)*thickness, 0., 1.);
    EmitVertex(); // 1

    uvl = vec3(-thickness, -thickness, dl);
    gl_Position = vec4(P1+(dir-norm)*thickness, 0., 1.);
    EmitVertex(); // 2
    EndPrimitive();

    uvl = vec3(-thickness, -thickness, dl);
    gl_Position = vec4(P1+(dir-norm)*thickness, 0., 1.);
    EmitVertex(); // 2

    uvl = vec3(dl+thickness, thickness, dl);
    gl_Position = vec4(P0+(-dir+norm)*thickness, 0., 1.);
    EmitVertex(); // 1

    uvl = vec3(-thickness, thickness, dl);
    gl_Position = vec4(P1+(dir+norm)*thickness, 0., 1.);
    EmitVertex(); // 3
    EndPrimitive();
}

float sample_freq(float x) {
    return max(-1., .1*log(8.*texture(iFreqR, .5*pow(mix(x, 1., .13), 3.)).r) - .4);
    //return max(-1., sqrt(1.2*texture(iFreqR, pow(mix(x, 1., .18), 4.)).r) - 1.);
}

float smooth_freq(float x) {
    float sum = 0.;
    const float width = 9.;
    for (float i = -width; i <= width; i+=1.) {
        sum += sample_freq(x + i / iNumGeomIters);
    }
    return sum / (1.5 * width + 1.);
}

float smooth_wave(float x) {
    float sum = 1.;
    const float width = 7.;
    for (float i = - width; i <= width; i += 1.)
        sum += .55 * texture(iSoundR, x + i / iNumGeomIters).r + .5;
    return sum / (1. * width + 1.);
}

void main() {
    float t0 = (iGeomIter+0)/iNumGeomIters;
    float t1 = (iGeomIter+1)/iNumGeomIters;

    width = .009;
    intensity = .05;
    min_intensity = .0;

    float f1 = smooth_freq(t1)+0.1;
    float f0 = smooth_freq(t0)+0.1;

    float omega_0 =  .9;
    float omega_0_s = omega_0*omega_0;
    f1 = -(f1*f1 + omega_0_s)/(f1*f1 + f1*0.6 + omega_0_s)*1.9 + 2.0;
    float f1_t = f1;
    f0 = -(f0*f0 + omega_0_s)/(f0*f0 + f0*0.6 + omega_0_s)*1.9 + 2.0;
    float f1_b = f0;

    t0 = t0 * 2. - 1.;
    t1 = t1 * 2. - 1.;

	vec4 zz = texture(iSoundR, 0.3);
    vec2 P0 = vec2(t0, f1);
    vec2 P1 = vec2(t1, f1);
    quad(P0, P1, width);

    float d = f1-f0;

    while(abs(d) > .01){

        f1_t = (f1_t+f0)/2;
        d = f1_t-f0;
        P0 = vec2(t0, f1_t);
        P1 = vec2(t1, f1_t);
        quad(P0, P1, width);

        f1_b = (f1+f1_b)/2;
        P0 = vec2(t0, f1_b);
        P1 = vec2(t1, f1_b);
        quad(P0, P1, width);
    }
  //  if ((f1-f0) > .01){

  //      P0 = vec2(t0, -abs((f1+f0)/2));
  //      P1 = vec2(t1, -abs((f1+f0)/2));
  //      quad(P0, P1, width);
  //  }else{
  //      vec2 P0 = vec2(t0, f1);
  //      vec2 P1 = vec2(t1, f1);
  //      quad(P0, P1, width);
  //  }
}
