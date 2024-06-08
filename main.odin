package main

import glm "core:math/linalg/glsl"
import "vendor:glfw"
import gl "vendor:OpenGL"

WIDTH :: 800
HEIGHT :: 600
MAX_TRANSFORMS :: 5000

running := true
transforms: [dynamic]Transform

Transform :: struct {
    position: glm.vec2,
    size: glm.vec2,
    color: glm.vec4,
}

main :: proc() {
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    if !glfw.Init() {
        panic("GLFW ERROR: could not init glfw")
    }

    window := glfw.CreateWindow(WIDTH, HEIGHT, "WTESTING", nil, nil)

    if window == nil {
        panic("GLFW ERROR: could not create window")
    }

    glfw.MakeContextCurrent(window)
    glfw.SwapInterval(1)
    glfw.SetKeyCallback(window, key_callback)
    
    gl.load_up_to(4, 6, glfw.gl_set_proc_address)

    program, program_ok := gl.load_shaders_source(vertex_source, fragment_source)
    if !program_ok {
        panic("Failed to create GLSL program")
    }
    defer gl.DeleteProgram(program)
    
    gl.UseProgram(program)
    
    uniforms := gl.get_uniforms_from_program(program)
    defer delete(uniforms)

    sbo, vao: u32

    gl.GenBuffers(1, &sbo)
    gl.BindBufferBase(gl.SHADER_STORAGE_BUFFER, 0, sbo)
    gl.BufferData(gl.SHADER_STORAGE_BUFFER, size_of(Transform) * MAX_TRANSFORMS, raw_data(transforms), gl.DYNAMIC_DRAW)
    
    gl.Enable(gl.BLEND)
    gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

    proj := glm.mat4Ortho3d(0, WIDTH, HEIGHT, 0, -1, 1)

    y: f32 = 0
    for !glfw.WindowShouldClose(window) && running {
        y += 1
        glfw.PollEvents()
        
        append(&transforms, Transform{{}, {64, 64}, {1,0,0,1}})
        append(&transforms, Transform{{32,y}, {64, 64}, {0,0,1,1}})
        // for x in 0..=16 {
        //     for y in 0..=16 {
        //         color: glm.vec4 = (x + y) % 2 == 0 ? {1, 0, 0, 0.5} : {0, 1, 0, 0.5}
        //         append(&transforms, Transform{glm.vec2{f32(x), f32(y)}*32, {16, 16}, color})
        //     }
        // }

        gl.UniformMatrix4fv(uniforms["proj"].location, 1, false, &proj[0, 0])

        gl.ClearColor(0.5, 0.7, 1.0, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        gl.BufferSubData(gl.SHADER_STORAGE_BUFFER, 0, size_of(Transform) * len(transforms), raw_data(transforms))
        gl.DrawArraysInstanced(gl.TRIANGLES, 0, 6, i32(len(transforms)))
        clear(&transforms)
        
        glfw.SwapBuffers(window)
    }
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
    if key == glfw.KEY_ESCAPE {
        running = false
    }
}

vertex_source := `#version 430 core

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
`

fragment_source := `#version 430 core

in vec4 a_color;
out vec4 FragColor;

void main() {
    FragColor = a_color;
}
`
