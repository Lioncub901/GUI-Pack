function rectPickShader()
    return shader.builder():sprite()
    :func(hsvToRgbString)
    :number{"hue"}
    :material[[
    vec2 uv = getUV0();
    vec3 col = hsvToRgb(hue /360,  uv.x, 1 - uv.y);
    
    material.baseColor = vec4(col,1);
]]
:build()
end

function hueSliderShader()
    return shader.builder():sprite()
    :func(hsvToRgbString)
    :material[[
    vec2 uv = getUV0();
    vec3 col = hsvToRgb(uv.y,  1, 1);

    material.baseColor = vec4(col,1);
]]
:build()
end

function alphaSliderShader()
    return shader.builder():sprite()
    :func(hsvToRgbString)
    :color{"mColor", value = color(255, 202, 0)}
    :material[[
    vec2 uv = getUV0();
    
    material.baseColor = vec4(mColor.rgb,1 - uv.y);
]]
:build()
end



hsvToRgbString = 
[[vec3 hsvToRgb(float h, float s, float v) {    
    float c = v * s; // Chroma
    float x = c * (1.0 - abs(mod(h * 6.0, 2.0) - 1.0)); // X is part of the color adjustment
    float m = v - c; // Match value
    
    vec3 color;
    
    if (h < 1.0 / 6.0) {
        color = vec3(c, x, 0.0);
    } else if (h < 2.0 / 6.0) {
        color = vec3(x, c, 0.0);
    } else if (h < 3.0 / 6.0) {
        color = vec3(0.0, c, x);
    } else if (h < 4.0 / 6.0) {
        color = vec3(0.0, x, c);
    } else if (h < 5.0 / 6.0) {
        color = vec3(x, 0.0, c);
    } else {
        color = vec3(c, 0.0, x);
    }
    
    // Add m to adjust the color value
    return color + vec3(m, m, m);
}]]