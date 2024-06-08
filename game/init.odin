package game

import glm "core:math/linalg/glsl"
import "vendor:glfw"
import gl "vendor:OpenGL"

running := true
window: glfw.WindowHandle
program: u32
uniforms: gl.Uniforms

window_running :: proc() -> bool {
    return !glfw.WindowShouldClose(window) && running
}

glfw_init :: proc() {
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    if !glfw.Init() {
        panic("GLFW ERROR: could not init glfw")
    }

    window = glfw.CreateWindow(WIDTH, HEIGHT, "WTESTING", nil, nil)

    if window == nil {
        panic("GLFW ERROR: could not create window")
    }

    glfw.MakeContextCurrent(window)
    glfw.SwapInterval(1)
    glfw.SetKeyCallback(window, key_callback)

    gl.load_up_to(4, 6, glfw.gl_set_proc_address)
}

gl_init :: proc() {
    program_ok: bool
    program, program_ok = gl.load_shaders_file("assets/vertex.glsl", "assets/fragment.glsl")

    if !program_ok {
        panic("Failed to create GLSL program")
    }
    
    gl.UseProgram(program)
    
    uniforms = gl.get_uniforms_from_program(program)

    sbo, vao: u32

    gl.GenBuffers(1, &sbo)
    gl.BindBufferBase(gl.SHADER_STORAGE_BUFFER, 0, sbo)
    gl.BufferData(gl.SHADER_STORAGE_BUFFER, size_of(Transform) * MAX_TRANSFORMS, raw_data(transforms), gl.DYNAMIC_DRAW)
    
    gl.Enable(gl.BLEND)
    gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
}

gl_destroy :: proc() {
    defer gl.DeleteProgram(program)
    defer delete(uniforms)
}
