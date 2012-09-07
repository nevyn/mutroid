uniform sampler2D tex;
uniform vec4 cycleSourceColor;
uniform vec4 cycleDestColor;

void main()
{
    // Shouldn't be needing this... hmm..
    float eps = 0.1;

    gl_FragColor = texture2D(tex, gl_TexCoord[0].st);
    if(gl_FragColor.r > cycleSourceColor.r-eps && gl_FragColor.r < cycleSourceColor.r+eps &&
       gl_FragColor.g > cycleSourceColor.g-eps && gl_FragColor.g < cycleSourceColor.g+eps && 
       gl_FragColor.b > cycleSourceColor.b-eps && gl_FragColor.b < cycleSourceColor.b+eps)
        gl_FragColor = cycleDestColor;
}
