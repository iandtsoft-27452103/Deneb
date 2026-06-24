public func csa_to_move (bt: inout BoardTree, str_csa: String) -> UInt32 {
    var move: UInt32 = 0
    var ifrom: Int = CSA_TO_SQ[String(str_csa.prefix(2))]!
    let startIndex = str_csa.startIndex
    var start = str_csa.index(startIndex, offsetBy: 2)
    var end = str_csa.index(startIndex, offsetBy: 4)
    var str = String(str_csa[start..<end])
    let ito: Int = CSA_TO_SQ[str]!
    var ipiece:Int = 0
    var flag_promo:Int = 0
    if ifrom < Square_NB {
        ipiece = abs(bt.Board[ifrom])
    }
    else {
        start = str_csa.index(startIndex, offsetBy: 4)
        end = str_csa.index(startIndex, offsetBy: 6)
        str = String(str_csa[start..<end])
        ipiece = CSA_TO_PC[str]!
        ifrom += ipiece - 1
    }
    let icap_piece: Int = abs(bt.Board[ito])
    if ipiece < Piece.King.rawValue {
        start = str_csa.index(startIndex, offsetBy: 4)
        end = str_csa.index(startIndex, offsetBy: 6)
        str = String(str_csa[start..<end])
        let temp_piece = CSA_TO_PC[str]!
        if temp_piece > Piece.King.rawValue {
            flag_promo = 1
        }
    }
    move = pack(from:ifrom, to:ito, pc:ipiece, cap_pc:icap_piece, flag_promo:flag_promo)
    return move
}

public func move_to_csa (move: UInt32) -> String {
    let ifrom = from(m:move)
    let ito = to(m:move)
    let flag_promo = flag_promo(m:move)
    var str: String = Str_CSA[ifrom]
    str += Str_CSA[ito]
    if flag_promo == 0 {
        let ipiece = piece_type(m:move)
        str += Str_Piece[ipiece]
    }
    else {
        let ipiece = piece_type(m:move) + Promote
        str += Str_Piece[ipiece]
    }
    return str
}
