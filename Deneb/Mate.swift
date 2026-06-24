public class Mate {
    public var move_cur: [UInt32]
    public var mate_proc: [[UInt32]]
    public var no_mate_proc: [[UInt32]]
    public var first_move: UInt32
    public var second_move: UInt32
    public var max_ply: Int
    public var is_abort: Bool
    public var is_mate_root: Bool
    public var bt: BoardTree
    public var root_check_moves:[UInt32]
    public var root_str_pv: String
    public init() {
        self.move_cur = []
        for _ in 1...Ply_Max {
            self.move_cur.append(0)
        }
        self.mate_proc = []
        self.no_mate_proc = []
        self.first_move = 0
        self.second_move = 0
        self.max_ply = 0
        self.is_abort = false
        self.is_mate_root = false
        self.bt = BoardTree()
        self.root_check_moves = []
        self.root_str_pv = ""
    }
    public func gen_root_check_moves(la: inout LongAttacks) {
        gen_check(bt:&self.bt, moves:&self.root_check_moves, la:&la)
    }
    public func mate_search_wrapper(depth_limit: Int, la: inout LongAttacks, h: inout Hash) {
        let depth_max = depth_limit
        var rest_depth = 1
        while rest_depth <= depth_max {
            self.max_ply = rest_depth
            self.mate_proc = []
            self.no_mate_proc = []
            self.first_move = 0
            self.second_move = 0

            self.is_mate_root = offend(color:self.bt.RootColor, rest_depth:rest_depth, ply:1, la:&la, h:&h)

            if self.is_mate_root {
                break
            }

            if self.is_abort {
                self.is_mate_root = false
                break
            }

            rest_depth += 2
        }

        if self.is_mate_root && !self.is_abort {
            print("詰みあり")
            self.root_str_pv = out_result(rest_depth:rest_depth)
        }
    }

    public func out_result(rest_depth: Int) -> String {
        let l = self.mate_proc
        let nl = self.no_mate_proc
        var str_pv: String = ""
        let str_color = [ "+", "-" ]
        var b = false
        var idxes: [Int] = []
        let limit = l.count - 1
        for i in 0...limit {
            let s = String(i + 1) + " / " + String(limit + 1)
            print(s)
            let limit2 = nl.count - 1
            for j in 0...limit2 {
                let limit3 = nl[j].count - 1
                for k in 0...limit3 {
                    if l[i][k] != nl[j][k] {
                        b = true
                        break
                    }
                    if !b {
                        idxes.append(i)
                    }
                }
            }
        }
        for i in 0...limit {
            if idxes.contains(i){
                continue
            }
            str_pv = ""
            var color = self.bt.RootColor
            let limit2 = rest_depth - 1
            for j in 0...limit2 {
                str_pv += str_color[color]
                str_pv += move_to_csa(move:l[i][j])
                if j != limit2 {
                    str_pv += ", "
                }
                color ^= 1
                print(str_pv)
            }
        }
        return str_pv
    }

    public func offend(color: Int, rest_depth: Int, ply: Int, la: inout LongAttacks, h: inout Hash) -> Bool {
        var is_mate = false
        var check_moves: [UInt32] = []

        if self.is_abort {
            return false
        }

        // generate check moves.
        if ply != 1 {
            gen_check(bt:&self.bt, moves:&check_moves, la:&la)
        }
        else {
            check_moves = self.root_check_moves
        }

        // There are no mate moves, it's not mate.
        if check_moves.count == 0 {
            return false
        }

        let limit = check_moves.count - 1
        if limit >= 0 {
            for i in 0...limit {
                if self.is_abort {
                    return false
                }

                self.move_cur[ply] = check_moves[i]

                if cap_piece(m:move_cur[ply]) == Piece.King.rawValue {
                    continue
                }

                if piece_type(m:move_cur[ply]) == Piece.Empty.rawValue {
                    continue
                }

                self.bt.do_move(move:self.move_cur[ply], h:&h)

                if is_attacked(bt:&self.bt, sq:self.bt.SQ_King[color ^ 1], color:(color ^ 1), la:&la) == 0 {
                    self.bt.undo_move(move:self.move_cur[ply])
                        continue
                }

                // the case of discovered check
                if is_attacked(bt:&self.bt, sq:self.bt.SQ_King[color], color:color, la:&la) != 0 {
                    self.bt.undo_move(move:move_cur[ply])
                    continue
                }

                is_mate = defend(color:(color ^ 1), rest_depth:(rest_depth - 1), ply:(ply + 1), la:&la, h:&h)

                if is_mate {
                    if ply == self.max_ply {
                        var moves: [UInt32] = []
                        for j in 1...ply {
                            moves.append(move_cur[j])
                        }
                        mate_proc.append(moves)
                    }
                    self.bt.undo_move(move:move_cur[ply])
                    return true
                }
                self.bt.undo_move(move:move_cur[ply])
            }
        }
        return false
    }

    public func defend(color: Int, rest_depth: Int, ply: Int, la: inout LongAttacks, h: inout Hash) -> Bool {
        var is_mate = false
        var mate_count: Int = 0
        var evasion_moves: [UInt32] = []

        if self.is_abort {
            return false
        }

        gen_evasion(bt:&self.bt, moves:&evasion_moves, la:&la, h:&h)

        // If rest depth equals to 0 and evasion moves are generated, it's not mate.
        if rest_depth == 0 && evasion_moves.count > 0 {
            return false
        }

        // If there are no evasion moves, it's mate.
        if evasion_moves.count == 0 {
            return true
        }

        let limit = evasion_moves.count - 1
        if limit >= 0 {
            for i in 0...limit {
                if self.is_abort {
                    return false
                }

                self.move_cur[ply] = evasion_moves[i]

                self.bt.do_move(move:self.move_cur[ply], h:&h)

                if is_attacked(bt:&self.bt, sq:self.bt.SQ_King[color], color:color, la:&la) != 0 {
                    self.bt.undo_move(move:move_cur[ply])
                    continue
                }

                is_mate = offend(color:(color ^ 1), rest_depth:(rest_depth - 1), ply:(ply + 1), la:&la, h:&h)

                if !is_mate {
                    var moves: [UInt32] = []
                    for j in 1...ply {
                        moves.append(move_cur[j + 1])
                    }
                    self.no_mate_proc.append(moves)

                    self.bt.undo_move(move:move_cur[ply])
                    return false
                }
                else {
                    mate_count += 1
                }
                self.bt.undo_move(move:move_cur[ply])
            }

            if ply == 2 && mate_count == evasion_moves.count {
                self.first_move = move_cur[1]
                self.second_move = move_cur[2]
            }
        }

        return true
    }
}
