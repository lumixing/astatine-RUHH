package game

BLOCK_SIZE :: 8

Block :: enum {
    AIR, GRASS, DIRT, STONE,
}

block_to_color :: proc(block: Block) -> Color {
    switch block {
        case .AIR:   return .BLANK
        case .GRASS: return .GREEN
        case .DIRT:  return .BROWN
        case .STONE: return .GRAY
        case: return .RED
    }
}
