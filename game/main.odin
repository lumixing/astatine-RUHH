package game

import "core:fmt"
import glm "core:math/linalg/glsl"
import "vendor:glfw"
import gl "vendor:OpenGL"

WIDTH :: 800
HEIGHT :: 600

camera := camera_new(WIDTH, HEIGHT)
camera_speed: f32 = 5
render_vec := Vec2{WIDTH, HEIGHT}

main :: proc() {
    glfw_init()
    gl_init()
    defer gl_destroy()

    world := world_new()

    player := new_entity(Player, &world)
    player.position.y = -100
    player.position.x = 350
    player.color = .BLUE
    player.size = {8, 16}
    world.player = player

    y: f32 = 0
    for window_running() {
        y += 1
        glfw.PollEvents()
        w, h := glfw.GetWindowSize(window)
        render_vec = {f32(w), f32(h)}

        player_input(player)
        entity_physics(player, world.colls[:])

        world_render(world)
        entity_render(player^)
        // draw_rect({}, {64, 64}, color_v4(.RED, 0.5))
        // draw_rect({32,y}, {64, 64}, color_v4(.BLUE, 0.5))

        // camera = glm.mat
        proj_view := camera_set_position(camera, player.position)
        camera_apply(&proj_view)

        clear_screen(color_v4(.SKYBLUE))
        render_transforms()

        glfw.SwapBuffers(window)
    }
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
    if key == glfw.KEY_ESCAPE {
        running = false
    }
}
