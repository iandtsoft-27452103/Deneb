public func gen_drop(bt: inout BoardTree, moves: inout [UInt32], la: inout LongAttacks) {
    let color = bt.CurrentColor
    var bb_piece_can_drop: [UInt128] = [ 0, 0, 0, 0, 0, 0, 0, 0 ]
    let bb_occupied = bt.BB_Occupied[Color.Black.rawValue] | bt.BB_Occupied[Color.White.rawValue]
    let bb_empty = ~bb_occupied & BB_Full
    if (bt.Hand[color] & Hand_Mask[Piece.Pawn.rawValue]) > 0 {
        for i in File.File1.rawValue...File.File9.rawValue {
            let bb = BB_File[i] & bt.BB_Piece[color][Piece.Pawn.rawValue]
            if bb == 0 {
                bb_piece_can_drop[Piece.Pawn.rawValue] |= ~bt.BB_Piece[color][Piece.Pawn.rawValue] & BB_Full & BB_Pawn_Lance_Can_Drop[color] & bb_empty & BB_File[i]
            }
        }
        let sq = bt.SQ_King[color ^ 1] + Delta_Table[color ^ 1]
        if sq >= 0 && sq < Square_NB {
            let bb = bb_piece_can_drop[Piece.Pawn.rawValue] & ABB_Mask[sq]
            if bt.Board[sq] == Piece.Empty.rawValue && bb > 0 {
                if is_mate_pawn_drop(bt:&bt, sq_drop:sq, color:(color ^ 1), la:&la) {
                    bb_piece_can_drop[Piece.Pawn.rawValue] ^= ABB_Mask[sq]
                }
            }
        }
    }
    bb_piece_can_drop[Piece.Lance.rawValue] = BB_Pawn_Lance_Can_Drop[color] & bb_empty
    bb_piece_can_drop[Piece.Knight.rawValue] = BB_Knight_Can_Drop[color] & bb_empty
    bb_piece_can_drop[Piece.Silver.rawValue] = BB_Others_Can_Drop & bb_empty
    bb_piece_can_drop[Piece.Gold.rawValue] = bb_piece_can_drop[Piece.Silver.rawValue]
    bb_piece_can_drop[Piece.Bishop.rawValue] = bb_piece_can_drop[Piece.Silver.rawValue]
    bb_piece_can_drop[Piece.Rook.rawValue] = bb_piece_can_drop[Piece.Silver.rawValue]
    for i in Piece.Pawn.rawValue...Piece.Rook.rawValue {
        if (bt.Hand[color] & Hand_Mask[i]) > 0 {
            var bb = bb_piece_can_drop[i]
            while bb > 0 {
                let ifrom = Square_NB + i - 1
                let ito = Square_NB - bb.trailingZeroBitCount - 1
                bb ^= ABB_Mask[ito]
                let m = pack(from:ifrom, to:ito, pc:i, cap_pc:0, flag_promo:0)
                moves.append(m)
            }
        }
    }
}

public func gen_no_cap(bt: inout BoardTree, moves: inout [UInt32], la: inout LongAttacks) {
    let color = bt.CurrentColor
    let bb_occupied = bt.BB_Occupied[Color.Black.rawValue] | bt.BB_Occupied[Color.White.rawValue]
    let bb_empty = ~bb_occupied & BB_Full
    var bb_from = bt.BB_Piece[color][Piece.Pawn.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = ABB_Piece_Attacks[color][Piece.Pawn.rawValue][ifrom] & bb_empty
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let flag_promo = (BB_Rev_Color_Position[color] & ABB_Mask[ito]) > 0 ? 1 : 0
            let m = pack(from:ifrom, to:ito, pc:Piece.Pawn.rawValue, cap_pc:0, flag_promo:flag_promo)
            moves.append(m)
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Knight.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = ABB_Piece_Attacks[color][Piece.Knight.rawValue][ifrom] & bb_empty
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let bb_can_promote = BB_Rev_Color_Position[color] & ABB_Mask[ito]
            if bb_can_promote > 0 {
                let m = pack(from:ifrom, to:ito, pc:Piece.Knight.rawValue, cap_pc:0, flag_promo:1)
                moves.append(m)
            }
            if (BB_Knight_Must_Promote[color] & ABB_Mask[ito]) == 0 {
                let m = pack(from:ifrom, to:ito, pc:Piece.Knight.rawValue, cap_pc:0, flag_promo:0)
                moves.append(m)
            }
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Silver.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = ABB_Piece_Attacks[color][Piece.Silver.rawValue][ifrom] & bb_empty
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let bb_can_promote = BB_Rev_Color_Position[color] & (ABB_Mask[ifrom] | ABB_Mask[ito])
            if bb_can_promote > 0 {
                let m = pack(from:ifrom, to:ito, pc:Piece.Silver.rawValue, cap_pc:0, flag_promo:1)
                moves.append(m)
            }
            let m = pack(from:ifrom, to:ito, pc:Piece.Silver.rawValue, cap_pc:0, flag_promo:0)
            moves.append(m)
        }
    }
    let piece_list = [ Piece.Gold.rawValue, Piece.King.rawValue, Piece.Pro_Pawn.rawValue, Piece.Pro_Lance.rawValue, Piece.Pro_Knight.rawValue, Piece.Pro_Silver.rawValue ]
    let limit = piece_list.count - 1
    for i in 0...limit {
        bb_from = bt.BB_Piece[color][piece_list[i]]
        while bb_from > 0 {
            let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
            bb_from ^= ABB_Mask[ifrom]
            var bb_to = ABB_Piece_Attacks[color][piece_list[i]][ifrom] & bb_empty
            while bb_to > 0 {
                let ito = Square_NB - bb_to.trailingZeroBitCount - 1
                bb_to ^= ABB_Mask[ito]
                let m = pack(from:ifrom, to:ito, pc:piece_list[i], cap_pc:0, flag_promo:0)
                moves.append(m)
            }
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Lance.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = la.ABB_Lance_Attacks[color][ifrom][ABB_Lance_Mask_Ex[color][ifrom] & bb_occupied]! & bb_empty
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let bb_can_promote = BB_Rev_Color_Position[color] & ABB_Mask[ito]
            if bb_can_promote > 0 {
                let m = pack(from:ifrom, to:ito, pc:Piece.Lance.rawValue, cap_pc:0, flag_promo:1)
                moves.append(m)
            }
            if (BB_Knight_Must_Promote[color] & ABB_Mask[ito]) == 0 {
                let m = pack(from:ifrom, to:ito, pc:Piece.Lance.rawValue, cap_pc:0, flag_promo:0)
                moves.append(m)
            }
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Bishop.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = la.ABB_Diagonal_Attacks[ifrom][ABB_Diagonal_Mask_Ex[ifrom] & bb_occupied]! & bb_empty
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let flag_promo = (BB_Rev_Color_Position[color] & (ABB_Mask[ifrom] | ABB_Mask[ito])) > 0 ? 1 : 0
            let m = pack(from:ifrom, to:ito, pc:Piece.Bishop.rawValue, cap_pc:0, flag_promo:flag_promo)
            moves.append(m)
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Horse.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = (la.ABB_Diagonal_Attacks[ifrom][ABB_Diagonal_Mask_Ex[ifrom] & bb_occupied]! | ABB_Piece_Attacks[color][Piece.King.rawValue][ifrom]) & bb_empty
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:ifrom, to:ito, pc:Piece.Horse.rawValue, cap_pc:0, flag_promo:0)
            moves.append(m)
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Rook.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = la.ABB_Cross_Attacks[ifrom][ABB_Cross_Mask_Ex[ifrom] & bb_occupied]! & bb_empty
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let flag_promo = (BB_Rev_Color_Position[color] & (ABB_Mask[ifrom] | ABB_Mask[ito])) > 0 ? 1 : 0
            let m = pack(from:ifrom, to:ito, pc:Piece.Rook.rawValue, cap_pc:0, flag_promo:flag_promo)
            moves.append(m)
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Dragon.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = (la.ABB_Cross_Attacks[ifrom][ABB_Cross_Mask_Ex[ifrom] & bb_occupied]! | ABB_Piece_Attacks[color][Piece.King.rawValue][ifrom]) & bb_empty
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:ifrom, to:ito, pc:Piece.Dragon.rawValue, cap_pc:0, flag_promo:0)
            moves.append(m)
        }
    }
}

