#version 430 core

// https://github.com/Cakez77/terraria_clone/
struct Transform {
    vec2 position;
    vec2 size;
    vec4 color;
};

layout(std430, binding=0) buffer TransformSBO {
    Transform transforms[];
};

out vec4 a_color;

uniform mat4 proj;

void main() {
    Transform transform = transforms[gl_InstanceID];

    vec2 vertices[6] = {
        transform.position,                                        // Top Left
        vec2(transform.position + vec2(0.0, transform.size.y)),    // Bottom Left
        vec2(transform.position + vec2(transform.size.x, 0.0)),    // Top Right
        vec2(transform.position + vec2(transform.size.x, 0.0)),    // Top Right
        vec2(transform.position + vec2(0.0, transform.size.y)),    // Bottom Left
        transform.position + transform.size                        // Bottom Right
    };

    gl_Position = proj * vec4(vertices[gl_VertexID], 1.0, 1.0);
    a_color = transform.color;
}
