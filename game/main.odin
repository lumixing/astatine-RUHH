package game

import "core:fmt"
import glm "core:math/linalg/glsl"
import "vendor:glfw"
import gl "vendor:OpenGL"

WIDTH :: 800
HEIGHT :: 600

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
    
    for window_running() {
        glfw.PollEvents()
        w, h := glfw.GetWindowSize(window)
        render_vec = {f32(w), f32(h)}
        
        camera := camera_new(f32(w), f32(h))
        player_input(player)
        entity_physics(player, world.colls[:])

        world_render(world)
        entity_render(player^)

        proj_view := camera_set_position(camera, player.position)
        camera_apply(&proj_view)

        clear_screen(color_v4(.SKYBLUE))
        gl.Viewport(0, 0, w, h)
        render_transforms()

        glfw.SwapBuffers(window)
    }
}
