public func mate_in_one_ply(bt: inout BoardTree, la: inout LongAttacks) -> UInt32 {
    var mate_move: UInt32 = 0
    let null_move: UInt32 = 0
    var sq_can_check_by_drop: [Int] = [ 0, 0, 0, 0, 0, 0, 0, 0 ]
    var sq_can_check_by_move: [Int] = [ 0, 0, 0, 0, 0, 0, 0, 0 ]
    var pos_array: [Int] = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
    var pc_array: [Int] = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
    var sq_can_escape: [Int] = [ 0, 0, 0, 0, 0, 0, 0, 0 ]
    var cnt_d: Int = 0
    var cnt_m: Int = 0
    var cnt_e: Int = 0
    let color = bt.CurrentColor
    let opponent_color = color ^ 1
    // get opponent king's square
    let sq_opponent_king = bt.SQ_King[opponent_color]
    let bb_can_escape = BB_Full & ~bt.BB_Occupied[opponent_color]
    let hand = bt.Hand[color]
    var bb_opp_king_attacks = ABB_Piece_Attacks[opponent_color][Piece.King.rawValue][sq_opponent_king]
    var flag = false
    while bb_opp_king_attacks > 0 {
        let sq = Square_NB - bb_opp_king_attacks.trailingZeroBitCount - 1
        bb_opp_king_attacks ^= ABB_Mask[sq]
        let bb_myside_attacks = attacks_to_piece(bt:&bt, sq:sq, color:opponent_color, la:&la)
        let myside_attacks_count = bb_myside_attacks.nonzeroBitCount
        flag = false
        if (myside_attacks_count >= 2) && (bt.Board[sq] == Piece.Empty.rawValue) {
            //If there are attacks from opponent pieces except king, opponents can capture the checker.
            flag = true
        }
        if (bb_can_escape & ABB_Mask[sq]) > 0 {
            // If there are attacks from your pieces, you maybe generate escape move.
            if is_attacked(bt:&bt, sq:sq, color:opponent_color, la:&la) == 0 {
                sq_can_escape[cnt_e] = sq
                cnt_e += 1
            }
        }
        if bt.Board[sq] == Piece.Empty.rawValue && !flag {
            sq_can_check_by_drop[cnt_d] = sq
            cnt_d += 1
        }
        let bb_enemy_attacks = is_attacked(bt:&bt, sq:sq, color:(color ^ 1), la:&la)
        if bt.Board[sq] != Piece.Empty.rawValue && (bt.BB_Occupied[opponent_color] & ABB_Mask[sq]) > 0 && bb_enemy_attacks > 0 {
            sq_can_check_by_move[cnt_m] = sq
            cnt_m += 1
        }
        if myside_attacks_count < 2 && bt.Board[sq] == Piece.Empty.rawValue && bb_enemy_attacks > 0 {
            sq_can_check_by_move[cnt_m] = sq
            cnt_m += 1
        }
    }
    var limit = cnt_d - 1
    if limit >= 0 {
        for i in 0...limit {
            let sq = sq_can_check_by_drop[i]
            let idirec = Adirec[sq][sq_opponent_king]
            let pt = Piece_Table[opponent_color]
            var bb = attacks_to_piece(bt:&bt, sq:sq, color:opponent_color, la:&la)
            var cnt_pos = 0
            var cnt_pc = 0
            while bb > 0 {
                let pos = Square_NB - bb.trailingZeroBitCount - 1
                bb ^= ABB_Mask[pos]
                pos_array[cnt_pos] = pos
                cnt_pos += 1
                pc_array[cnt_pc] = bt.Board[pos]
                cnt_pc += 1
            }
            let pcs = pt[idirec]!
            if hand > 0 {
                let limit2 = pt.count - 1
                if limit2 >= 0 {
                    for j in 0...limit2 {
                        let pc = pcs[j]
                        if pc > Piece.Rook.rawValue {
                            break
                        }
                        if (pc != Piece.Pawn.rawValue) && (hand & Hand_Mask[pc]) > 0 {
                            if cnt_e == 0 {
                                mate_move = pack(from:(Square_NB + pc - 1), to:sq, pc:pc, cap_pc:0, flag_promo:0)
                                return mate_move
                            }
                            var counter = 0
                            var mate_flag = true
                            let limit3 = cnt_e - 1
                            if limit3 >= 0 {
                                for k in 0...limit3 {
                                    let sq_object = sq_can_escape[k]
                                    if sq == sq_object {
                                        counter += 1
                                    }
                                    if !is_can_escape(bt:&bt, color:color, sq_checker:sq, pc_checker:pc, sq_opponent_king:sq_opponent_king, sq_object:sq_object, is_promo:false, la:&la) && !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:true, ifrom:-1, ipiece:pc, la:&la) {
                                        counter += 1
                                    }
                                    else {
                                        mate_flag = false
                                    }
                                }
                                if counter == cnt_e && mate_flag {
                                    mate_move = pack(from:(Square_NB + pc - 1), to:sq, pc:pc, cap_pc:0, flag_promo:0)
                                    return mate_move
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    if cnt_m > 0 {
        limit = cnt_m - 1
        for i in 0...limit {
            let sq = sq_can_check_by_move[i]
            let idirec = Adirec[sq][sq_opponent_king]
            let pt = Piece_Table[opponent_color]
            var bb = attacks_to_piece(bt:&bt, sq:sq, color:color, la:&la)
            let attacks_count = bb.nonzeroBitCount
            if attacks_count < 2 && bb > 0 {
                let pos = Square_NB - bb.trailingZeroBitCount - 1
                var bb2 = attacks_to_long_piece(bt:&bt, sq:pos, color:color, la:&la)
                while bb2 > 0 {
                    let sq2 = Square_NB - bb2.trailingZeroBitCount - 1
                    bb2 ^= ABB_Mask[sq2]
                    let idirec2 = Adirec[sq2][sq_opponent_king]
                    if idirec == idirec2 {
                        if cnt_e == 0 {
                            if !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:false, ifrom:pos, ipiece:abs(bt.Board[pos]), la:&la) {
                                mate_move = pack(from:pos, to:sq, pc:abs(bt.Board[pos]), cap_pc:abs(bt.Board[sq]), flag_promo:0)
                                return mate_move
                            }
                        }
                        else if cnt_e == 1 {
                           let sq3 = sq_can_escape[0]
                           let idirec3 = Adirec[sq3][sq_opponent_king]
                           if !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:false, ifrom:pos, ipiece:abs(bt.Board[pos]), la:&la) {
                               if abs(idirec) == abs(idirec3) {
                                   switch abs(idirec) {
                                   case Direction.Direc_File_U2d.rawValue:
                                       if abs(bt.Board[pos]) == Piece.Lance.rawValue || abs(bt.Board[pos]) == Piece.Rook.rawValue || abs(bt.Board[pos]) == Piece.Dragon.rawValue {
                                            mate_move = pack(from:pos, to:sq, pc:abs(bt.Board[pos]), cap_pc:abs(bt.Board[sq]), flag_promo:0)
                                            return mate_move
                                       }
                                   case Direction.Direc_Rank_L2r.rawValue:
                                       if abs(bt.Board[pos]) == Piece.Rook.rawValue || abs(bt.Board[pos]) == Piece.Dragon.rawValue {
                                            mate_move = pack(from:pos, to:sq, pc:abs(bt.Board[pos]), cap_pc:abs(bt.Board[sq]), flag_promo:0)
                                            return mate_move
                                       }
                                   case Direction.Direc_Diag1_U2d.rawValue, Direction.Direc_Diag2_U2d.rawValue:
                                       if abs(bt.Board[pos]) == Piece.Bishop.rawValue || abs(bt.Board[pos]) == Piece.Horse.rawValue {
                                            mate_move = pack(from:pos, to:sq, pc:abs(bt.Board[pos]), cap_pc:abs(bt.Board[sq]), flag_promo:0)
                                            return mate_move
                                       }
                                   default:
                                       mate_move = 0
                                   }
                               }
                           }
                        }
                    }
                    else {
                        if cnt_e == 0 && (ABB_Piece_Attacks[color][Piece.Gold.rawValue][sq] & ABB_Piece_Attacks[opponent_color][Piece.King.rawValue][sq_opponent_king]) > 0 && (ABB_Mask[sq] & BB_Color_Position[opponent_color]) > 0 {
                            let bb_myside_attacks = attacks_to_piece(bt:&bt, sq:sq, color:opponent_color, la:&la)
                            let myside_attacks_count = bb_myside_attacks.nonzeroBitCount
                            let idirec3 = Adirec[pos][bt.SQ_King[color]]
                            bt.BB_Occupied[color] ^= ABB_Mask[pos]
                            bb = is_pinned_on_king(bt:&bt, sq:pos, idirec:idirec3, color:color, la:&la)
                            bt.BB_Occupied[color] ^= ABB_Mask[pos]
                            if myside_attacks_count < 2 && bb == 0 {
                                mate_move = pack(from:pos, to:sq, pc:abs(bt.Board[pos]), cap_pc:abs(bt.Board[sq]), flag_promo:1)
                                return mate_move
                            }
                        }
                    }
                }
                continue
            }
            var cnt_pos = 0
            var cnt_pc = 0
            while bb > 0 {
                let pos = Square_NB - bb.trailingZeroBitCount - 1
                bb ^= ABB_Mask[pos]
                pos_array[cnt_pos] = pos
                cnt_pos += 1
                pc_array[cnt_pc] = bt.Board[pos]
                cnt_pc += 1
            }
            let pcs = pt[idirec]!
            if cnt_pos == 0 { // This maybe not make sense.
                continue
            }
            var index = 0
            while index < cnt_pos {
                let pos = pos_array[index]
                let pc = abs(pc_array[index])
                if pc == Piece.King.rawValue {
                    index += 1
                    continue
                }
                if is_discover_king2(bt:&bt, ifrom:pos, ito:sq, color:color, ipiece:pc, la:&la) {
                    index += 1
                    continue
                }
                if pcs.contains(pc) {
                    if LongPieces2.contains(pc) {
                        if cnt_e == 0 {
                            var flag_promo = 0
                            if LongPieces.contains(pc) && !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:false, ifrom:pos, ipiece:pc, la:&la) {
                                if (ABB_Mask[sq] & BB_Color_Position[opponent_color]) > 0 {
                                    flag_promo = 1
                                }
                                else{
                                    flag_promo = 0
                                }
                                mate_move = pack(from:pos, to:sq, pc:pc, cap_pc:abs(bt.Board[sq]), flag_promo:flag_promo)
                                return mate_move
                            }
                        }
                        flag = false
                        let limit2 = cnt_e - 1
                        if limit2 >= 0 {
                            for j in 0...limit2 {
                                let sq_object = sq_can_escape[j]
                                if sq == sq_object {
                                    continue
                                }
                                if !is_can_escape(bt:&bt, color:color, sq_checker:sq, pc_checker:pc, sq_opponent_king:sq_opponent_king, sq_object:sq_object, is_promo:false, la:&la) && !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:false, ifrom:pos, ipiece:pc, la:&la) {
                                    var flag_promo = 0
                                    if (ABB_Mask[pos] & BB_Color_Position[opponent_color]) > 0 || (ABB_Mask[sq] & BB_Color_Position[opponent_color]) > 0 {
                                        flag_promo = 1
                                    }
                                    else {
                                        flag_promo = 0
                                    }
                                    mate_move = pack(from:pos, to:sq, pc:pc, cap_pc:abs(bt.Board[sq]), flag_promo:flag_promo)
                                    flag = true
                                }
                                else {
                                    flag = false
                                    mate_move = 0
                                    break
                                }
                            }
                            if flag && mate_move != 0 {
                                return mate_move
                            }
                        }
                    }
                    else if pc == Piece.Dragon.rawValue || pc == Piece.Horse.rawValue {
                        if cnt_e == 0 {
                            if !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:false, ifrom:pos, ipiece:pc, la:&la) {
                                mate_move = pack(from:pos, to:sq, pc:pc, cap_pc:abs(bt.Board[sq]), flag_promo:0)
                                return mate_move
                            }
                        }
                        flag = false
                        let limit2 = cnt_e - 1
                        if limit2 >= 0 {
                            for j in 0...limit2 {
                                let sq_object = sq_can_escape[j]
                                if sq == sq_object {
                                    continue
                                }
                                if !is_can_escape(bt:&bt, color:color, sq_checker:sq, pc_checker:pc, sq_opponent_king:sq_opponent_king, sq_object:sq_object, is_promo:false, la:&la) && !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:false, ifrom:pos, ipiece:pc, la:&la) {
                                    mate_move = pack(from:pos, to:sq, pc:pc, cap_pc:abs(bt.Board[sq]), flag_promo:0)
                                    flag = true
                                }
                                else {
                                    flag = false
                                    mate_move = 0
                                    break
                                }
                               }
                            if flag && mate_move != 0 {
                                return mate_move
                            }
                        }
                    }
                    else {
                        switch pc {
                        case Piece.Gold.rawValue, Piece.Pro_Pawn.rawValue, Piece.Pro_Lance.rawValue, Piece.Pro_Knight.rawValue, Piece.Pro_Silver.rawValue, Piece.Silver.rawValue:
                            if cnt_e == 0 {
                                if !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:false, ifrom:pos, ipiece:pc, la:&la) {
                                    mate_move = pack(from:pos, to:sq, pc:pc, cap_pc:abs(bt.Board[sq]), flag_promo:0)
                                    return mate_move
                                }
                            }
                            flag = false
                            let limit2 = cnt_e - 1
                            if limit2 >= 0 {
                                for j in 0...limit2 {
                                    let sq_object = sq_can_escape[j]
                                    if sq == sq_object {
                                        continue
                                    }
                                    if !is_can_escape(bt:&bt, color:color, sq_checker:sq, pc_checker:pc, sq_opponent_king:sq_opponent_king, sq_object:sq_object, is_promo:false, la:&la) && !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:false, ifrom:pos, ipiece:pc, la:&la) {
                                        mate_move = pack(from:pos, to:sq, pc:pc, cap_pc:abs(bt.Board[sq]), flag_promo:0)
                                        flag = true
                                    }
                                    else {
                                        flag = false
                                        mate_move = 0
                                        break
                                    }
                                }
                                if flag && mate_move != 0 {
                                    return mate_move
                                }
                            }
                        default:
                            mate_move = 0
                        }
                    }
                    // In this case, generate pawn and lance move with no promoting.
                }
                if pc > Piece.Rook.rawValue {
                    index += 1
                    continue
                }
                let pc_promote = pc + Promote
                // knight promote move
                // Knight cannnot mate opponent king from neighbour 8 Square.
                if pcs.contains(pc_promote) && pc == Piece.Knight.rawValue && (BB_Rev_Color_Position[color] & ABB_Mask[sq]) > 0 {
                    if cnt_e == 0 {
                        if !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:false, ifrom:pos, ipiece:pc, la:&la) && (ABB_Piece_Attacks[color][Piece.Gold.rawValue][sq] & ABB_Mask[sq_opponent_king]) > 0 {
                            mate_move = pack(from:pos, to:sq, pc:pc, cap_pc:abs(bt.Board[sq]), flag_promo:1)
                            return mate_move
                        }
                    }
                    flag = false
                    let limit2 = cnt_e - 1
                    if limit2 >= 0 {
                        for j in 0...limit2 {
                            let sq_object = sq_can_escape[j]
                            if sq == sq_object {
                                continue
                            }
                            if !is_can_escape(bt:&bt, color:color, sq_checker:sq, pc_checker:pc, sq_opponent_king:sq_opponent_king, sq_object:sq_object, is_promo:true, la:&la) && !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:false, ifrom:pos, ipiece:pc, la:&la) {
                                flag = true
                                mate_move = pack(from:pos, to:sq, pc:pc, cap_pc:abs(bt.Board[sq]), flag_promo:1)
                            }
                            else {
                                flag = false
                                mate_move = 0
                                break
                            }
                        }
                        if flag && mate_move != 0 {
                            return mate_move
                        }
                    }
                }
                // lance promote move or pawn promote move
                if pcs.contains(pc_promote) && ShortPieces.contains(pc) && (BB_Rev_Color_Position[color] & ABB_Mask[sq]) > 0 {
                    if cnt_e == 0 {
                        if !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:false, ifrom:pos, ipiece:pc, la:&la) && (ABB_Piece_Attacks[color][Piece.Gold.rawValue][sq] & ABB_Mask[sq_opponent_king]) > 0 {
                            mate_move = pack(from:pos, to:sq, pc:pc, cap_pc:abs(bt.Board[sq]), flag_promo:1)
                            return mate_move
                        }
                    }
                    flag = false
                    let limit2 = cnt_e - 1
                    if limit2 >= 0 {
                        for j in 0...limit2 {
                            let sq_object = sq_can_escape[j]
                            if sq == sq_object {
                                continue
                            }
                            if !is_can_escape(bt:&bt, color:color, sq_checker:sq, pc_checker:pc, sq_opponent_king:sq_opponent_king, sq_object:sq_object, is_promo:false, la:&la) && !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:false, ifrom:pos, ipiece:pc, la:&la) {
                                flag = true
                                mate_move = pack(from:pos, to:sq, pc:pc, cap_pc:abs(bt.Board[sq]), flag_promo:1)
                            }
                            else {
                                flag = false
                                mate_move = 0
                                break
                            }
                        }
                        if flag && mate_move != 0 {
                            mate_move = pack(from:pos, to:sq, pc:pc, cap_pc:abs(bt.Board[sq]), flag_promo:1)
                            return mate_move
                        }
                    }
                }
                // silver promote move
                if pc == Piece.Silver.rawValue {
                    if pcs.contains(pc_promote) && (BB_Rev_Color_Position[color] & ABB_Mask[sq]) > 0 || (BB_Rev_Color_Position[color] & ABB_Mask[pos]) > 0 {
                        if cnt_e == 0 {
                            if !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:false, ifrom:pos, ipiece:pc, la:&la) && (ABB_Piece_Attacks[color][Piece.Gold.rawValue][sq] & ABB_Mask[sq_opponent_king]) > 0 {
                                mate_move = pack(from:pos, to:sq, pc:pc, cap_pc:abs(bt.Board[sq]), flag_promo:1)
                                return mate_move
                            }
                        }
                        flag = false
                        let limit2 = cnt_e - 1
                        if limit2 >= 0 {
                            for j in 0...limit2 {
                                let sq_object = sq_can_escape[j]
                                if sq == sq_object {
                                    continue
                                }
                                if !is_can_escape(bt:&bt, color:color, sq_checker:sq, pc_checker:pc, sq_opponent_king:sq_opponent_king, sq_object:sq_object, is_promo:false, la:&la) && !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:false, ifrom:pos, ipiece:pc, la:&la) {
                                    mate_move = pack(from:pos, to:sq, pc:pc, cap_pc:abs(bt.Board[sq]), flag_promo:1)
                                    flag = true
                                }
                                else {
                                    flag = false
                                    mate_move = 0
                                    break
                                }
                            }
                            if flag && mate_move != 0 {
                                return mate_move
                            }
                        }
                    }
                }

                if pc < Piece.Bishop.rawValue {
                    index += 1
                    continue
                }

                // rook promote move or bishop promote move
                if pcs.contains(pc_promote) && LongPieces.contains(pc) && (BB_Rev_Color_Position[color] & ABB_Mask[sq]) > 0 || (BB_Rev_Color_Position[color] & ABB_Mask[pos]) > 0 {
                    if cnt_e == 0 {
                        if !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:false, ifrom:pos, ipiece:pc, la:&la) && (ABB_Piece_Attacks[color][Piece.King.rawValue][sq] & ABB_Mask[sq_opponent_king]) > 0 {
                            var flag_promo = 0
                            if (ABB_Mask[pos] & BB_Color_Position[opponent_color]) > 0 || (ABB_Mask[sq] & BB_Color_Position[opponent_color]) > 0 {
                                flag_promo = 1
                            }
                            else {
                                flag_promo = 0
                            }
                            mate_move = pack(from:pos, to:sq, pc:pc, cap_pc:abs(bt.Board[sq]), flag_promo:flag_promo)
                            return mate_move
                        }
                    }
                    flag = false
                    let limit2 = cnt_e - 1
                    if limit2 >= 0 {
                        for j in 0...limit2 {
                            let sq_object = sq_can_escape[j]
                            if sq == sq_object {
                                continue
                            }
                            if !is_can_escape(bt:&bt, color:color, sq_checker:sq, pc_checker:pc, sq_opponent_king:sq_opponent_king, sq_object:sq_object, is_promo:false, la:&la) && !is_can_capture(bt:&bt, color:color, opponent_color:opponent_color, sq_object:sq, is_drop:false, ifrom:pos, ipiece:pc, la:&la) {
                                var flag_promo = 0
                                if (ABB_Mask[pos] & BB_Color_Position[opponent_color]) > 0 || (ABB_Mask[sq] & BB_Color_Position[opponent_color]) > 0 {
                                    flag_promo = 1
                                }
                                else {
                                    flag_promo = 0
                                }
                                mate_move = pack(from:pos, to:sq, pc:pc, cap_pc:abs(bt.Board[sq]), flag_promo:flag_promo)
                                flag = true
                            }
                            else {
                                flag = false
                                mate_move = 0
                                break
                            }
                        }
                        if flag && mate_move != 0 {
                            return mate_move
                        }
                    }
                }
                index += 1
            }
        }
    }
    // You cannot mate opponnent king from neighbour 8 square.
    // You maybe mate opponnent move using knight.
    let pc = Piece.Knight.rawValue
    let bb_occupied = bt.BB_Occupied[Color.Black.rawValue] | bt.BB_Occupied[Color.White.rawValue]
    var bb = ABB_Piece_Attacks[opponent_color][pc][sq_opponent_king] & ((~bb_occupied & BB_Full) | bt.BB_Occupied[opponent_color])
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        let bb_opponent_attacks_to_sq = attacks_to_piece(bt:&bt, sq:sq, color:opponent_color, la:&la)
        if (hand & Hand_Mask[pc]) > 0 && bt.Board[sq] == Piece.Empty.rawValue && cnt_e == 0 && bb_opponent_attacks_to_sq == 0 {
            // drop knight
            mate_move = pack(from:(Square_NB + pc - 1), to:sq, pc:pc, cap_pc:0, flag_promo:0)
                return mate_move
        }
        var bb_my_knight_attacks = ABB_Piece_Attacks[opponent_color][pc][sq] & bt.BB_Piece[color][Piece.Knight.rawValue]
        if bb_my_knight_attacks > 0 && cnt_e == 0 && bb_opponent_attacks_to_sq == 0 {
            let pos = Square_NB - bb_my_knight_attacks.trailingZeroBitCount - 1
            bb_my_knight_attacks ^= ABB_Mask[pos]
            if is_discover_king2(bt:&bt, ifrom:pos, ito:sq, color:color, ipiece:pc, la:&la) {
                continue
            }
            mate_move = pack(from:pos, to:sq, pc:pc, cap_pc:abs(bt.Board[sq]), flag_promo:0)
        }
    }
    if mate_move != 0 {
        return mate_move
    }
    return null_move
}

