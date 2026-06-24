public func is_pinned_on_king(bt: inout BoardTree, sq: Int, idirec: Int, color:Int, la: inout LongAttacks) -> UInt128 {
    let abs_idirec = abs(idirec)
    let bb_occupied = bt.BB_Occupied[Color.Black.rawValue] | bt.BB_Occupied[Color.White.rawValue]
    var bb_attacks: UInt128 = 0
    var bb_ret: UInt128 = 0
    switch abs_idirec {
    case Direction.Direc_File_U2d.rawValue:
        bb_attacks = la.ABB_File_Attacks[sq][bb_occupied & ABB_File_Mask_Ex[sq]]!
        if bb_attacks & ABB_Mask[bt.SQ_King[color]] > 0 {
            bb_ret = bb_attacks & (bt.BB_Piece[color ^ 1][Piece.Rook.rawValue] | bt.BB_Piece[color ^ 1][Piece.Dragon.rawValue] | bt.BB_Piece[color ^ 1][Piece.Lance.rawValue])
        }
    case Direction.Direc_Rank_L2r.rawValue:
        bb_attacks = la.ABB_Rank_Attacks[sq][bb_occupied & ABB_Rank_Mask_Ex[sq]]!
        if bb_attacks & ABB_Mask[bt.SQ_King[color]] > 0 {
            bb_ret = bb_attacks & (bt.BB_Piece[color ^ 1][Piece.Rook.rawValue] | bt.BB_Piece[color ^ 1][Piece.Dragon.rawValue])
        }
    case Direction.Direc_Diag1_U2d.rawValue:
        bb_attacks = la.ABB_Diag1_Attacks[sq][bb_occupied & ABB_Diag1_Mask_Ex[sq]]!
        if bb_attacks & ABB_Mask[bt.SQ_King[color]] > 0 {
            bb_ret = bb_attacks & (bt.BB_Piece[color ^ 1][Piece.Bishop.rawValue] | bt.BB_Piece[color ^ 1][Piece.Horse.rawValue])
        }
    case Direction.Direc_Diag2_U2d.rawValue:
        bb_attacks = la.ABB_Diag2_Attacks[sq][bb_occupied & ABB_Diag2_Mask_Ex[sq]]!
        if bb_attacks & ABB_Mask[bt.SQ_King[color]] > 0 {
            bb_ret = bb_attacks & (bt.BB_Piece[color ^ 1][Piece.Bishop.rawValue] | bt.BB_Piece[color ^ 1][Piece.Horse.rawValue])
        }
    default:
        bb_ret = 0
    }
    return bb_ret
}

