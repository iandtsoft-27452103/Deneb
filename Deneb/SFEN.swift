public func to_sfen(bt: inout BoardTree) -> String {
    let color = bt.CurrentColor
    var str_sfen: String = ""
    var flag = false
    var i: Int = 0
    var empty_count: Int = 0
    while i < Square_NB {
        let str_piece = Str_SFEN_Pc[bt.Board[i]]!
        if str_piece == "" {
            empty_count += 1
            flag = true
        }
        else {
            if flag == true {
                flag = false
                str_sfen += String(empty_count)
                empty_count = 0
            }
            str_sfen += str_piece
        }
        if i != (Square_NB - 1) && FileTable[i] == File.File9.rawValue {
            if empty_count > 0 {
                flag = false
                str_sfen += String(empty_count)
                empty_count = 0
            }
            str_sfen += "/"
        }
        i += 1
    }

    str_sfen += " "
    str_sfen += Str_Color[color]!
    str_sfen += " "

    var k :Int = 0
    if bt.Hand[Color.Black.rawValue] == 0 && bt.Hand[Color.White.rawValue] == 0 {
        str_sfen += "-"
    }
    else {
        for i in Color.Black.rawValue...Color.White.rawValue {
            var j = Piece.Rook.rawValue
            while j >= Piece.Pawn.rawValue {
                let num = (bt.Hand[i] & Hand_Mask[j]) >> Hand_Rev_Bit[j]
                if num == 0 {
                    j -= 1
                    continue
                }
                if num > 0 {
                    if num == 1 {
                        k = -Sign_Table[i] * j
                        str_sfen += Str_SFEN_Pc[k]!
                    }
                    else if num > 1 {
                        k = -Sign_Table[i] * j
                        str_sfen += String(num) + Str_SFEN_Pc[k]!
                    }
                }
                j -= 1
            }
        }
    }

    str_sfen += " 1"
    return str_sfen
}

public func to_board(str_sfen: String, h: inout Hash) -> BoardTree {
    var flag = false
    let bt = BoardTree()
    let str_temp = str_sfen.split(separator: " ")
    let str_board = str_temp[0]
    var startIndex = str_board.startIndex
    var limit: Int = str_board.count - 1
    var sq = 0
    var empty_num = 0
    for i in 0...limit {
        let start = str_board.index(startIndex, offsetBy: i)
        let end = str_board.index(startIndex, offsetBy: i + 1)
        let s = String(str_board[start..<end])
        if s == "+" {
            flag = true
        }
        else if s == "/" {
            continue
        }
        else {
            if Int_Empty_Num[s] != nil {
                empty_num = Int_Empty_Num[s]!
                var j = 0
                while j < empty_num {
                    bt.Board[sq] = Piece.Empty.rawValue
                    sq += 1
                    j += 1
                }
            }
            else {
                var int_pc: Int = Int_Pc[s]!
                if int_pc > 0 {
                    if flag {
                        int_pc += Promote
                        flag = false
                    }
                    bt.BB_Piece[Color.Black.rawValue][int_pc] |= ABB_Mask[sq]
                    bt.BB_Occupied[Color.Black.rawValue] |= ABB_Mask[sq]
                    if int_pc == Piece.King.rawValue {
                        bt.SQ_King[Color.Black.rawValue] = sq
                    }
                }
                else {
                    if flag {
                        int_pc -= Promote
                        flag = false
                    }
                    bt.BB_Piece[Color.White.rawValue][-int_pc] |= ABB_Mask[sq]
                    bt.BB_Occupied[Color.White.rawValue] |= ABB_Mask[sq]
                    if int_pc == -Piece.King.rawValue {
                        bt.SQ_King[Color.White.rawValue] = sq
                    }
                }
                bt.Board[sq] = int_pc
                sq += 1
            }
        }
    }
    let str_color:String = String(str_temp[1])
    bt.RootColor = Num_Color[str_color]!
    bt.CurrentColor = bt.RootColor
    let str_hand:String = String(str_temp[2])
    limit = str_hand.count - 1
    flag = false
    var num = 1
    for i in 0...limit {
        startIndex = str_hand.startIndex
        let start = str_hand.index(startIndex, offsetBy: i)
        let end = str_hand.index(startIndex, offsetBy: i + 1)
        let s = String(str_hand[start..<end])
        if s == "-" {
            break
        }
        if s == "1" && !flag {
            flag = true
        }
        else {
            if flag {
                num = 10 + Int_Hand_Num[s]!
                flag = false
            }
            else {
                if Int_Hand_Num[s] != nil {
                    num = Int_Hand_Num[s]!
                }
                else {
                    var color:Int
                    var int_pc: Int = Int_Pc[s]!
                    if int_pc > 0 {
                        color = Color.Black.rawValue
                    }
                    else {
                        color = Color.White.rawValue
                        int_pc = -int_pc
                    }
                    var j = 0
                    while j < num {
                        bt.Hand[color] += Hand_Hash[int_pc]
                        j += 1
                    }
                    num = 1
                }
            }
        }
    }
    bt.CurrentHash = h.hash_func(bt:bt)
    bt.Hash[0] = bt.PrevHash
    bt.Hash[1] = bt.CurrentHash
    bt.Ply = 1
    return bt
}
