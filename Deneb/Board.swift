public class BoardTree {
    public var BB_Piece :[[UInt128]]
    public var BB_Occupied: [UInt128]
    public var SQ_King: [Int]
    public var Hand: [Int]
    public var Board: [Int]
    public var RootColor: Int
    public var CurrentColor : Int
    public var RootMoves: [UInt32]
    public var Hash: [UInt128]
    public var CurrentHash: UInt128
    public var PrevHash: UInt128
    public var Ply: Int
    public var EvalArray: [Int]
    public init () {
        self.BB_Piece = [[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
                         [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]]
        self.BB_Occupied = [ 0, 0 ]
        self.SQ_King = [0, 0]
        self.Hand = [0, 0]
        self.RootColor = 0
        self.CurrentColor = 0
        self.Board = []
        self.RootMoves = []
        self.Hash = []
        self.EvalArray = []
        var limit = Ply_Max + 1
        for _ in 1...limit {
            self.Hash.append(0)
            self.EvalArray.append(0)
        }
        limit = Square_NB
        for _ in 1...limit {
            self.Board.append(0)
        }
        self.CurrentHash = 0
        self.PrevHash = 0
        self.Ply = 0
    }
    public func clear () {
        self.BB_Piece = [[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
                         [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]]
        self.BB_Occupied = [ 0, 0 ]
        self.SQ_King = [0, 0]
        self.Hand = [0, 0]
        self.RootColor = 0
        self.CurrentColor = 0
        self.Board = []
        self.RootMoves = []
        self.Hash = []
        self.EvalArray = []
        var limit = Ply_Max + 1
        for _ in 1...limit {
            self.Hash.append(0)
            self.EvalArray.append(0)
        }
        limit = Square_NB
        for _ in 1...limit {
            self.Board.append(0)
        }
        self.CurrentHash = 0
        self.PrevHash = 0
        self.Ply = 0
    }
    public func init_start_pos (h: inout Hash) {
        self.BB_Occupied[0] = (511 << 18) | ABB_Mask[64] | ABB_Mask[70] | 511
        self.BB_Occupied[1] = (134022655 << 54)
        self.BB_Piece[0][Piece.Pawn.rawValue] = 511 << 18
        self.BB_Piece[1][Piece.Pawn.rawValue] = 133955584 << 36
        self.BB_Piece[0][Piece.Lance.rawValue] = ABB_Mask[72] | ABB_Mask[80]
        self.BB_Piece[1][Piece.Lance.rawValue] = ABB_Mask[0] | ABB_Mask[8]
        self.BB_Piece[0][Piece.Knight.rawValue] = ABB_Mask[73] | ABB_Mask[79]
        self.BB_Piece[1][Piece.Knight.rawValue] = ABB_Mask[1] | ABB_Mask[7]
        self.BB_Piece[0][Piece.Silver.rawValue] = ABB_Mask[74] | ABB_Mask[78]
        self.BB_Piece[1][Piece.Silver.rawValue] = ABB_Mask[2] | ABB_Mask[6]
        self.BB_Piece[0][Piece.Gold.rawValue] = ABB_Mask[75] | ABB_Mask[77]
        self.BB_Piece[1][Piece.Gold.rawValue] = ABB_Mask[3] | ABB_Mask[5]
        self.BB_Piece[0][Piece.Bishop.rawValue] = ABB_Mask[64]
        self.BB_Piece[1][Piece.Bishop.rawValue] = ABB_Mask[16]
        self.BB_Piece[0][Piece.Rook.rawValue] = ABB_Mask[70]
        self.BB_Piece[1][Piece.Rook.rawValue] = ABB_Mask[10]
        self.BB_Piece[0][Piece.King.rawValue] = ABB_Mask[76]
        self.BB_Piece[1][Piece.King.rawValue] = ABB_Mask[4]
        for c in Color.Black.rawValue...Color.White.rawValue {
            for pc in Piece.Pro_Pawn.rawValue...Piece.Dragon.rawValue {
                self.BB_Piece[c][pc] = 0
            }
        }
        self.Board[0] = -Piece.Lance.rawValue
        self.Board[8] = -Piece.Lance.rawValue
        self.Board[1] = -Piece.Knight.rawValue
        self.Board[7] = -Piece.Knight.rawValue
        self.Board[2] = -Piece.Silver.rawValue
        self.Board[6] = -Piece.Silver.rawValue
        self.Board[3] = -Piece.Gold.rawValue
        self.Board[5] = -Piece.Gold.rawValue
        self.Board[4] = -Piece.King.rawValue
        self.Board[10] = -Piece.Rook.rawValue
        self.Board[16] = -Piece.Bishop.rawValue
        self.Board[18] = -Piece.Pawn.rawValue
        self.Board[19] = -Piece.Pawn.rawValue
        self.Board[20] = -Piece.Pawn.rawValue
        self.Board[21] = -Piece.Pawn.rawValue
        self.Board[22] = -Piece.Pawn.rawValue
        self.Board[23] = -Piece.Pawn.rawValue
        self.Board[24] = -Piece.Pawn.rawValue
        self.Board[25] = -Piece.Pawn.rawValue
        self.Board[26] = -Piece.Pawn.rawValue
        self.Board[72] = Piece.Lance.rawValue
        self.Board[80] = Piece.Lance.rawValue
        self.Board[73] = Piece.Knight.rawValue
        self.Board[79] = Piece.Knight.rawValue
        self.Board[74] = Piece.Silver.rawValue
        self.Board[78] = Piece.Silver.rawValue
        self.Board[75] = Piece.Gold.rawValue
        self.Board[77] = Piece.Gold.rawValue
        self.Board[76] = Piece.King.rawValue
        self.Board[64] = Piece.Bishop.rawValue
        self.Board[70] = Piece.Rook.rawValue
        self.Board[54] = Piece.Pawn.rawValue
        self.Board[55] = Piece.Pawn.rawValue
        self.Board[56] = Piece.Pawn.rawValue
        self.Board[57] = Piece.Pawn.rawValue
        self.Board[58] = Piece.Pawn.rawValue
        self.Board[59] = Piece.Pawn.rawValue
        self.Board[60] = Piece.Pawn.rawValue
        self.Board[61] = Piece.Pawn.rawValue
        self.Board[62] = Piece.Pawn.rawValue
        self.Hand[0] = 0
        self.Hand[1] = 0
        self.CurrentHash = h.hash_func(bt: self)
        self.RootColor = Color.Black.rawValue
        self.CurrentColor = self.RootColor
        self.SQ_King[0] = 76
        self.SQ_King[1] = 4
        self.Ply = 1
        self.PrevHash = 0
        self.Hash[1] = self.CurrentHash
        // EvalArray is not changed in this method.
    }
    public func deep_copy(bt: BoardTree, flag: Bool) -> BoardTree {
        let bt_base = BoardTree()
        for c in Color.Black.rawValue...Color.White.rawValue {
            bt_base.BB_Occupied[c] = bt.BB_Occupied[c]
            bt_base.SQ_King[c] = bt.SQ_King[c]
            for pc in Piece.Pawn.rawValue...Piece.Dragon.rawValue {
                bt_base.BB_Piece[c][pc] = bt.BB_Piece[c][pc]
            }
            bt_base.Hand[c] = bt.Hand[c]
        }

        bt_base.RootColor = bt.RootColor
        bt_base.Ply = bt.Ply
        bt_base.CurrentHash = bt.CurrentHash
        bt_base.PrevHash = bt.PrevHash

        for sq in 0...Square_NB-1 {
            bt_base.Board[sq] = bt.Board[sq]
        }

        for i in 0...Ply_Max {
            if (i != 0 && bt.Hash[i] == 0) { break }
            bt_base.Hash[i] = bt.Hash[i]
            bt_base.EvalArray[i] = bt.EvalArray[i]
        }

        if flag {
            let limit = bt.RootMoves.count - 1
            for i in 0...limit {
                let move = bt.RootMoves[i]
                bt_base.RootMoves.append(move)
            }
        }

        return bt_base
    }
    public func do_move (move: UInt32, h: inout Hash) {
        self.PrevHash = self.CurrentHash
        let color = self.CurrentColor
        let ifrom = from(m: move)
        let ito = to(m: move)
        let ipiece = piece_type(m: move)
        let is_promote = flag_promo(m: move)
        if ifrom >= Square_NB {
            self.BB_Piece[color][ipiece] ^= ABB_Mask[ito]
            self.CurrentHash ^= h.PieceRand[color][ipiece][ito]
            self.Hand[color] -= Hand_Hash[ipiece]
            self.Board[ito] = -Sign_Table[color] * ipiece
            self.BB_Occupied[color] ^= ABB_Mask[ito]
        }
        else {
            let bb_set_clear = ABB_Mask[ifrom] | ABB_Mask[ito]
            self.BB_Occupied[color] ^= bb_set_clear
            self.Board[ifrom] = Piece.Empty.rawValue
            if is_promote > 0 {
                self.BB_Piece[color][ipiece] ^= ABB_Mask[ifrom]
                self.BB_Piece[color][ipiece + Promote] ^= ABB_Mask[ito]
                self.CurrentHash ^= h.PieceRand[color][ipiece][ifrom] ^ h.PieceRand[color][ipiece + Promote][ito]
                self.Board[ito] = -Sign_Table[color] * (ipiece + Promote)
            }
            else {
                if ipiece == Piece.King.rawValue {
                    self.SQ_King[color] = ito
                }
                self.BB_Piece[color][ipiece] ^= bb_set_clear
                self.CurrentHash ^= h.PieceRand[color][ipiece][ifrom] ^ h.PieceRand[color][ipiece][ito]
                self.Board[ito] = -Sign_Table[color] * ipiece
            }
            let icap_piece = cap_piece(m: move)
            var index = icap_piece
            if icap_piece > 0 {
                if icap_piece > Piece.King.rawValue {
                    index -= Promote
                }
                self.Hand[color] += Hand_Hash[index]
                self.BB_Piece[color ^ 1][icap_piece] ^= ABB_Mask[ito]
                self.CurrentHash ^= h.PieceRand[color ^ 1][icap_piece][ito]
                self.BB_Occupied[color ^ 1] ^= ABB_Mask[ito]
            }
        }

        self.Hash[self.Ply] = self.PrevHash
        self.Hash[self.Ply + 1] = self.CurrentHash
        self.CurrentColor ^= 1
        self.Ply += 1
    }

    public func undo_move (move: UInt32) {
        self.CurrentHash = self.PrevHash
        self.CurrentColor ^= 1
        let color = self.CurrentColor
        let ifrom = from(m: move)
        let ito = to(m: move)
        let ipiece = piece_type(m: move)
        let is_promote = flag_promo(m: move)
        if ifrom >= Square_NB {
            self.BB_Piece[color][ipiece] ^= ABB_Mask[ito]
            self.Hand[color] += Hand_Hash[ipiece]
            self.Board[ito] = Piece.Empty.rawValue
            self.BB_Occupied[color] ^= ABB_Mask[ito]
        }
        else {
            let bb_set_clear = ABB_Mask[ifrom] | ABB_Mask[ito]
            self.BB_Occupied[color] ^= bb_set_clear
            self.Board[ifrom] = -Sign_Table[color] * ipiece
            if is_promote > 0 {
                self.BB_Piece[color][ipiece] ^= ABB_Mask[ifrom]
                self.BB_Piece[color][ipiece + Promote] ^= ABB_Mask[ito]
            }
            else {
                if ipiece == Piece.King.rawValue {
                    self.SQ_King[color] = ifrom
                }
                self.BB_Piece[color][ipiece] ^= bb_set_clear
            }
            let icap_piece = cap_piece(m: move)
            var index = icap_piece
            if icap_piece > 0 {
                if icap_piece > Piece.King.rawValue {
                    index -= Promote
                }
                self.Hand[color] -= Hand_Hash[index]
                self.BB_Piece[color ^ 1][icap_piece] ^= ABB_Mask[ito]
                self.BB_Occupied[color ^ 1] ^= ABB_Mask[ito]
                self.Board[ito] = Sign_Table[color] * icap_piece
            }
            else {
                self.Board[ito] = Piece.Empty.rawValue
            }
        }
        self.PrevHash = self.Hash[self.Ply - 2]
        self.Hash[self.Ply] = 0
        self.Ply -= 1
    }

    public func do_null_move () {
        self.Hash[self.Ply + 1] = self.CurrentHash
        self.Ply += 1
    }

    public func undo_null_move () {
        self.Hash[self.Ply] = 0
        self.Ply -= 1
    }

    // Return Value
    // -> 0: You can not declare in this position.
    // -> 1: Black wins.
    // -> 2: White wins.
    public func is_declaration_win() -> Int {
        var black_score = 0
        var white_score = 0
        var b_tekijin_piece_count = 0
        var w_tekijin_piece_count = 0
        var b_hand_piece_count = [0, 0, 0, 0, 0, 0, 0, 0]
        var w_hand_piece_count = [0, 0, 0, 0, 0, 0, 0, 0]
        var b_board_piece_count = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        var w_board_piece_count = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        let bb0 = self.BB_Piece[Color.Black.rawValue][Piece.King.rawValue] & BB_White_Position
        let bb1 = self.BB_Piece[Color.White.rawValue][Piece.King.rawValue] & BB_Black_Position
        if bb0 == 0 && bb1 == 0 {
            return 0
        }
        if bb0 > 0 {
            for i in Piece.Pawn.rawValue...Piece.Rook.rawValue {
                b_hand_piece_count[i] = (self.Hand[Color.Black.rawValue] & Hand_Mask[i]) >> Hand_Rev_Bit[i]
                if i >= Piece.Bishop.rawValue {
                    black_score += 5 * b_hand_piece_count[i]
                }
                else {
                    black_score += b_hand_piece_count[i]
                }
            }
            for i in Piece.Pawn.rawValue...Piece.Dragon.rawValue {
                if i == Piece.None.rawValue {
                    continue
                }
                var bb_object = self.BB_Piece[Color.Black.rawValue][i] & BB_Rev_Color_Position[Color.Black.rawValue]
                b_board_piece_count[i] = bb_object.nonzeroBitCount
                b_tekijin_piece_count += b_board_piece_count[i]
                let bb_temp = BB_DMZ | BB_Rev_Color_Position[Color.White.rawValue]
                bb_object = bb_temp & self.BB_Piece[Color.Black.rawValue][i]
                b_board_piece_count[i] += bb_object.nonzeroBitCount
                if i == Piece.King.rawValue {
                    continue
                }
                if i == Piece.Bishop.rawValue || i == Piece.Rook.rawValue || i >= Piece.Horse.rawValue {
                    black_score += 5 * b_board_piece_count[i]
                }
                else {
                    black_score += b_board_piece_count[i]
                }
            }
        }
        if bb1 > 0 {
            for i in Piece.Pawn.rawValue...Piece.Rook.rawValue {
                w_hand_piece_count[i] = (self.Hand[Color.White.rawValue] & Hand_Mask[i]) >> Hand_Rev_Bit[i]
                if i >= Piece.Bishop.rawValue {
                    white_score += 5 * w_hand_piece_count[i]
                }
                else {
                    white_score += w_hand_piece_count[i]
                }
            }
            for i in Piece.Pawn.rawValue...Piece.Dragon.rawValue {
                if i == Piece.None.rawValue {
                    continue
                }
                var bb_object = self.BB_Piece[Color.White.rawValue][i] & BB_Rev_Color_Position[Color.White.rawValue]
                w_board_piece_count[i] = bb_object.nonzeroBitCount
                w_tekijin_piece_count += w_board_piece_count[i]
                let bb_temp = BB_DMZ | BB_Rev_Color_Position[Color.Black.rawValue]
                bb_object = bb_temp & self.BB_Piece[Color.White.rawValue][i]
                w_board_piece_count[i] += bb_object.nonzeroBitCount
                if i == Piece.King.rawValue {
                    continue
                }
                if i == Piece.Bishop.rawValue || i == Piece.Rook.rawValue || i >= Piece.Horse.rawValue {
                    white_score += 5 * w_board_piece_count[i]
                }
                else {
                    white_score += w_board_piece_count[i]
                }
            }
        }
        if bb0 > 0 && black_score >= 28 && b_tekijin_piece_count >= 10 {
            return 1
        }
        if bb1 > 0 && white_score >= 27 && w_tekijin_piece_count >= 10 {
            return 2
        }
        return 0
    }

    public func is_repetition(tt: inout TT) -> Int {
        let limit = self.Ply - 12
        if limit < 1 {
            return 0
        }
        var counter = 0
        var i = self.Ply
        while i >= limit {
            if self.CurrentHash == self.Hash[i] {
                counter += 1
            }
            i -= 1
        }
        // The number of same position is equals to three, it's repetition.
        // This idea derived from Apery.
        if counter > 2 {
            if tt.is_check.keys.contains(self.CurrentHash) {
                let b = tt.is_check[self.CurrentHash] ?? false
                if !b {
                    return 1 // normal repetition -> It's draw.
                }
                else {
                    return 2 // succeeding check repetition -> It's lost the game.
                }
            }
        }
        return 0
    }
}