public func is_mate_pawn_drop(bt: inout BoardTree, sq_drop: Int, color:Int, la: inout LongAttacks) -> Bool {
    if color == Color.White.rawValue {
        if (sq_drop - 9) >= 0 && bt.Board[sq_drop - 9] != -Piece.King.rawValue
        {
            return false
        }
    }
    else {
        if (sq_drop + 9) < Square_NB && bt.Board[sq_drop + 9] != Piece.King.rawValue
        {
            return false
        }
    }
    var bb_sum = bt.BB_Piece[color][Piece.Knight.rawValue] & ABB_Piece_Attacks[color ^ 1][Piece.Knight.rawValue][sq_drop]
    bb_sum |= bt.BB_Piece[color][Piece.Silver.rawValue] & ABB_Piece_Attacks[color ^ 1][Piece.Silver.rawValue][sq_drop]
    let bb_total_gold = bt.BB_Piece[color][Piece.Gold.rawValue] | bt.BB_Piece[color][Piece.Pro_Pawn.rawValue] | bt.BB_Piece[color][Piece.Pro_Lance.rawValue] | bt.BB_Piece[color][Piece.Pro_Knight.rawValue] | bt.BB_Piece[color][Piece.Pro_Silver.rawValue]
    bb_sum |= bb_total_gold & ABB_Piece_Attacks[color ^ 1][Piece.Gold.rawValue][sq_drop]
    let bb_occupied = bt.BB_Occupied[Color.Black.rawValue] | bt.BB_Occupied[Color.White.rawValue]
    let bb_bh = bt.BB_Piece[color][Piece.Bishop.rawValue] | bt.BB_Piece[color][Piece.Horse.rawValue]
    bb_sum |= bb_bh & la.ABB_Diagonal_Attacks[sq_drop][ABB_Diagonal_Mask_Ex[sq_drop] & bb_occupied]!
    let bb_rd = bt.BB_Piece[color][Piece.Rook.rawValue] | bt.BB_Piece[color][Piece.Dragon.rawValue]
    bb_sum |= bb_rd & la.ABB_Cross_Attacks[sq_drop][ABB_Cross_Mask_Ex[sq_drop] & bb_occupied]!
    let bb_hd = bt.BB_Piece[color][Piece.Horse.rawValue] | bt.BB_Piece[color][Piece.Dragon.rawValue]
    bb_sum |= bb_hd & ABB_Piece_Attacks[color][Piece.King.rawValue][sq_drop]
    while bb_sum > 0 {
        let ifrom = Square_NB - bb_sum.trailingZeroBitCount - 1
        bb_sum ^= ABB_Mask[ifrom]
        if is_discover_king(bt:&bt, ifrom:ifrom, ito:sq_drop, color:color, la:&la) {
            continue
        }
        return false
    }
    let iking = bt.SQ_King[color]
    var bret = true
    bt.BB_Occupied[color ^ 1] ^= ABB_Mask[sq_drop]
    var bb_move = ABB_Piece_Attacks[color][Piece.King.rawValue][iking] & ~bt.BB_Occupied[color] & BB_Full
    while bb_move > 0 {
        let ito = Square_NB - bb_move.trailingZeroBitCount - 1
        if is_attacked(bt:&bt, sq:ito, color:color, la:&la) == 0 {
            bret = false
            break
        }
        bb_move ^= ABB_Mask[ito]
    }
    bt.BB_Occupied[color ^ 1] ^= ABB_Mask[sq_drop]
    return bret
}

public func attacks_to_piece(bt: inout BoardTree, sq: Int, color:Int, la: inout LongAttacks) -> UInt128 {
    let bb_occupied = bt.BB_Occupied[Color.Black.rawValue] | bt.BB_Occupied[Color.White.rawValue]
    var bb_ret: UInt128 = bt.BB_Piece[color][Piece.Pawn.rawValue] & ABB_Piece_Attacks[color ^ 1][Piece.Pawn.rawValue][sq]
    bb_ret |= bt.BB_Piece[color][Piece.Knight.rawValue] & ABB_Piece_Attacks[color ^ 1][Piece.Knight.rawValue][sq]
    bb_ret |= bt.BB_Piece[color][Piece.Silver.rawValue] & ABB_Piece_Attacks[color ^ 1][Piece.Silver.rawValue][sq]
    let bb_total_gold = bt.BB_Piece[color][Piece.Gold.rawValue] | bt.BB_Piece[color][Piece.Pro_Pawn.rawValue] | bt.BB_Piece[color][Piece.Pro_Lance.rawValue] | bt.BB_Piece[color][Piece.Pro_Knight.rawValue] | bt.BB_Piece[color][Piece.Pro_Silver.rawValue]
    bb_ret |= bb_total_gold & ABB_Piece_Attacks[color ^ 1][Piece.Gold.rawValue][sq]
    let bb_hdk = bt.BB_Piece[color][Piece.Horse.rawValue] | bt.BB_Piece[color][Piece.Dragon.rawValue] | bt.BB_Piece[color][Piece.King.rawValue]
    bb_ret |= bb_hdk & ABB_Piece_Attacks[color ^ 1][Piece.King.rawValue][sq]
    let bb_bh = bt.BB_Piece[color][Piece.Bishop.rawValue] | bt.BB_Piece[color][Piece.Horse.rawValue]
    bb_ret |= bb_bh & la.ABB_Diagonal_Attacks[sq][ABB_Diagonal_Mask_Ex[sq] & bb_occupied]!
    let bb_rd = bt.BB_Piece[color][Piece.Rook.rawValue] | bt.BB_Piece[color][Piece.Dragon.rawValue]
    bb_ret |= bb_rd & la.ABB_Cross_Attacks[sq][ABB_Cross_Mask_Ex[sq] & bb_occupied]!
    let bb_lance_attacks = la.ABB_Lance_Attacks[color ^ 1][sq][ABB_Lance_Mask_Ex[color ^ 1][sq] & bb_occupied]!
    bb_ret |= bt.BB_Piece[color][Piece.Lance.rawValue] & bb_lance_attacks
    return bb_ret
}

