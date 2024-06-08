package game

import "core:fmt"

Player :: struct {
    using entity: Entity,
    using transform: Transform,
    using sprite: Sprite,
    using body: DynamicBody,
}

player_input :: proc(player: ^Player) {
    player.input = {}
    if is_key_pressed(.D) do player.input.x += 1
    if is_key_pressed(.A) do player.input.x -= 1
    if is_key_pressed(.S) do player.input.y += 1
    if is_key_pressed(.W) do player.input.y -= 1
}
