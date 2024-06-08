package game

import "core:fmt"
import glm "core:math/linalg/glsl"
import "vendor:glfw"
import gl "vendor:OpenGL"

WIDTH :: 800
HEIGHT :: 600

main :: proc() {
    glfw_init()
    gl_init()
    defer gl_destroy()

    camera := camera_new(WIDTH, HEIGHT)

    y: f32 = 0
    for window_running() {
        y += 1
        glfw.PollEvents()
        
        draw_rect({}, {64, 64}, color_v4(.RED, 0.5))
        draw_rect({32,y}, {64, 64}, color_v4(.BLUE, 0.5))

        camera_apply(&camera)

        clear_screen()
        render_transforms()

        glfw.SwapBuffers(window)
    }
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
    if key == glfw.KEY_ESCAPE {
        running = false
    }
}