public func gen_cap(bt: inout BoardTree, moves: inout [UInt32], la: inout LongAttacks) {
    let color = bt.CurrentColor
    let bb_occupied = bt.BB_Occupied[Color.Black.rawValue] | bt.BB_Occupied[Color.White.rawValue]
    let bb_can_cap = bt.BB_Occupied[color ^ 1]
    var bb_from = bt.BB_Piece[color][Piece.Pawn.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = ABB_Piece_Attacks[color][Piece.Pawn.rawValue][ifrom] & bb_can_cap
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let flag_promo = (BB_Rev_Color_Position[color] & ABB_Mask[ito]) > 0 ? 1 : 0
            let m = pack(from:ifrom, to:ito, pc:Piece.Pawn.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:flag_promo)
            moves.append(m)
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Knight.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = ABB_Piece_Attacks[color][Piece.Knight.rawValue][ifrom] & bb_can_cap
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let bb_can_promote = BB_Rev_Color_Position[color] & ABB_Mask[ito]
            if bb_can_promote > 0 {
                let m = pack(from:ifrom, to:ito, pc:Piece.Knight.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:1)
                moves.append(m)
            }
            if (BB_Knight_Must_Promote[color] & ABB_Mask[ito]) == 0 {
                let m = pack(from:ifrom, to:ito, pc:Piece.Knight.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:0)
                moves.append(m)
            }
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Silver.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = ABB_Piece_Attacks[color][Piece.Silver.rawValue][ifrom] & bb_can_cap
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let bb_can_promote = BB_Rev_Color_Position[color] & ABB_Mask[ito]
            if bb_can_promote > 0 {
                let m = pack(from:ifrom, to:ito, pc:Piece.Silver.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:1)
                moves.append(m)
            }
            let m = pack(from:ifrom, to:ito, pc:Piece.Silver.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:0)
            moves.append(m)
        }
    }
    let piece_list = [ Piece.Gold.rawValue, Piece.King.rawValue, Piece.Pro_Pawn.rawValue, Piece.Pro_Lance.rawValue, Piece.Pro_Knight.rawValue, Piece.Pro_Silver.rawValue ]
    let limit = piece_list.count - 1
    for i in 0...limit {
        bb_from = bt.BB_Piece[color][piece_list[i]]
        while bb_from > 0 {
            let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
            bb_from ^= ABB_Mask[ifrom]
            var bb_to = ABB_Piece_Attacks[color][piece_list[i]][ifrom] & bb_can_cap
            while bb_to > 0 {
                let ito = Square_NB - bb_to.trailingZeroBitCount - 1
                bb_to ^= ABB_Mask[ito]
                let m = pack(from:ifrom, to:ito, pc:piece_list[i], cap_pc:abs(bt.Board[ito]), flag_promo:0)
                moves.append(m)
            }
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Lance.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = la.ABB_Lance_Attacks[color][ifrom][ABB_Lance_Mask_Ex[color][ifrom] & bb_occupied]! & bb_can_cap
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let bb_can_promote = BB_Rev_Color_Position[color] & ABB_Mask[ito]
            if bb_can_promote > 0 {
                let m = pack(from:ifrom, to:ito, pc:Piece.Lance.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:1)
                moves.append(m)
            }
            if (BB_Knight_Must_Promote[color] & ABB_Mask[ito]) == 0 {
                let m = pack(from:ifrom, to:ito, pc:Piece.Lance.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:0)
                moves.append(m)
            }
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Bishop.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = la.ABB_Diagonal_Attacks[ifrom][ABB_Diagonal_Mask_Ex[ifrom] & bb_occupied]! & bb_can_cap
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let flag_promo = (BB_Rev_Color_Position[color] & (ABB_Mask[ifrom] | ABB_Mask[ito])) > 0 ? 1 : 0
            let m = pack(from:ifrom, to:ito, pc:Piece.Bishop.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:flag_promo)
            moves.append(m)
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Horse.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = (la.ABB_Diagonal_Attacks[ifrom][ABB_Diagonal_Mask_Ex[ifrom] & bb_occupied]! | ABB_Piece_Attacks[color][Piece.King.rawValue][ifrom]) & bb_can_cap
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:ifrom, to:ito, pc:Piece.Horse.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:0)
            moves.append(m)
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Rook.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = la.ABB_Cross_Attacks[ifrom][ABB_Cross_Mask_Ex[ifrom] & bb_occupied]! & bb_can_cap
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let flag_promo = (BB_Rev_Color_Position[color] & (ABB_Mask[ifrom] | ABB_Mask[ito])) > 0 ? 1 : 0
            let m = pack(from:ifrom, to:ito, pc:Piece.Rook.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:flag_promo)
            moves.append(m)
        }
    }
    bb_from = bt.BB_Piece[color][Piece.Dragon.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = (la.ABB_Cross_Attacks[ifrom][ABB_Cross_Mask_Ex[ifrom] & bb_occupied]! | ABB_Piece_Attacks[color][Piece.King.rawValue][ifrom]) & bb_can_cap
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:ifrom, to:ito, pc:Piece.Dragon.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:0)
            moves.append(m)
        }
    }
}