public func is_attacked(bt: inout BoardTree, sq: Int, color:Int,  la: inout LongAttacks) -> UInt128 {
    let bb_occupied = bt.BB_Occupied[Color.Black.rawValue] | bt.BB_Occupied[Color.White.rawValue]
    var bb_ret: UInt128 = 0
    if (sq + Delta_Table[color]) >= 0 && (sq + Delta_Table[color]) < Square_NB {
        if (bt.Board[sq + Delta_Table[color]]) == (Sign_Table[color] * Piece.Pawn.rawValue) {
            bb_ret = ABB_Mask[sq + Delta_Table[color]]
        }
    }
    bb_ret |= bt.BB_Piece[color ^ 1][Piece.Knight.rawValue] & ABB_Piece_Attacks[color][Piece.Knight.rawValue][sq]
    bb_ret |= bt.BB_Piece[color ^ 1][Piece.Silver.rawValue] & ABB_Piece_Attacks[color][Piece.Silver.rawValue][sq]
    let bb_total_gold = bt.BB_Piece[color ^ 1][Piece.Gold.rawValue] | bt.BB_Piece[color ^ 1][Piece.Pro_Pawn.rawValue] | bt.BB_Piece[color ^ 1][Piece.Pro_Lance.rawValue] | bt.BB_Piece[color ^ 1][Piece.Pro_Knight.rawValue] | bt.BB_Piece[color ^ 1][Piece.Pro_Silver.rawValue]
    bb_ret |= bb_total_gold & ABB_Piece_Attacks[color][Piece.Gold.rawValue][sq]
    let bb_hdk = bt.BB_Piece[color ^ 1][Piece.Horse.rawValue] | bt.BB_Piece[color ^ 1][Piece.Dragon.rawValue] | bt.BB_Piece[color ^ 1][Piece.King.rawValue]
    bb_ret |= bb_hdk & ABB_Piece_Attacks[color][Piece.King.rawValue][sq]
    let bb_bh = bt.BB_Piece[color ^ 1][Piece.Bishop.rawValue] | bt.BB_Piece[color ^ 1][Piece.Horse.rawValue]
    bb_ret |= bb_bh & la.ABB_Diagonal_Attacks[sq][ABB_Diagonal_Mask_Ex[sq] & bb_occupied]!
    let bb_rd = bt.BB_Piece[color ^ 1][Piece.Rook.rawValue] | bt.BB_Piece[color ^ 1][Piece.Dragon.rawValue]
    bb_ret |= bb_rd & la.ABB_Cross_Attacks[sq][ABB_Cross_Mask_Ex[sq] & bb_occupied]!
    let bb_lance_attacks = la.ABB_Lance_Attacks[color][sq][ABB_Lance_Mask_Ex[color][sq] & bb_occupied]!
    bb_ret |= bt.BB_Piece[color ^ 1][Piece.Lance.rawValue] & bb_lance_attacks
    return bb_ret
}

