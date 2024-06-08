package game

import "core:fmt"
import glm "core:math/linalg/glsl"
import "vendor:glfw"
import gl "vendor:OpenGL"

transforms: [dynamic]TransformRect

MAX_TRANSFORMS :: 20000

TransformRect :: struct {
    position: glm.vec2,
    size:     glm.vec2,
    color:    glm.vec4,
}

Color :: enum {
    BLANK,
    WHITE,
    GRAY,
    BLACK,
    RED,
    GREEN,
    BLUE,
    BROWN,
    SKYBLUE,
}

color_v4 :: proc(color: Color, alpha: f32 = 1) -> glm.vec4 {
    switch color {
    case .WHITE: return {1, 1, 1, alpha}
    case .GRAY:  return {.5, .5, .5, alpha}
    case .BLACK: return {0, 0, 0, alpha}
    case .RED:   return {1, 0, 0, alpha}
    case .GREEN: return {0, 1, 0, alpha}
    case .BLUE:  return {0, 0, 1, alpha}
    case .BROWN: return {.5, .4, .3, alpha}
    case .SKYBLUE: return {.5, .7, 1, alpha}
    case .BLANK: return {}
    case: return {}
    }
}

v2_extend :: proc(vec: Vec2, z: f32 = 0) -> glm.vec3 {
    return {vec.x, vec.y, z}
}

camera_new :: proc(width, height: f32) -> glm.mat4 {
    return glm.mat4Ortho3d(0, width, height, 0, -1, 1)
}

camera_set_position :: proc(camera: glm.mat4, position: Vec2) -> glm.mat4 {
    view := glm.identity(glm.mat4) * glm.mat4Translate({-position.x, -position.y, 0}+v2_extend(render_vec)/2)
    return camera * view
}

camera_apply :: proc(camera: ^glm.mat4) {
    gl.UniformMatrix4fv(uniforms["proj"].location, 1, false, &camera[0, 0])
}

draw_rect :: proc(position, size: Vec2, color: glm.vec4) {
    append(&transforms, TransformRect{cast(glm.vec2)position, cast(glm.vec2)size, color})
}

render_transforms :: proc() {
    len_transforms := len(transforms)
    if len_transforms > MAX_TRANSFORMS {
        fmt.println("[WARN] reached max transforms!", len_transforms)
    }

    gl.BufferSubData(gl.SHADER_STORAGE_BUFFER, 0, size_of(TransformRect) * len_transforms, raw_data(transforms))
    gl.DrawArraysInstanced(gl.TRIANGLES, 0, 6, i32(len_transforms))
    clear(&transforms)
}

clear_screen :: proc(v: glm.vec4) {
    gl.ClearColor(v.r, v.g, v.b, v.a)
    gl.Clear(gl.COLOR_BUFFER_BIT)
}