public func gen_evasion(bt: inout BoardTree, moves: inout [UInt32], la: inout LongAttacks, h: inout Hash) {
    let color = bt.CurrentColor
    var bb_piece_can_drop: [UInt128] = [ 0, 0, 0, 0, 0, 0, 0, 0 ]
    var flag = false
    let sq_king = bt.SQ_King[color]
    let ifrom = sq_king
    bt.BB_Occupied[color] ^= ABB_Mask[ifrom]
    let bb_not_color = ~bt.BB_Occupied[color] & BB_Full
    var bb_to = ABB_Piece_Attacks[color][Piece.King.rawValue][sq_king] & bb_not_color
    while bb_to > 0 {
        let ito = Square_NB - bb_to.trailingZeroBitCount - 1
        if is_attacked(bt:&bt, sq:ito, color:color, la:&la) == 0 {
            let m = pack(from:ifrom, to:ito, pc:Piece.King.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:0)
            moves.append(m)
        }
        bb_to ^= ABB_Mask[ito]
    }
    bt.BB_Occupied[color] ^= ABB_Mask[ifrom]
    let bb_checker = attacks_to_piece(bt:&bt, sq:sq_king, color:(color ^ 1), la:&la)
    let checker_num = bb_checker.nonzeroBitCount
    if checker_num == 2 {
        return
    }
    let sq_checker = Square_NB - bb_checker.trailingZeroBitCount - 1
    var bb_cap_checker = attacks_to_piece(bt:&bt, sq:sq_checker, color:color, la:&la)
    let ito = sq_checker
    while bb_cap_checker > 0 {
        let ifrom = Square_NB - bb_cap_checker.trailingZeroBitCount - 1
        bb_cap_checker ^= ABB_Mask[ifrom]
        if ifrom == sq_king {
            continue
        }
        let ipiece = abs(bt.Board[ifrom])
        if ipiece == 0 {
            continue
        }
        let idirec = Adirec[ifrom][ito]
        flag = false
        if is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:color, la:&la) == 0 {
            if Set_Piece_Can_Promote0.contains(ipiece)  && (ABB_Piece_Attacks[color][ipiece][ifrom] & ABB_Mask[sq_checker]) > 0 && (ABB_Piece_Attacks[color][ipiece][ifrom] & BB_Rev_Color_Position[color]) > 0 {
                let m = pack(from:ifrom, to:ito, pc:ipiece, cap_pc:abs(bt.Board[ito]), flag_promo:1)
                bt.do_move(move:m, h:&h)
                if is_attacked(bt:&bt, sq:sq_king, color:color, la:&la) == 0 {
                    moves.append(m)
                }
                bt.undo_move(move:m)
                if ipiece == Piece.Pawn.rawValue {
                    flag = true
                }
            }
            if Set_Piece_Can_Promote1.contains(ipiece) {
                if (BB_Rev_Color_Position[color] & ABB_Mask[ifrom]) > 0 || (BB_Rev_Color_Position[color] & ABB_Mask[ito]) > 0 {
                    let m = pack(from:ifrom, to:ito, pc:ipiece, cap_pc:abs(bt.Board[ito]), flag_promo:1)
                    bt.do_move(move:m, h:&h)
                    if is_attacked(bt:&bt, sq:sq_king, color:color, la:&la) == 0 {
                        moves.append(m)
                    }
                    bt.undo_move(move:m)
                    if ipiece != Piece.Silver.rawValue {
                        flag = true
                    }
                }
            }
            if !flag {
                let m = pack(from:ifrom, to:ito, pc:ipiece, cap_pc:abs(bt.Board[ito]), flag_promo:0)
                bt.do_move(move:m, h:&h)
                if is_attacked(bt:&bt, sq:sq_king, color:color, la:&la) == 0 {
                    moves.append(m)
                }
                bt.undo_move(move:m)
            }
        }
    }
    let checker = abs(bt.Board[sq_checker])
    if !Set_Long_Attack_Pieces.contains(checker) {
        return
    }
    if (bb_checker & ABB_Piece_Attacks[color][Piece.King.rawValue][sq_king]) > 0 {
        return
    }
    else {
        if Set_Long_Attack_Pieces.contains(checker) {
            var bb_inter = ABB_Obstacles[sq_king][sq_checker]
            while bb_inter > 0 {
                let ito = Square_NB - bb_inter.trailingZeroBitCount - 1
                bb_inter ^= ABB_Mask[ito]
                var bb_defender = attacks_to_piece(bt:&bt, sq:ito, color:color, la:&la)
                while bb_defender > 0 {
                    let ifrom = Square_NB - bb_defender.trailingZeroBitCount - 1
                    bb_defender ^= ABB_Mask[ifrom]
                    if ifrom == sq_king {
                        continue
                    }
                    let ipiece = abs(bt.Board[ifrom])
                    let idirec = Adirec[sq_king][ifrom]
                    flag = false
                    if idirec == Direction.Direc_Misc.rawValue || is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:color, la:&la) == 0 {
                        if Set_Piece_Can_Promote0.contains(ipiece) {
                            if ipiece != Piece.Lance.rawValue && (ABB_Piece_Attacks[color][ipiece][ifrom] & BB_Rev_Color_Position[color]) > 0 {
                                let m = pack(from:ifrom, to:ito, pc:ipiece, cap_pc:abs(bt.Board[ito]), flag_promo:1)
                                moves.append(m)
                                if ipiece == Piece.Pawn.rawValue {
                                    flag = true
                                }
                            }
                            else if ipiece == Piece.Lance.rawValue {
                                let bb_occupied = bt.BB_Occupied[Color.Black.rawValue] | bt.BB_Occupied[Color.White.rawValue]
                                if la.ABB_Lance_Attacks[color][ifrom][ABB_Lance_Mask_Ex[color][ifrom] & bb_occupied]! > 0 && (BB_Rev_Color_Position[color] & ABB_Mask[ito]) > 0 {
                                    let m = pack(from:ifrom, to:ito, pc:ipiece, cap_pc:abs(bt.Board[ito]), flag_promo:1)
                                    moves.append(m)
                                }
                            }
                        }
                        if Set_Piece_Can_Promote1.contains(ipiece) {
                            if (BB_Rev_Color_Position[color] & ABB_Mask[ifrom]) > 0 || (BB_Rev_Color_Position[color] & ABB_Mask[ito]) > 0 {
                                let m = pack(from:ifrom, to:ito, pc:ipiece, cap_pc:abs(bt.Board[ito]), flag_promo:1)
                                moves.append(m)
                                if ipiece != Piece.Silver.rawValue {
                                    flag = true
                                }
                            }
                        }
                        if !flag {
                            if (ipiece == Piece.Knight.rawValue || ipiece == Piece.Lance.rawValue) && (BB_Knight_Must_Promote[color] & ABB_Mask[ito]) > 0 {
                                continue
                            }
                            let m = pack(from:ifrom, to:ito, pc:ipiece, cap_pc:abs(bt.Board[ito]), flag_promo:0)
                            moves.append(m)
                        }
                    }
                }
            }
        }
        let bb_empty = ABB_Obstacles[sq_king][sq_checker]
        bb_piece_can_drop[Piece.Pawn.rawValue] = 0
        if ((bt.Hand[color] & Hand_Mask[Piece.Pawn.rawValue]) > 0) {
            for i in File.File1.rawValue...File.File9.rawValue {
                if (BB_File[i] & bt.BB_Piece[color][Piece.Pawn.rawValue]) == 0 {
                    let bb = (~bt.BB_Piece[color][Piece.Pawn.rawValue] & BB_Full) & BB_Pawn_Lance_Can_Drop[color] & bb_empty & BB_File[i]
                    bb_piece_can_drop[Piece.Pawn.rawValue] = bb_piece_can_drop[Piece.Pawn.rawValue] | bb
                }
            }
            let sq = bt.SQ_King[color] + Delta_Table[color]
            if (sq >= 0 && sq < Square_NB) && bt.Board[sq] == Piece.Empty.rawValue && (bb_piece_can_drop[Piece.Pawn.rawValue] & ABB_Mask[sq]) == 0 {
                if is_mate_pawn_drop(bt:&bt, sq_drop:sq, color:color, la:&la) {
                    bb_piece_can_drop[Piece.Pawn.rawValue] ^= ABB_Mask[sq]
                }
            }
        }
        bb_piece_can_drop[Piece.Lance.rawValue] = BB_Pawn_Lance_Can_Drop[color] & bb_empty
        bb_piece_can_drop[Piece.Knight.rawValue] = BB_Knight_Can_Drop[color] & bb_empty
        bb_piece_can_drop[Piece.Silver.rawValue] = BB_Others_Can_Drop & bb_empty
        bb_piece_can_drop[Piece.Gold.rawValue] = bb_piece_can_drop[Piece.Silver.rawValue]
        bb_piece_can_drop[Piece.Bishop.rawValue] = bb_piece_can_drop[Piece.Silver.rawValue]
        bb_piece_can_drop[Piece.Rook.rawValue] = bb_piece_can_drop[Piece.Silver.rawValue]
        for i in Piece.Pawn.rawValue...Piece.Rook.rawValue {
            if (bt.Hand[color] & Hand_Mask[i]) > 0 {
                var bb_object = bb_piece_can_drop[i]
                while bb_object > 0 {
                    let ifrom = Square_NB + i - 1
                    let ito = Square_NB - bb_object.trailingZeroBitCount - 1
                    bb_object ^= ABB_Mask[ito]
                    let m = pack(from:ifrom, to:ito, pc:i, cap_pc:0, flag_promo:0)
                    moves.append(m)
                }
            }
        }
    }
}