public func is_attacked_by_long_pieces(bt: inout BoardTree, sq: Int, color:Int, la: inout LongAttacks) -> UInt128 {
    let bb_occupied = bt.BB_Occupied[Color.Black.rawValue] | bt.BB_Occupied[Color.White.rawValue]
    var bb_ret: UInt128 = 0
    let bb_bh = bt.BB_Piece[color ^ 1][Piece.Bishop.rawValue] | bt.BB_Piece[color ^ 1][Piece.Horse.rawValue]
    bb_ret |= bb_bh & la.ABB_Diagonal_Attacks[sq][ABB_Diagonal_Mask_Ex[sq] & bb_occupied]!
    let bb_rd = bt.BB_Piece[color ^ 1][Piece.Rook.rawValue] | bt.BB_Piece[color ^ 1][Piece.Dragon.rawValue]
    bb_ret |= bb_rd & la.ABB_Cross_Attacks[sq][ABB_Cross_Mask_Ex[sq] & bb_occupied]!
    let bb_lance_attacks = la.ABB_Lance_Attacks[color][sq][ABB_Lance_Mask_Ex[color][sq] & bb_occupied]!
    bb_ret |= bt.BB_Piece[color ^ 1][Piece.Lance.rawValue] & bb_lance_attacks
    return bb_ret
}

public func attacks_to_long_piece(bt: inout BoardTree, sq: Int, color:Int, la: inout LongAttacks) -> UInt128 {
    let bb_occupied = bt.BB_Occupied[Color.Black.rawValue] | bt.BB_Occupied[Color.White.rawValue]
    let bb_bh = bt.BB_Piece[color][Piece.Bishop.rawValue] | bt.BB_Piece[color][Piece.Horse.rawValue]
    var bb_ret = bb_bh & la.ABB_Diagonal_Attacks[sq][ABB_Diagonal_Mask_Ex[sq] & bb_occupied]!
    let bb_rd = bt.BB_Piece[color][Piece.Rook.rawValue] | bt.BB_Piece[color][Piece.Dragon.rawValue]
    bb_ret |= bb_rd & la.ABB_Cross_Attacks[sq][ABB_Cross_Mask_Ex[sq] & bb_occupied]!
    let bb_lance_attacks = la.ABB_Lance_Attacks[color ^ 1][sq][ABB_Lance_Mask_Ex[color ^ 1][sq] & bb_occupied]!
    bb_ret |= bt.BB_Piece[color][Piece.Lance.rawValue] & bb_lance_attacks
    return bb_ret;
}

public func is_discover_king(bt: inout BoardTree, ifrom: Int, ito: Int, color:Int, la: inout LongAttacks) -> Bool {
    let idirec = Adirec[bt.SQ_King[color]][ifrom]
    if idirec != Direction.Direc_Misc.rawValue && idirec != Adirec[bt.SQ_King[color]][ito] && is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:color, la:&la) != 0
    {
        return true
    }
    return false
}

public func is_discover_king2(bt: inout BoardTree, ifrom: Int, ito: Int, color:Int, ipiece:Int, la: inout LongAttacks) -> Bool {
    let idirec = Adirec[bt.SQ_King[color]][ifrom]
    bt.BB_Piece[color][ipiece] ^= ABB_Mask[ifrom]
    bt.BB_Occupied[color] ^= ABB_Mask[ifrom]
    if idirec != Direction.Direc_Misc.rawValue && idirec != Adirec[bt.SQ_King[color]][ito] && is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:color, la:&la) != 0
    {
        bt.BB_Piece[color][ipiece] ^= ABB_Mask[ifrom]
        bt.BB_Occupied[color] ^= ABB_Mask[ifrom]
        return true
    }
    bt.BB_Piece[color][ipiece] ^= ABB_Mask[ifrom]
    bt.BB_Occupied[color] ^= ABB_Mask[ifrom]
    return false
}
