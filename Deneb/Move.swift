// to               xxxxxxxx xxxxxxxx x1111111
// from             xxxxxxxx xx111111 1xxxxxxx
// flag_promo       xxxxxxxx x1xxxxxx xxxxxxxx
// moved_piece      xxxxx111 1xxxxxxx xxxxxxxx
// captured_piece   x1111xxx xxxxxxxx xxxxxxxx

func to (m: UInt32) -> Int {
    return Int(m & 0x007f)
}

func from (m: UInt32) -> Int {
    return Int((m >> 7) & 0x007f)
}

func flag_promo (m: UInt32) -> Int {
    return Int((m >> 14) & 1)
}

func piece_type (m: UInt32) -> Int {
    return Int((m >> 15) & 0x000f)
}

func cap_piece (m: UInt32) -> Int {
    return Int((m >> 19) & 0x000f)
}

func pack (from: Int, to: Int, pc: Int, cap_pc: Int, flag_promo: Int) -> UInt32 {
    return UInt32((cap_pc << 19) | (pc << 15) | (flag_promo << 14) | (from << 7) | to)
}

func set_null_move () -> UInt32 {
    return UInt32(1 << 23)
}