// generate moves that make my own king to be discovered check
public func gen_check(bt: inout BoardTree, moves: inout [UInt32], la: inout LongAttacks) {
    let color: Int = bt.CurrentColor
    let opponent_color: Int = color ^ 1
    let sq_opponent_king: Int = bt.SQ_King[opponent_color]
    let sq_object: Int = sq_opponent_king + Delta_Table[opponent_color]
    let sq_pawn: Int = sq_opponent_king + (2 * Delta_Table[opponent_color])
    // pawn move
    let bb_occupied: UInt128 = bt.BB_Occupied[Color.Black.rawValue] | bt.BB_Occupied[Color.White.rawValue]
    let bb_empty = ~bb_occupied & BB_Full
    let bb_move_to = (bt.BB_Occupied[color ^ 1] | bb_empty) & BB_Full
    var flag_promo: Int = 0
    // generate no promote move
    if sq_pawn >= 0 && sq_pawn < Square_NB && (bt.Board[sq_pawn] == Sign_Table[opponent_color] * Piece.Pawn.rawValue) && ((ABB_Mask[sq_pawn] & BB_Pawn_Mask[color]) > 0) && (ABB_Mask[sq_object] & bb_move_to) > 0 {
        let m = pack(from:sq_pawn, to:sq_object, pc:Piece.Pawn.rawValue, cap_pc:abs(bt.Board[sq_object]), flag_promo:0)
        moves.append(m)
    }
    // pawn promote move
    var bb_from = bt.BB_Piece[color][Piece.Pawn.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = BB_Rev_Color_Position[color] & ABB_Piece_Attacks[color][Piece.Pawn.rawValue][ifrom] & ABB_Piece_Attacks[opponent_color][Piece.King.rawValue][sq_opponent_king] & bb_move_to
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:ifrom, to:ito, pc:Piece.Pawn.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:1)
            moves.append(m)
        }
    }
    // pawn move that makes opponent king discovered check with using dragon or rook attacks
    bb_from = la.ABB_Rank_Attacks[sq_opponent_king][0]! & bt.BB_Piece[color][Piece.Pawn.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        if ((bt.BB_Piece[color][Piece.Rook.rawValue] | bt.BB_Piece[color][Piece.Dragon.rawValue]) & la.ABB_Rank_Attacks[ifrom][0]!) > 0 && (ABB_Piece_Attacks[color][Piece.Pawn.rawValue][ifrom] & bb_move_to) > 0 {
            if (BB_Rev_Color_Position[color] & ABB_Piece_Attacks[color][Piece.Pawn.rawValue][ifrom]) == 0 {
                flag_promo = 0
            }
            else {
                flag_promo = 1
            }
            let ito = ifrom + Delta_Table[color]
            let m = pack(from:ifrom, to:ito, pc:Piece.Pawn.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:flag_promo)
            moves.append(m)
        }
    }
    // pawn move that makes opponent king discovered check with using horse or bishop attacks
    bb_from = la.ABB_Diag1_Attacks[sq_opponent_king][0]! & bt.BB_Piece[color][Piece.Pawn.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        if (la.ABB_Diag1_Attacks[ifrom][0]! & (bt.BB_Piece[color][Piece.Bishop.rawValue] | bt.BB_Piece[color][Piece.Horse.rawValue])) > 0 && ((ABB_Piece_Attacks[color][Piece.Pawn.rawValue][ifrom] & bb_move_to)) > 0 {
            if (BB_Rev_Color_Position[color] & ABB_Piece_Attacks[color][Piece.Pawn.rawValue][ifrom]) == 0 {
                flag_promo = 0
            }
            else {
                flag_promo = 1
            }
            let ito = ifrom + Delta_Table[color]
            let m = pack(from:ifrom, to:ito, pc:Piece.Pawn.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:flag_promo)
            moves.append(m)
        }
    }
    bb_from = la.ABB_Diag2_Attacks[sq_opponent_king][0]! & bt.BB_Piece[color][Piece.Pawn.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        if (la.ABB_Diag2_Attacks[ifrom][0]! & (bt.BB_Piece[color][Piece.Bishop.rawValue] | bt.BB_Piece[color][Piece.Horse.rawValue])) > 0 && ((ABB_Piece_Attacks[color][Piece.Pawn.rawValue][ifrom] & bb_move_to)) > 0 {
            if (BB_Rev_Color_Position[color] & ABB_Piece_Attacks[color][Piece.Pawn.rawValue][ifrom]) == 0 {
                flag_promo = 0
            }
            else {
                flag_promo = 1
            }
            let ito = ifrom + Delta_Table[color]
            let m = pack(from:ifrom, to:ito, pc:Piece.Pawn.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:flag_promo)
            moves.append(m)
        }
    }
    var bb_temp:UInt128 = 0
    // drop pawn
    if sq_object >= 0 && sq_object < Square_NB {
        bb_temp = BB_File[FileTable[sq_object]] & bt.BB_Piece[color][Piece.Pawn.rawValue]
    }
    if bb_temp == 0 && (sq_object >= 0 && sq_object < Square_NB) && (bt.Hand[color] & Hand_Mask[Piece.Pawn.rawValue]) > 0 && bt.Board[sq_object] == Piece.Empty.rawValue && !is_mate_pawn_drop(bt:&bt, sq_drop:sq_object, color:(color ^ 1), la:&la) {
        let m = pack(from:(Square_NB + Piece.Pawn.rawValue - 1), to:sq_object, pc:Piece.Pawn.rawValue, cap_pc:0, flag_promo:0)
        moves.append(m)
    }
    // silver move
    bb_from = bt.BB_Piece[color][Piece.Silver.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        let idirec = Adirec[sq_opponent_king][ifrom]
        var bb_to = ABB_Piece_Attacks[color][Piece.Silver.rawValue][ifrom] & ABB_Piece_Attacks[opponent_color][Piece.Silver.rawValue][sq_opponent_king] & bb_move_to
        if idirec != Direction.Direc_Misc.rawValue && is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:opponent_color, la:&la) > 0 {
            bb_temp = 0
            bb_to |= add_behind_attacks(bb:bb_temp, idirec:idirec, ik:sq_opponent_king, la:&la) & ABB_Piece_Attacks[color][Piece.Silver.rawValue][ifrom] & bb_move_to
        }
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:ifrom, to:ito, pc:Piece.Silver.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:0)
            moves.append(m)
        }
    }
    // silver promote move
    bb_from = bt.BB_Piece[color][Piece.Silver.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        let idirec = Adirec[sq_opponent_king][ifrom]
        var bb_to = ABB_Piece_Attacks[color][Piece.Silver.rawValue][ifrom] & ABB_Piece_Attacks[opponent_color][Piece.Gold.rawValue][sq_opponent_king] & bb_move_to
        if idirec != Direction.Direc_Misc.rawValue && is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:opponent_color, la:&la) > 0 {
            bb_temp = 0
            bb_to |= add_behind_attacks(bb:bb_temp, idirec:idirec, ik:sq_opponent_king, la:&la) & ABB_Piece_Attacks[color][Piece.Silver.rawValue][ifrom] & bb_move_to
        }
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            if (BB_Rev_Color_Position[color] & ABB_Mask[ifrom]) > 0 || (BB_Rev_Color_Position[color] & ABB_Mask[ito]) > 0 {
                let m = pack(from:ifrom, to:ito, pc:Piece.Silver.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:1)
                moves.append(m)
            }
        }
    }
    // drop silver
    if (bt.Hand[color] & Hand_Mask[Piece.Silver.rawValue]) > 0 {
        var bb_to = ABB_Piece_Attacks[opponent_color][Piece.Silver.rawValue][sq_opponent_king] & bb_empty
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:(Square_NB + Piece.Silver.rawValue - 1), to:ito, pc:Piece.Silver.rawValue, cap_pc:0, flag_promo:0)
            moves.append(m)
        }
    }
    // gold move
    bb_from = bt.BB_Piece[color][Piece.Gold.rawValue] | bt.BB_Piece[color][Piece.Pro_Pawn.rawValue] | bt.BB_Piece[color][Piece.Pro_Lance.rawValue] | bt.BB_Piece[color][Piece.Pro_Knight.rawValue] | bt.BB_Piece[color][Piece.Pro_Silver.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        let idirec = Adirec[sq_opponent_king][ifrom]
        var bb_to = ABB_Piece_Attacks[color][Piece.Gold.rawValue][ifrom] & ABB_Piece_Attacks[opponent_color][Piece.Gold.rawValue][sq_opponent_king] & bb_move_to
        if idirec != Direction.Direc_Misc.rawValue && is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:opponent_color, la:&la) > 0 {
            bb_temp = 0
            bb_to |= add_behind_attacks(bb:bb_temp, idirec:idirec, ik:sq_opponent_king, la:&la) & ABB_Piece_Attacks[color][Piece.Gold.rawValue][ifrom] & bb_move_to
        }
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:ifrom, to:ito, pc:abs(bt.Board[ifrom]), cap_pc:abs(bt.Board[ito]), flag_promo:0)
            moves.append(m)
        }
    }
    // drop gold
    if (bt.Hand[color] & Hand_Mask[Piece.Gold.rawValue]) > 0 {
        var bb_to = ABB_Piece_Attacks[opponent_color][Piece.Gold.rawValue][sq_opponent_king] & bb_empty
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:(Square_NB + Piece.Gold.rawValue - 1), to:ito, pc:Piece.Gold.rawValue, cap_pc:0, flag_promo:0)
            moves.append(m)
        }
    }
    // knight move
    bb_from = bt.BB_Piece[color][Piece.Knight.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        let idirec = Adirec[sq_opponent_king][ifrom]
        var bb_to = ABB_Piece_Attacks[color][Piece.Knight.rawValue][ifrom] & ABB_Piece_Attacks[opponent_color][Piece.Knight.rawValue][sq_opponent_king] & bb_move_to
        if idirec != Direction.Direc_Misc.rawValue && is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:opponent_color, la:&la) > 0 {
            bb_temp = 0
            bb_to |= add_behind_attacks(bb:bb_temp, idirec:idirec, ik:sq_opponent_king, la:&la) & ABB_Piece_Attacks[color][Piece.Knight.rawValue][ifrom] & bb_move_to
        }
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:ifrom, to:ito, pc:Piece.Knight.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:0)
            moves.append(m)
        }
    }
    // knight promote move
    bb_from = bt.BB_Piece[color][Piece.Knight.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        let idirec = Adirec[sq_opponent_king][ifrom]
        var bb_to = ABB_Piece_Attacks[color][Piece.Knight.rawValue][ifrom] & ABB_Piece_Attacks[opponent_color][Piece.Gold.rawValue][sq_opponent_king] & bb_move_to
        if idirec != Direction.Direc_Misc.rawValue && is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:opponent_color, la:&la) > 0 {
            bb_temp = 0
            bb_to |= add_behind_attacks(bb:bb_temp, idirec:idirec, ik:sq_opponent_king, la:&la) & ABB_Piece_Attacks[color][Piece.Knight.rawValue][ifrom] & bb_move_to
        }
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            if (BB_Rev_Color_Position[color] & ABB_Mask[ifrom]) > 0 || (BB_Rev_Color_Position[color] & ABB_Mask[ito]) > 0 {
                let m = pack(from:ifrom, to:ito, pc:Piece.Knight.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:1)
                moves.append(m)
            }
        }
    }
    // drop knight
    if (bt.Hand[color] & Hand_Mask[Piece.Knight.rawValue]) > 0 {
        var bb_to = ABB_Piece_Attacks[opponent_color][Piece.Knight.rawValue][sq_opponent_king] & bb_empty
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:(Square_NB + Piece.Knight.rawValue - 1), to:ito, pc:Piece.Knight.rawValue, cap_pc:0, flag_promo:0)
            moves.append(m)
        }
    }
    // king move
    let ifrom = bt.SQ_King[color]
    let idirec = Adirec[sq_opponent_king][ifrom]
    if idirec != Direction.Direc_Misc.rawValue && is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:opponent_color, la:&la) > 0 {
        bb_temp = 0
        var bb_to = add_behind_attacks(bb:bb_temp, idirec:idirec, ik:sq_opponent_king, la:&la) & ABB_Piece_Attacks[color][Piece.King.rawValue][ifrom] & bb_move_to
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:ifrom, to:ito, pc:Piece.King.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:0)
            moves.append(m)
        }
    }
    // lance move
    // These moves must be discovered check or capture moves.
    bb_from = bt.BB_Piece[color][Piece.Lance.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = la.ABB_Lance_Attacks[color][ifrom][ABB_Lance_Mask_Ex[color][ifrom] & bb_occupied]! & (~BB_Knight_Must_Promote[color] & BB_Full & bt.BB_Occupied[opponent_color] & bb_move_to)
        let bb_attacks = bb_to
        bb_to &= la.ABB_Lance_Attacks[color ^ 1][sq_opponent_king][ABB_Lance_Mask_Ex[color ^ 1][sq_opponent_king] & bb_occupied]!
        let idirec = Adirec[sq_opponent_king][ifrom]
        if idirec != Direction.Direc_Misc.rawValue && is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:opponent_color, la:&la) > 0 {
            bb_temp = bb_attacks | add_behind_attacks(bb:bb_temp, idirec:idirec, ik:sq_opponent_king, la:&la)
            bb_to |= bb_temp
            bb_to &= (color == Color.Black.rawValue) ? (BB_File[FileTable[ifrom]] & (BB_Rank[2] | BB_Rank[3])) : (BB_File[FileTable[ifrom]] & (BB_Rank[6] | BB_Rank[5]))
        }
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:ifrom, to:ito, pc:Piece.Lance.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:0)
            moves.append(m)
        }
    }
    // lance promote move
    bb_from = bt.BB_Piece[color][Piece.Lance.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = la.ABB_Lance_Attacks[color][ifrom][ABB_Lance_Mask_Ex[color][ifrom] & bb_occupied]!
        let bb_attacks = bb_to
        bb_to &= BB_Rev_Color_Position[color] & BB_Full & ABB_Piece_Attacks[opponent_color][Piece.Gold.rawValue][sq_opponent_king] & bb_move_to
        bb_to &= la.ABB_Lance_Attacks[color ^ 1][sq_opponent_king][ABB_Lance_Mask_Ex[color ^ 1][sq_opponent_king] & bb_occupied]!
        let idirec = Adirec[sq_opponent_king][ifrom]
        if idirec != Direction.Direc_Misc.rawValue && is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:opponent_color, la:&la) > 0 {
            bb_temp = bb_attacks & add_behind_attacks(bb:bb_temp, idirec:idirec, ik:sq_opponent_king, la:&la)
            bb_to |= bb_temp
            bb_to &= BB_Color_Position[Color.Black.rawValue] | BB_Color_Position[Color.White.rawValue]
        }
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:ifrom, to:ito, pc:Piece.Lance.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:1)
            moves.append(m)
        }
    }
    // drop lance
    if (bt.Hand[color] & Hand_Mask[Piece.Lance.rawValue]) > 0 {
        var bb_to = la.ABB_Lance_Attacks[color ^ 1][sq_opponent_king][ABB_Lance_Mask_Ex[color ^ 1][sq_opponent_king] & bb_occupied]! & bb_empty
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:(Square_NB + Piece.Lance.rawValue - 1), to:ito, pc:Piece.Lance.rawValue, cap_pc:0, flag_promo:0)
            moves.append(m)
        }
    }
    // rook move
    bb_from = bt.BB_Piece[color][Piece.Rook.rawValue] & (BB_Color_Position[color] | BB_DMZ)
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = la.ABB_Cross_Attacks[ifrom][ABB_Cross_Mask_Ex[ifrom] & bb_occupied]!
        let bb_attacks = bb_to
        bb_to &= bb_move_to
        let idirec = Adirec[sq_opponent_king][ifrom]
        bb_to &= la.ABB_Cross_Attacks[sq_opponent_king][ABB_Cross_Mask_Ex[sq_opponent_king] & bb_occupied]!
        bb_to &= BB_Color_Position[color] | BB_DMZ
        if idirec != Direction.Direc_Misc.rawValue && is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:opponent_color, la:&la) > 0 {
            bb_temp = bb_attacks & add_behind_attacks(bb:bb_temp, idirec:idirec, ik:sq_opponent_king, la:&la)
            bb_to |= bb_temp
            bb_to &= BB_Color_Position[color] | BB_DMZ
        }
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:ifrom, to:ito, pc:Piece.Rook.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:0)
            moves.append(m)
        }
    }
    // rook promote move
    bb_from = bt.BB_Piece[color][Piece.Rook.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = la.ABB_Cross_Attacks[ifrom][ABB_Cross_Mask_Ex[ifrom] & bb_occupied]!
        let bb_attacks = bb_to
        bb_to &= bb_move_to
        let idirec = Adirec[sq_opponent_king][ifrom]
        bb_to &= la.ABB_Cross_Attacks[sq_opponent_king][ABB_Cross_Mask_Ex[sq_opponent_king] & bb_occupied]! | ABB_Piece_Attacks[opponent_color][Piece.King.rawValue][sq_opponent_king]
        if idirec != Direction.Direc_Misc.rawValue && is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:opponent_color, la:&la) > 0 {
            bb_temp = bb_attacks & add_behind_attacks(bb:bb_temp, idirec:idirec, ik:sq_opponent_king, la:&la)
            bb_to |= bb_temp
        }
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            if (ABB_Mask[ifrom] & BB_Rev_Color_Position[color]) > 0 || (ABB_Mask[ito] & BB_Rev_Color_Position[color]) > 0 {
                let m = pack(from:ifrom, to:ito, pc:Piece.Rook.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:1)
                moves.append(m)
            }
        }
    }
    // drop rook
    if (bt.Hand[color] & Hand_Mask[Piece.Rook.rawValue]) > 0 {
        var bb_to = la.ABB_Cross_Attacks[sq_opponent_king][ABB_Cross_Mask_Ex[sq_opponent_king] & bb_occupied]! & bb_empty
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:(Square_NB + Piece.Rook.rawValue - 1), to:ito, pc:Piece.Rook.rawValue, cap_pc:0, flag_promo:0)
            moves.append(m)
        }
    }
    // bishop move
    bb_from = bt.BB_Piece[color][Piece.Bishop.rawValue] & (BB_Color_Position[color] | BB_DMZ)
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = la.ABB_Diagonal_Attacks[ifrom][ABB_Diagonal_Mask_Ex[ifrom] & bb_occupied]!
        let bb_attacks = bb_to
        bb_to &= bb_move_to
        let idirec = Adirec[sq_opponent_king][ifrom]
        bb_to &= la.ABB_Diagonal_Attacks[sq_opponent_king][ABB_Diagonal_Mask_Ex[sq_opponent_king] & bb_occupied]!
        bb_to &= BB_Color_Position[color] | BB_DMZ
        if idirec != Direction.Direc_Misc.rawValue && is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:opponent_color, la:&la) > 0 {
            bb_temp = 0
            bb_to |= bb_attacks & add_behind_attacks(bb:bb_temp, idirec:idirec, ik:sq_opponent_king, la:&la)
            bb_to &= BB_Color_Position[color] | BB_DMZ
        }
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:ifrom, to:ito, pc:Piece.Bishop.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:0)
            moves.append(m)
        }
    }
    // bishop promote move
    bb_from = bt.BB_Piece[color][Piece.Bishop.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = la.ABB_Diagonal_Attacks[ifrom][ABB_Diagonal_Mask_Ex[ifrom] & bb_occupied]!
        let bb_attacks = bb_to
        bb_to &= bb_move_to
        let idirec = Adirec[sq_opponent_king][ifrom]
        bb_to &= la.ABB_Diagonal_Attacks[sq_opponent_king][ABB_Diagonal_Mask_Ex[sq_opponent_king] & bb_occupied]! | ABB_Piece_Attacks[opponent_color][Piece.King.rawValue][sq_opponent_king]
        if idirec != Direction.Direc_Misc.rawValue && is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:opponent_color, la:&la) > 0 {
            bb_temp = 0
            bb_to |= bb_attacks & add_behind_attacks(bb:bb_temp, idirec:idirec, ik:sq_opponent_king, la:&la)
        }
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            if (ABB_Mask[ifrom] & BB_Rev_Color_Position[color]) > 0 || (ABB_Mask[ito] & BB_Rev_Color_Position[color]) > 0 {
                let m = pack(from:ifrom, to:ito, pc:Piece.Bishop.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:1)
                moves.append(m)
            }
        }
    }
    // drop bishop
    if (bt.Hand[color] & Hand_Mask[Piece.Bishop.rawValue]) > 0 {
        var bb_to = la.ABB_Diagonal_Attacks[sq_opponent_king][ABB_Diagonal_Mask_Ex[sq_opponent_king] & bb_occupied]! & bb_empty
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:(Square_NB + Piece.Bishop.rawValue - 1), to:ito, pc:Piece.Bishop.rawValue, cap_pc:0, flag_promo:0)
            moves.append(m)
        }
    }
    // dragon move
    bb_from = bt.BB_Piece[color][Piece.Dragon.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = la.ABB_Cross_Attacks[ifrom][ABB_Cross_Mask_Ex[ifrom] & bb_occupied]! | ABB_Piece_Attacks[color][Piece.King.rawValue][ifrom]
        let bb_attacks = bb_to
        bb_to &= bb_move_to
        let idirec = Adirec[sq_opponent_king][ifrom]
        bb_to &= la.ABB_Cross_Attacks[sq_opponent_king][ABB_Cross_Mask_Ex[sq_opponent_king] & bb_occupied]! | ABB_Piece_Attacks[color][Piece.King.rawValue][sq_opponent_king]
        if idirec != Direction.Direc_Misc.rawValue && is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:opponent_color, la:&la) > 0 {
            bb_temp = 0
            bb_to |= bb_attacks & add_behind_attacks(bb:bb_temp, idirec:idirec, ik:sq_opponent_king, la:&la)
        }
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:ifrom, to:ito, pc:Piece.Dragon.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:0)
            moves.append(m)
        }
    }
    // horse move
    bb_from = bt.BB_Piece[color][Piece.Horse.rawValue]
    while bb_from > 0 {
        let ifrom = Square_NB - bb_from.trailingZeroBitCount - 1
        bb_from ^= ABB_Mask[ifrom]
        var bb_to = la.ABB_Diagonal_Attacks[ifrom][ABB_Diagonal_Mask_Ex[ifrom] & bb_occupied]! | ABB_Piece_Attacks[color][Piece.King.rawValue][ifrom]
        let bb_attacks = bb_to
        bb_to &= bb_move_to
        let idirec = Adirec[sq_opponent_king][ifrom]
        bb_temp = la.ABB_Diagonal_Attacks[sq_opponent_king][ABB_Diagonal_Mask_Ex[sq_opponent_king] & bb_occupied]! | ABB_Piece_Attacks[color][Piece.King.rawValue][sq_opponent_king]
        bb_to &= la.ABB_Diagonal_Attacks[sq_opponent_king][ABB_Diagonal_Mask_Ex[sq_opponent_king] & bb_occupied]! | ABB_Piece_Attacks[color][Piece.King.rawValue][sq_opponent_king]
        if idirec != Direction.Direc_Misc.rawValue && is_pinned_on_king(bt:&bt, sq:ifrom, idirec:idirec, color:opponent_color, la:&la) > 0 {
            bb_temp = 0
            bb_to |= bb_attacks & add_behind_attacks(bb:bb_temp, idirec:idirec, ik:sq_opponent_king, la:&la)
        }
        while bb_to > 0 {
            let ito = Square_NB - bb_to.trailingZeroBitCount - 1
            bb_to ^= ABB_Mask[ito]
            let m = pack(from:ifrom, to:ito, pc:Piece.Horse.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:0)
            moves.append(m)
        }
    }
}

