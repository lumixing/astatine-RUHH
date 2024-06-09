package game

import "core:fmt"
import glm "core:math/linalg/glsl"
import "vendor:glfw"
import gl "vendor:OpenGL"

WIDTH :: 800
HEIGHT :: 600

camera_speed: f32 = 5
camera_zoom: f32 = 2
render_vec := Vec2{WIDTH, HEIGHT}

mouse_world_pos :: proc(proj, view: glm.mat4) -> Vec2 {
    x, y := glfw.GetCursorPos(window)
    ndc := glm.vec3{
        (f32(x) * 2) / render_vec.x - 1,
        1 - (f32(y) * 2) / render_vec.y,
        0,
    }

    clip := glm.vec4{ndc.x, ndc.y, ndc.z, 1}
    eye := glm.inverse(proj) * clip
    eye /= eye.w;

    world := glm.inverse(view) * eye
    return Vec2{world.x, world.y}
}

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
        
        if is_key_pressed(.ESCAPE) {
            running = false
        }

        camera := camera_new(f32(w), f32(h))
        camera *= glm.mat4Scale({camera_zoom, camera_zoom, 1})
        player_input(player)
        entity_physics(player, world.colls[:])

        world_render(world)
        entity_render(player^)

        view := camera_get_view(camera, player.position)

        p := mouse_world_pos(camera, view)
        cp := p / BLOCK_SIZE / CHUNK_SIZE
        ci := xy_to_lin(int(cp.x), int(cp.y), WORLD_SIZE)
        bp := p / BLOCK_SIZE
        bi := xy_to_lin(int(bp.x) % CHUNK_SIZE, int(bp.y) % CHUNK_SIZE, CHUNK_SIZE)

        if is_mouse_pressed(.LEFT) && pos_in_world_bounds(p) {
            world.chunks[ci].blocks[bi] = .AIR
            world_update_colls(&world)
        }
        if is_mouse_pressed(.RIGHT) && pos_in_world_bounds(p) {
            world.chunks[ci].blocks[bi] = .DIRT
            world_update_colls(&world)
        }

        inter := camera * view
        camera_apply(&inter)

        clear_screen(color_v4(.SKYBLUE))
        gl.Viewport(0, 0, w, h)
        render_transforms()

        glfw.SwapBuffers(window)
    }
}

pos_in_world_bounds :: proc(pos: Vec2) -> bool {
    return pos.x >= 0 &&
        pos.y >= 0 &&
        pos.x < WORLD_SIZE * CHUNK_SIZE * BLOCK_SIZE &&
        pos.y < WORLD_SIZE * CHUNK_SIZE * BLOCK_SIZE
}
