package game

import glm "core:math/linalg/glsl"
import "vendor:glfw"
import gl "vendor:OpenGL"

transforms: [dynamic]Transform

MAX_TRANSFORMS :: 5000

Transform :: struct {
    position: glm.vec2,
    size:     glm.vec2,
    color:    glm.vec4,
}

Color :: enum {
    WHITE,
    BLACK,
    RED,
    GREEN,
    BLUE,
}

color_v4 :: proc(color: Color, alpha: f32 = 1) -> glm.vec4 {
    switch color {
    case .WHITE: return {1, 1, 1, alpha}
    case .BLACK: return {0, 0, 0, alpha}
    case .RED:   return {1, 0, 0, alpha}
    case .GREEN: return {0, 1, 0, alpha}
    case .BLUE:  return {0, 0, 1, alpha}
    case: return {}
    }
}

camera_new :: proc(width, height: f32) -> glm.mat4 {
    return glm.mat4Ortho3d(0, width, height, 0, -1, 1)
}

camera_apply :: proc(camera: ^glm.mat4) {
    gl.UniformMatrix4fv(uniforms["proj"].location, 1, false, &camera[0, 0])
}

draw_rect :: proc(position, size: glm.vec2, color: glm.vec4) {
    append(&transforms, Transform{position, size, color})
}

render_transforms :: proc() {
    gl.BufferSubData(gl.SHADER_STORAGE_BUFFER, 0, size_of(Transform) * len(transforms), raw_data(transforms))
    gl.DrawArraysInstanced(gl.TRIANGLES, 0, 6, i32(len(transforms)))
    clear(&transforms)
}

clear_screen :: proc() {
    gl.ClearColor(0.5, 0.7, 1.0, 1.0)
    gl.Clear(gl.COLOR_BUFFER_BIT)
}