public func gen_cap_treat_piece(bt: inout BoardTree, moves: inout [UInt32], threat_move: UInt32, la: inout LongAttacks) {
    let color: Int = bt.CurrentColor
    let sq_attacks_to = from(m:threat_move)
    // If mate in 1 ply by drop move, you can not capture.
    if sq_attacks_to >= Square_NB {
        return
    }
    var bb_attacks_from = attacks_to_piece(bt:&bt, sq:sq_attacks_to, color:color, la:&la)
    while bb_attacks_from > 0 {
        let ifrom = Square_NB - bb_attacks_from.trailingZeroBitCount - 1
        bb_attacks_from ^= ABB_Mask[ifrom]
        let ipiece: Int = abs(bt.Board[ifrom])
        let m = pack(from:ifrom, to:sq_attacks_to, pc:ipiece, cap_pc:abs(bt.Board[sq_attacks_to]), flag_promo:0)
        moves.append(m)
        if (BB_Rev_Color_Position[color] & ABB_Mask[sq_attacks_to]) > 0 && ipiece < Piece.King.rawValue {
            let m = pack(from:ifrom, to:sq_attacks_to, pc:ipiece, cap_pc:abs(bt.Board[sq_attacks_to]), flag_promo:1)
            moves.append(m)
        }
        if (BB_Rev_Color_Position[color] & ABB_Mask[ifrom]) > 0 && Set_Piece_Can_Promote1.contains(ipiece) {
            let m = pack(from:ifrom, to:sq_attacks_to, pc:ipiece, cap_pc:abs(bt.Board[sq_attacks_to]), flag_promo:1)
            moves.append(m)
        }
    }
}