private func is_can_escape(bt: inout BoardTree, color: Int, sq_checker: Int, pc_checker: Int, sq_opponent_king: Int, sq_object: Int, is_promo: Bool, la: inout LongAttacks) -> Bool {
    var bb_occupied = bt.BB_Occupied[Color.Black.rawValue] | bt.BB_Occupied[Color.White.rawValue]
    bb_occupied ^= ABB_Mask[sq_opponent_king] | ABB_Mask[sq_object]
    var bb_attacks: UInt128 = 0
    switch pc_checker {
    case Piece.Rook.rawValue:
        bb_attacks = la.ABB_Cross_Attacks[sq_checker][ABB_Cross_Mask_Ex[sq_checker] & bb_occupied]!
    case Piece.Dragon.rawValue:
        bb_attacks = la.ABB_Cross_Attacks[sq_checker][ABB_Cross_Mask_Ex[sq_checker] & bb_occupied]!
        bb_attacks |= ABB_Piece_Attacks[color][Piece.King.rawValue][sq_checker]
    case Piece.Bishop.rawValue:
        bb_attacks = la.ABB_Diagonal_Attacks[sq_checker][ABB_Diagonal_Mask_Ex[sq_checker] & bb_occupied]!
    case Piece.Horse.rawValue:
        bb_attacks = la.ABB_Diagonal_Attacks[sq_checker][ABB_Diagonal_Mask_Ex[sq_checker] & bb_occupied]!
        bb_attacks |= ABB_Piece_Attacks[color][Piece.King.rawValue][sq_checker]
    case Piece.Pawn.rawValue, Piece.Knight.rawValue, Piece.Silver.rawValue:
        if is_promo {
            bb_attacks = ABB_Piece_Attacks[color][Piece.Gold.rawValue][sq_checker]
        }
        else {
            bb_attacks = ABB_Piece_Attacks[color][pc_checker][sq_checker]
        }
    case Piece.Lance.rawValue:
        if is_promo {
            bb_attacks = ABB_Piece_Attacks[color][Piece.Gold.rawValue][sq_checker]
        }
        else {
            bb_attacks = la.ABB_Lance_Attacks[color][sq_checker][ABB_Lance_Mask_Ex[color][sq_checker] & bb_occupied]!
        }
    default:
        bb_attacks = ABB_Piece_Attacks[color][pc_checker][sq_checker]
    }
    bb_attacks &= ABB_Mask[sq_object]
    if bb_attacks > 0 {
        return false
    }
    return true
}