public func gen_king_move(bt: inout BoardTree, moves: inout [UInt32], la: inout LongAttacks) {
    let color: Int = bt.CurrentColor
    let sq_king = bt.SQ_King[color]
    let ifrom = sq_king
    bt.BB_Occupied[color] ^= ABB_Mask[ifrom]
    let bb_not_color = ~bt.BB_Occupied[color] & BB_Full
    var bb_to = ABB_Piece_Attacks[color][Piece.King.rawValue][sq_king] & bb_not_color
    while bb_to > 0 {
        let ito = Square_NB - bb_to.trailingZeroBitCount - 1
        bb_to ^= ABB_Mask[ito]
        if is_attacked(bt:&bt, sq:ito, color:color, la:&la) == 0 {
            let m = pack(from:ifrom, to:ito, pc:Piece.King.rawValue, cap_pc:abs(bt.Board[ito]), flag_promo:0)
            moves.append(m)
        }
        bb_to ^= ABB_Mask[ito]
    }
    bt.BB_Occupied[color] ^= ABB_Mask[ifrom]
}

public func gen_interfere(bt: inout BoardTree, moves: inout [UInt32], threat_move: UInt32, la: inout LongAttacks) {
    let color: Int = bt.CurrentColor
    let sq_threat_to = to(m:threat_move)
    let bb_empty = ~(bt.BB_Occupied[0] | bt.BB_Occupied[1]) & BB_Full
    let bb_object = bb_empty | bt.BB_Occupied[color ^ 1]
    var bb_attacks_from = attacks_to_piece(bt:&bt, sq:sq_threat_to, color:color, la:&la)
    if (bb_object & ABB_Mask[sq_threat_to]) > 0 {
        while bb_attacks_from > 0 {
            let ifrom = Square_NB - bb_attacks_from.trailingZeroBitCount - 1
            bb_attacks_from ^= ABB_Mask[ifrom]
            let ipiece = abs(bt.Board[ifrom])
            if ipiece == Piece.King.rawValue {
                continue
            }
            let m = pack(from:ifrom, to:sq_threat_to, pc:ipiece, cap_pc:abs(bt.Board[sq_threat_to]), flag_promo:0)
            moves.append(m)
            if (BB_Rev_Color_Position[color] & ABB_Mask[sq_threat_to]) > 0 && ipiece < Piece.King.rawValue {
                let m = pack(from:ifrom, to:sq_threat_to, pc:ipiece, cap_pc:abs(bt.Board[sq_threat_to]), flag_promo:1)
                moves.append(m)
            }
            if (BB_Rev_Color_Position[color] & ABB_Mask[ifrom]) > 0 && Set_Piece_Can_Promote1.contains(ipiece) {
                let m = pack(from:ifrom, to:sq_threat_to, pc:ipiece, cap_pc:abs(bt.Board[sq_threat_to]), flag_promo:1)
                moves.append(m)
            }
        }
    }
    let ifrom = from(m:threat_move)
    if ifrom >= Square_NB {
        let bb_drop = bb_empty & ABB_Mask[sq_threat_to]
        if bt.Hand[color] > 0 && (bb_drop & BB_File[FileTable[sq_threat_to]]) > 0 && !is_mate_pawn_drop(bt:&bt, sq_drop:sq_threat_to, color:(color ^ 1), la:&la) {
            if (bt.Hand[color] & Hand_Mask[Piece.Pawn.rawValue]) > 0 {
                let m = pack(from:Square_NB, to:sq_threat_to, pc:Piece.Pawn.rawValue, cap_pc:0, flag_promo:0)
                moves.append(m)
            }
        }
        if bt.Hand[color] > 0 {
            for i in Piece.Lance.rawValue...Piece.Rook.rawValue {
                if (bt.Hand[color] & Hand_Mask[i]) > 0 {
                    let m = pack(from:(Square_NB + i - 1), to:sq_threat_to, pc:i, cap_pc:0, flag_promo:0)
                    moves.append(m)
                }
            }
        }
    }
}

private func add_behind_attacks(bb: UInt128, idirec: Int, ik: Int, la: inout LongAttacks) -> UInt128 {
    var bb_tmp:UInt128 = 0
    let abs_idirec = abs(idirec)
    switch abs_idirec {
    case Direction.Direc_Diag1_U2d.rawValue:
        bb_tmp = la.ABB_Diag1_Attacks[ik][0]!
    case Direction.Direc_Diag2_U2d.rawValue:
        bb_tmp = la.ABB_Diag2_Attacks[ik][0]!
    case Direction.Direc_File_U2d.rawValue:
        bb_tmp = la.ABB_File_Attacks[ik][0]!
    case Direction.Direc_Rank_L2r.rawValue:
        bb_tmp = la.ABB_Rank_Attacks[ik][0]!
    default:
        bb_tmp = 0
    }
    bb_tmp = BB_Full & ~bb_tmp
    bb_tmp |= bb
    return bb_tmp
}