private func is_can_capture(bt: inout BoardTree, color: Int, opponent_color: Int, sq_object: Int, is_drop: Bool, ifrom: Int, ipiece: Int, la: inout LongAttacks) -> Bool {
    let bb_myside_attacks: UInt128 = attacks_to_piece(bt:&bt, sq:sq_object, color:color, la:&la)
    let myside_attacks_count: Int = bb_myside_attacks.nonzeroBitCount
    let bb_opp_attacks: UInt128 = attacks_to_piece(bt:&bt, sq:sq_object, color:opponent_color, la:&la)
    let opp_attacks_count: Int = bb_opp_attacks.nonzeroBitCount
    if opp_attacks_count > 1 {
        return true
    }
    if opp_attacks_count == 1 && myside_attacks_count == 0 {
        // Only opponent king's attack is to the objective square.
        // There are no offence side attacks.
        return true
    }
    if opp_attacks_count >= myside_attacks_count {
        if opp_attacks_count == myside_attacks_count && is_drop {
            // Only opponent king's attack is to the objective square from the defence side.
            // Only one attack is to the objective square from the offence side.
            // Current move is drop move.
            return false
        }
        if is_drop {
            return true
        }
        bt.BB_Occupied[color] ^= ABB_Mask[ifrom]
        bt.BB_Piece[color][ipiece] ^= ABB_Mask[ifrom]
        let bb: UInt128 = is_attacked(bt:&bt, sq:bt.SQ_King[opponent_color], color:color, la:&la)
        let bb2: UInt128 = is_attacked(bt:&bt, sq:bt.SQ_King[color], color:color, la:&la)
        var bb3: UInt128 = 0
        switch ipiece {
        case Piece.Pawn.rawValue, Piece.Lance.rawValue, Piece.Rook.rawValue, Piece.Dragon.rawValue:
            let idirec = Adirec[ifrom][sq_object]
            if abs(idirec) == Direction.Direc_File_U2d.rawValue {
                bb3 = is_attacked(bt:&bt, sq:sq_object, color:color, la:&la)
            }
        default:
            bb3 = 0
        }
        bt.BB_Occupied[color] ^= ABB_Mask[ifrom]
        bt.BB_Piece[color][ipiece] ^= ABB_Mask[ifrom]
        if bb2 > 0 {
            return true
        }
        if (bb > 0) || (bb3 > 0) {
            return false
        }
        return true
    }
    return false
}
