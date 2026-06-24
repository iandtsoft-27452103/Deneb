import Foundation

public func read_test_data(file_name: String, comments: inout [String], data: inout [String]) {
    let filePath = NSString(string: file_name).expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)
    var li_c: [String] = []
    var li_d: [String] = []
    do {
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        var flag: Int = 0
        contents.enumerateLines { line, stop in
            if flag == 0 {
                li_c.append(line)
            }
            else {
                li_d.append(line)
            }
            flag ^= 1
        }
        //print("file contents :\n\(contents)")
    } catch {
        print("file not found.\(error.localizedDescription)")
    }
    comments = li_c
    data = li_d
}

public func test_gen_drop(la: inout LongAttacks, h: inout Hash) {
    var li_c: [String] = []
    var li_d: [String] = []
    read_test_data(file_name:"files/test_data_drop.txt", comments:&li_c, data:&li_d)
    //print(li_c)
    //print(li_d)
    let limit = li_d.count - 1

    let filePath = NSString(string: "files/debug_gendrop_log.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)
    var str_out = ""
    var bt: BoardTree = BoardTree()

    for i in 0...limit {
        let str_sfen: String = li_d[i]
        bt.clear()
        bt = to_board(str_sfen:str_sfen, h:&h)
        print(str_sfen)
        print(bt.SQ_King)
        var moves: [UInt32] = []
        gen_drop(bt:&bt, moves:&moves, la:&la)
        let limit2 = moves.count - 1
        if limit2 <= 0 {
            print(li_c[i])
            print("\n")
            continue
        }
        str_out += li_c[i] + "\n"
        for j in 0...limit2 {
            let m = moves[j]
            str_out += move_to_csa(move:m)
            if j != limit2 {
                str_out += ","
            }
        }
        str_out += "\n"
        print(li_c[i])
        //print(str_out)
        //do {
        //    try li_c[i].write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        //    try str_out.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        //} catch {
        //    print("file can't written!: \(error.localizedDescription)")
        //}
    }
    do {
        try str_out.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
    } catch {
        print("file can't written!: \(error.localizedDescription)")
    }
}

public func test_gen_no_cap(la: inout LongAttacks, h: inout Hash) {
    var li_c: [String] = []
    var li_d: [String] = []
    read_test_data(file_name:"files/test_data_gennocap.txt", comments:&li_c, data:&li_d)
    //print(li_c)
    //print(li_d)
    let limit = li_d.count - 1

    let filePath = NSString(string: "files/debug_gennocap_log.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    var str_out = ""
    var bt: BoardTree = BoardTree()

    for i in 0...limit {
        let str_sfen: String = li_d[i]
        bt.clear()
        bt = to_board(str_sfen:str_sfen, h:&h)
        print(str_sfen)
        print(bt.SQ_King)
        var moves: [UInt32] = []
        gen_no_cap(bt:&bt, moves:&moves, la:&la)
        let limit2 = moves.count - 1
        if limit2 <= 0 {
            print(li_c[i])
            print("\n")
            continue
        }
        str_out += li_c[i] + "\n"
        for j in 0...limit2 {
            let m = moves[j]
            str_out += move_to_csa(move:m)
            if j != limit2 {
                str_out += ","
            }
        }
        str_out += "\n"
        print(li_c[i])
        //print(str_out)
        //do {
        //    try li_c[i].write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        //    try str_out.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        //} catch {
        //    print("file can't written!: \(error.localizedDescription)")
        //}
    }
    do {
        try str_out.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
    } catch {
        print("file can't written!: \(error.localizedDescription)")
    }
}

public func test_gen_cap(la: inout LongAttacks, h: inout Hash) {
    var li_c: [String] = []
    var li_d: [String] = []
    read_test_data(file_name:"files/test_data_gencap.txt", comments:&li_c, data:&li_d)
    //print(li_c)
    //print(li_d)
    let limit = li_d.count - 1
    let filePath = NSString(string: "files/debug_gencap_log.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    var str_out = ""
    var bt: BoardTree = BoardTree()

    for i in 0...limit {
        let str_sfen: String = li_d[i]
        bt.clear()
        bt = to_board(str_sfen:str_sfen, h:&h)
        print(str_sfen)
        print(bt.SQ_King)
        var moves: [UInt32] = []
        gen_cap(bt:&bt, moves:&moves, la:&la)
        let limit2 = moves.count - 1
        if limit2 < 0 {
            print(li_c[i])
            print("\n")
            continue
        }
        str_out += li_c[i] + "\n"
        for j in 0...limit2 {
            let m = moves[j]
            str_out += move_to_csa(move:m)
            if j != limit2 {
                str_out += ","
            }
        }
        str_out += "\n"
        print(li_c[i])
        //print(str_out)
        //do {
        //    try li_c[i].write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        //    try str_out.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        //} catch {
        //    print("file can't written!: \(error.localizedDescription)")
        //}
    }
    do {
        try str_out.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
    } catch {
        print("file can't written!: \(error.localizedDescription)")
    }
}

public func test_gen_evasion(la: inout LongAttacks, h: inout Hash) {
    var li_c: [String] = []
    var li_d: [String] = []
    read_test_data(file_name:"files/test_data_evasion.txt", comments:&li_c, data:&li_d)
    //print(li_c)
    //print(li_d)
    let limit = li_d.count - 1
    let filePath = NSString(string: "files/debug_genevasion_log.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    var str_out = ""
    var bt: BoardTree = BoardTree()

    for i in 0...limit {
        let str_sfen: String = li_d[i]
        bt.clear()
        bt = to_board(str_sfen:str_sfen, h:&h)
        print(str_sfen)
        print(bt.SQ_King)
        print(bt.BB_Piece)
        var moves: [UInt32] = []
        print("richard")
        gen_evasion(bt:&bt, moves:&moves, la:&la, h:&h)
        let limit2 = moves.count - 1
        print(limit2)
        if limit2 < 0 {
            print(li_c[i])
            print("\n")
            continue
        }
        print("nn")
        str_out += li_c[i] + "\n"
        for j in 0...limit2 {
            let m = moves[j]
            print(move_to_csa(move:m))
            str_out += move_to_csa(move:m)
            if j != limit2 {
                str_out += ","
            }
        }
        str_out += "\n"
        print(li_c[i])
        //print(str_out)
        //do {
        //    try li_c[i].write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        //    try str_out.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        //} catch {
        //    print("file can't written!: \(error.localizedDescription)")
        //}
    }
    do {
        try str_out.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
    } catch {
        print("file can't written!: \(error.localizedDescription)")
    }
}

public func test_gen_check(la: inout LongAttacks, h: inout Hash) {
    var li_c: [String] = []
    var li_d: [String] = []
    read_test_data(file_name:"files/test_data_check.txt", comments:&li_c, data:&li_d)
    //print(li_c)
    //print(li_c)
    //print(li_d)
    let limit = li_d.count - 1
    let filePath = NSString(string: "files/debug_gencheck_log.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    var str_out = ""
    var bt: BoardTree = BoardTree()

    for i in 0...limit {
        let str_sfen: String = li_d[i]
        bt.clear()
        bt = to_board(str_sfen:str_sfen, h:&h)
        print(str_sfen)
        print(bt.SQ_King)
        print(bt.BB_Piece)
        var moves: [UInt32] = []
        print("richard")
        gen_check(bt:&bt, moves:&moves, la:&la)
        let limit2 = moves.count - 1
        print("limit2")
        print(limit2)
        if limit2 < 0 {
            print(li_c[i])
            print("\n")
            continue
        }
        print("nn")
        str_out += li_c[i] + "\n"
        for j in 0...limit2 {
            let m = moves[j]
            print(move_to_csa(move:m))
            str_out += move_to_csa(move:m)
            if j != limit2 {
                str_out += ","
            }
        }
        str_out += "\n"
        print(li_c[i])
        //print(str_out)
        //do {
        //    try li_c[i].write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        //    try str_out.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        //} catch {
        //    print("file can't written!: \(error.localizedDescription)")
        //}
    }
    do {
        try str_out.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
    } catch {
        print("file can't written!: \(error.localizedDescription)")
    }
}

public func test_gen_check2(la: inout LongAttacks, h: inout Hash) {
    var li_c: [String] = []
    var li_d: [String] = []
    read_test_data(file_name:"files/test_data_b_check_additional.txt", comments:&li_c, data:&li_d)
    //print(li_c)
    //print(li_c)
    //print(li_d)
    let limit = li_d.count - 1
    let filePath = NSString(string: "files/debug_gencheck2_log.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    var str_out = ""
    var bt: BoardTree = BoardTree()

    for i in 0...limit {
        let str_sfen: String = li_d[i]
        bt.clear()
        bt = to_board(str_sfen:str_sfen, h:&h)
        print(str_sfen)
        print(bt.SQ_King)
        print(bt.BB_Piece)
        var moves: [UInt32] = []
        gen_check(bt:&bt, moves:&moves, la:&la)
        let limit2 = moves.count - 1
        print("limit2")
        print(limit2)
        if limit2 < 0 {
            print(li_c[i])
            print("\n")
            continue
        }
        print("nn")
        str_out += li_c[i] + "\n"
        for j in 0...limit2 {
            let m = moves[j]
            print(move_to_csa(move:m))
            str_out += move_to_csa(move:m)
            if j != limit2 {
                str_out += ","
            }
        }
        str_out += "\n"
        print(li_c[i])
        //print(str_out)
        //do {
        //    try li_c[i].write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        //    try str_out.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        //} catch {
        //    print("file can't written!: \(error.localizedDescription)")
        //}
    }
    do {
        try str_out.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
    } catch {
        print("file can't written!: \(error.localizedDescription)")
    }
}

public func test_gen_check3(la: inout LongAttacks, h: inout Hash) {
    var li_c: [String] = []
    var li_d: [String] = []
    read_test_data(file_name:"files/test_data_w_check_additional.txt", comments:&li_c, data:&li_d)
    //print(li_c)
    //print(li_d)
    let limit = li_d.count - 1

    let filePath = NSString(string: "files/debug_gencheck3_log.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    var str_out = ""
    var bt: BoardTree = BoardTree()

    for i in 0...limit {
        let str_sfen: String = li_d[i]
        bt.clear()
        bt = to_board(str_sfen:str_sfen, h:&h)
        print(str_sfen)
        print(bt.SQ_King)
        print(bt.BB_Piece)
        var moves: [UInt32] = []
        print("richard")
        gen_check(bt:&bt, moves:&moves, la:&la)
        let limit2 = moves.count - 1
        print("limit2")
        print(limit2)
        if limit2 < 0 {
            print(li_c[i])
            print("\n")
            continue
        }
        print("nn")
        str_out += li_c[i] + "\n"
        for j in 0...limit2 {
            let m = moves[j]
            print(move_to_csa(move:m))
            str_out += move_to_csa(move:m)
            if j != limit2 {
                str_out += ","
            }
        }
        str_out += "\n"
        print(li_c[i])
        //print(str_out)
        //do {
        //    try li_c[i].write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        //    try str_out.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        //} catch {
        //    print("file can't written!: \(error.localizedDescription)")
        //}
    }
    do {
        try str_out.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
    } catch {
        print("file can't written!: \(error.localizedDescription)")
    }

}

public func test_mate_one_ply(la: inout LongAttacks, h: inout Hash) {
    var li_c: [String] = []
    var li_d: [String] = []
    read_test_data(file_name:"files/test_data_b_mate1ply.txt", comments:&li_c, data:&li_d)
    //print(li_c)
    //print(li_d)
    let limit = li_d.count - 1

    let filePath = NSString(string: "files/debug_mate1ply_log.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    var str_out = ""

    for i in 0...limit {
        let str_sfen: String = li_d[i]
        var bt: BoardTree = to_board(str_sfen:str_sfen, h:&h)
        let mate_move: UInt32 = mate_in_one_ply(bt:&bt, la:&la)
        str_out += li_c[i]
        if mate_move > 0 {
            str_out += move_to_csa(move:mate_move)
        }
        str_out += "\n"
        print(li_c[i])
        //if li_c[i] == "#先手_金(22)" {
            //break
        //}
        //print(str_out)
    }

    do {
        try str_out.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
    } catch {
        print("file can't written!: \(error.localizedDescription)")
    }
}

public func test_mate_one_ply2(la: inout LongAttacks, h: inout Hash) {
    var li_c: [String] = []
    var li_d: [String] = []
    read_test_data(file_name:"files/test_data_w_mate1ply.txt", comments:&li_c, data:&li_d)
    //print(li_c)
    //print(li_d)
    let limit = li_d.count - 1

    let filePath = NSString(string: "files/debug_mate1ply_log.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    var str_out = ""

    for i in 0...limit {
        let str_sfen: String = li_d[i]
        var bt: BoardTree = to_board(str_sfen:str_sfen, h:&h)
        let mate_move: UInt32 = mate_in_one_ply(bt:&bt, la:&la)
        str_out += li_c[i]
        if mate_move > 0 {
            str_out += move_to_csa(move:mate_move)
        }
        str_out += "\n"
        print(li_c[i])
        //if li_c[i] == "#先手_金(22)" {
            //break
        //}
        //print(str_out)
    }

    do {
        try str_out.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
    } catch {
        print("file can't written!: \(error.localizedDescription)")
    }
}

public func test_mate_search(la: inout LongAttacks, h: inout Hash) {
    let str_sfen: String = "7n1/7SR/3s1p1k1/3b2s2/6pp1/9/9/9/9 b RBP 1"
    //var bt: BoardTree = to_board(str_sfen:str_sfen, h:&h)
    let mate = Mate()
    let depth_limit = 9
    mate.bt = to_board(str_sfen:str_sfen, h:&h)
    out_board(bt:mate.bt)
    mate.gen_root_check_moves(la:&la)
    mate.mate_search_wrapper(depth_limit:depth_limit, la:&la, h:&h)
    if mate.is_mate_root {
        print(mate.root_str_pv)
    } else {
        print("詰みではない")
    }
}

public func test_do_move(h: inout Hash) {
    var bt = BoardTree()
    bt.init_start_pos(h:&h)
    let records = read_records(str_file_name:"files/20220403_nhk_hai.txt")
    let limit = records[0].str_moves.count - 1
    print(limit)
    for i in 0...limit {
        print(i)
        let str_move = records[0].str_moves[i]
        print(str_move)
        let move = csa_to_move (bt:&bt, str_csa:str_move)
        bt.do_move(move:move, h:&h)
        if i == 72 {
            out_board(bt:bt)
        }
    }
    out_board(bt:bt)
}

public func test_undo_move(h: inout Hash) {
    var bt = BoardTree()
    bt.init_start_pos(h:&h)
    let records = read_records(str_file_name:"files/20220403_nhk_hai.txt")
    let limit = records[0].str_moves.count - 1
    for i in 0...limit {
        print(i)
        let str_move = records[0].str_moves[i]
        print(str_move)
        let bt_before = bt.deep_copy(bt:bt, flag:false)
        let move = csa_to_move (bt:&bt, str_csa:str_move)
        bt.do_move(move:move, h:&h)
        bt.undo_move(move:move)
        let b = compare_board(bt1:bt_before, bt2:bt)
        if !b {
            print("error occurs!")
            let s = "i=" + String(i) + "\n"
            print(s)
            break
        }
        bt.do_move(move:move, h:&h)
    }
    //out_board(bt:bt)
}

// Return Value
// -> 0: You can not declare in this position.
// -> 1: Black wins.
// -> 2: White wins.
public func test_declaration_win(h: inout Hash) {
    var bt = BoardTree()
    var str_sfen = ["", "", "", "", "", "", "", "", "", "", ""]
    str_sfen[0] = "+L+NSGKGS+N+L/1+R5+B1/+P+P+P+P+P+P+P+P+P/9/9/9/+p+p+p+p+p+p+p+p+p/1+r5+b1/+l+nsgkgs+n+l b - 1"// 後手勝ち
    str_sfen[1] = "+L+NSGKGS+N+L/+P+R5+B1/+P+P+P+P+P+P+P+P+P/9/9/9/+p+p+p+p+p+p+p+p1/1+r5+b1/+l+nsgkgs+n+l b - 1"// 先手勝ち
    str_sfen[2] = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1"// どちらの勝ちでもない → 初期局面
    str_sfen[3] = "+L+NSGK4/1+R7/+P+P+P+P+P4/9/9/9/+p+p+p+p+p4/7+b1/+l+nsgk4 b BGSNL4Prgsnl4p 1"// 後手勝ち
    str_sfen[4] = "+L+NSGK4/1+R7/+P+P+P+P+P4/9/9/9/+p+p+p+p+p4/7+b1/+l+nsgk4 b BGSNL5Prgsnl3p 1"// 先手勝ち
    str_sfen[5] = "4k4/9/9/9/9/9/9/4p4/4K4 b RB2G2S2N2L9Prb2g2s2n2l8p 1"// どちらの勝ちでもない → 先手玉が王手
    str_sfen[6] = "4k4/4P4/9/9/9/9/9/9/4K4 b RB2G2S2N2L8Prb2g2s2n2l9p 1"// どちらの勝ちでもない → 後手玉が王手
    str_sfen[7] = "+L+NSGKGS+N+L/1+R5+B1/+P+P+P+P+P+P+P+P+P/9/9/8k/+p+p+p+p+p+p+p+p+p/1+r5+b1/+l+nsg1gs+n+l b - 1"// どちらの勝ちでもない → 後手玉が宣言勝ちの位置にいない
    str_sfen[8] = "+L+NSG1GS+N+L/+P+R5+B1/+P+P+P+P+P+P+P+P+P/K8/9/9/+p+p+p+p+p+p+p+p1/1+r5+b1/+l+nsgkgs+n+l b - 1"// どちらの勝ちでもない → 先手玉が宣言勝ちの位置にいない
    str_sfen[9] = "+L+NSGK4/1+R7/+P+P+P+P+P4/9/9/8k/+p+p+p+p+p4/7+b1/+l+nsg5 b BGSNL4Prgsnl4p 1"// どちらの勝ちでもない → 後手玉が宣言勝ちの位置にいない
    str_sfen[10] = "+L+NSG5/1+R7/+P+P+P+P+P4/K8/9/9/+p+p+p+p+p4/7+b1/+l+nsgk4 b BGSNL5Prgsnl3p 1"// どちらの勝ちでもない → 先手玉が宣言勝ちの位置にいない
    for i in 0...10 {
        let s = str_sfen[i]
        bt = to_board(str_sfen:s, h:&h)
        let iret = bt.is_declaration_win()
        print(iret)
    }
}

public func test_repetition(h: inout Hash) {
    var bt = BoardTree()
    bt.init_start_pos(h:&h)
    var tt = TT()
    let records = read_records(str_file_name:"files/test_repetition.txt")
    let limit = records[0].str_moves.count - 1
    for i in 0...limit {
        print(i)
        let str_move = records[0].str_moves[i]
        print(str_move)
        let move = csa_to_move (bt:&bt, str_csa:str_move)
        bt.do_move(move:move, h:&h)
        tt.store(k:bt.CurrentHash, v:0, c:bt.CurrentColor, ch:false, m:move, param_ply:bt.Ply)
    }
    let iret = bt.is_repetition(tt:&tt)
    print("result")
    print(iret)
}

// The comparison of hash array is not implemented.
public func compare_board(bt1: BoardTree, bt2: BoardTree) -> Bool {
    for i in 0...1 {
        if bt1.SQ_King[i] != bt2.SQ_King[i] {
            print("a")
            return false
        }
        if bt1.BB_Occupied[i] != bt2.BB_Occupied[i] {
            print("b")
            return false
        }
        for j in Piece.Pawn.rawValue...Piece.Dragon.rawValue {
            if bt1.BB_Piece[i][j] != bt2.BB_Piece[i][j] {
                print("c")
                print(i)
                print(j)
                return false
            }
        }
        if bt1.Hand[i] != bt2.Hand[i] {
            print("d")
            return false
        }
    }
    for i in 0...80 {
        if bt1.Board[i] != bt2.Board[i] {
            print("e")
            print(i)
            print(bt1.Board[i])
            print(bt2.Board[i])
            return false
        }
    }

    if bt1.CurrentHash != bt2.CurrentHash {
        print("f")
        return false
    }
    if bt1.PrevHash != bt2.PrevHash {
        print("g")
        return false
    }
    if bt1.RootColor != bt2.RootColor {
        print("h")
        return false
    }
    if bt1.Ply != bt2.Ply {
        print("i")
        return false
    }
    return true
}

public func out_board(bt: BoardTree) {
    var out_board = ""
    var count = 0
    var flag = false
    for i in 0...80 {
        if count == 9 {
            out_board += "\n"
            count = 0
        }
        flag = false
        if bt.Board[i] < 0 {
            flag = true
        }
        let pc = abs(bt.Board[i])
        var str_piece = ""
        switch pc {
            case Piece.Empty.rawValue:
                str_piece = "  "
            case Piece.Pawn.rawValue:
                str_piece = "歩"
            case Piece.Lance.rawValue:
                str_piece = "香"
            case Piece.Knight.rawValue:
                str_piece = "桂"
            case Piece.Silver.rawValue:
                str_piece = "銀"
            case Piece.Gold.rawValue:
                str_piece = "金"
            case Piece.Bishop.rawValue:
                str_piece = "角"
            case Piece.Rook.rawValue:
                str_piece = "飛"
            case Piece.King.rawValue:
                str_piece = "玉"
            case Piece.Pro_Pawn.rawValue:
                str_piece = "と"
            case Piece.Pro_Lance.rawValue:
                str_piece = "杏"
            case Piece.Pro_Knight.rawValue:
                str_piece = "圭"
            case Piece.Pro_Silver.rawValue:
                str_piece = "全"
            case Piece.Horse.rawValue:
                str_piece = "馬"
            case Piece.Dragon.rawValue:
                str_piece = "龍"
            default:
                str_piece = ""
        }
        if !flag {
            str_piece = " " + str_piece
        }
        else {
            str_piece = "v" + str_piece
        }
        out_board += str_piece + "|"
        count += 1
    }

    var str_hand = ["", ""]
    for i in 0...1 {
        for j in Piece.Pawn.rawValue...Piece.Rook.rawValue {
            let s = String((bt.Hand[i] & Hand_Mask[j]) >> Hand_Rev_Bit[j])
            switch j {
                case Piece.Pawn.rawValue:
                    str_hand[i] = str_hand[i] + "歩" + s
                case Piece.Lance.rawValue:
                    str_hand[i] = str_hand[i] + "香" + s
                case Piece.Knight.rawValue:
                    str_hand[i] = str_hand[i] + "桂" + s
                case Piece.Silver.rawValue:
                    str_hand[i] = str_hand[i] + "銀" + s
                case Piece.Gold.rawValue:
                    str_hand[i] = str_hand[i] + "金" + s
                case Piece.Bishop.rawValue:
                    str_hand[i] = str_hand[i] + "角" + s
                case Piece.Rook.rawValue:
                    str_hand[i] = str_hand[i] + "飛" + s
                default:
                    str_hand[i] = ""
            }
        }
    }
    var bb: UInt128 = 0
    //var sq: Int = 0
    var str_bb_piece = [["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""], ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]]
    //var str_bb_pawn_attacks = ["", ""]
    //var str_bb_total_gold = ["", ""]
    //var str_bb_bh = ["", ""]
    //var str_bb_rd = ["", ""]
    //var str_bb_hdk = ["", ""]
    var str_sq_king = ["", ""]

    str_bb_piece[0][1] = "BB_BPAWN : ";
    bb = bt.BB_Piece[0][1]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[0][1] += String(sq) + ", "
    }

    str_bb_piece[0][2] = "BB_BLANCE : ";
    bb = bt.BB_Piece[0][2]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[0][2] += String(sq) + ", "
    }

    str_bb_piece[0][3] = "BB_BKNIGHT : ";
    bb = bt.BB_Piece[0][3]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[0][3] += String(sq) + ", "
    }

    str_bb_piece[0][4] = "BB_BSILVER : ";
    bb = bt.BB_Piece[0][4]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[0][4] += String(sq) + ", "
    }

    str_bb_piece[0][5] = "BB_BGOLD : ";
    bb = bt.BB_Piece[0][5]
    print(bb)
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[0][5] += String(sq) + ", "
    }

    str_bb_piece[0][6] = "BB_BBISHOP : ";
    bb = bt.BB_Piece[0][6]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[0][6] += String(sq) + ", "
    }

    str_bb_piece[0][7] = "BB_BROOK : ";
    bb = bt.BB_Piece[0][7]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[0][7] += String(sq) + ", "
    }

    str_bb_piece[0][8] = "BB_BKING : ";
    bb = bt.BB_Piece[0][8]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[0][8] += String(sq) + ", "
    }

    str_bb_piece[0][9] = "BB_BPRO_PAWN : ";
    bb = bt.BB_Piece[0][9]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[0][9] += String(sq) + ", "
    }

    str_bb_piece[0][10] = "BB_BPRO_LANCE : ";
    bb = bt.BB_Piece[0][10]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[0][10] += String(sq) + ", "
    }

    str_bb_piece[0][11] = "BB_BPRO_KNIGHT : ";
    bb = bt.BB_Piece[0][11]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[0][11] += String(sq) + ", "
    }

    str_bb_piece[0][12] = "BB_BPRO_SILVER : ";
    bb = bt.BB_Piece[0][12]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[0][12] += String(sq) + ", "
    }

    str_bb_piece[0][14] = "BB_BHORSE : ";
    bb = bt.BB_Piece[0][14]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[0][14] += String(sq) + ", "
    }

    str_bb_piece[0][15] = "BB_BDRAGON : ";
    bb = bt.BB_Piece[0][15]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[0][15] += String(sq) + ", "
    }

    str_sq_king[0] = "SQ_BKING : " + String(bt.SQ_King[0])

    str_bb_piece[1][1] = "BB_WPAWN : ";
    bb = bt.BB_Piece[1][1]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[1][1] += String(sq) + ", "
    }

    str_bb_piece[1][2] = "BB_WLANCE : ";
    bb = bt.BB_Piece[1][2]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[1][2] += String(sq) + ", "
    }

    str_bb_piece[1][3] = "BB_WKNIGHT : ";
    bb = bt.BB_Piece[1][3]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[1][3] += String(sq) + ", "
    }

    str_bb_piece[1][4] = "BB_WSILVER : ";
    bb = bt.BB_Piece[1][4]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[1][4] += String(sq) + ", "
    }

    str_bb_piece[1][5] = "BB_WGOLD : ";
    bb = bt.BB_Piece[1][5]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[1][5] += String(sq) + ", "
    }

    str_bb_piece[1][6] = "BB_WBISHOP : ";
    bb = bt.BB_Piece[1][6]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[1][6] += String(sq) + ", "
    }

    str_bb_piece[1][7] = "BB_WROOK : ";
    bb = bt.BB_Piece[1][7]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[1][7] += String(sq) + ", "
    }

    str_bb_piece[1][8] = "BB_WKING : ";
    bb = bt.BB_Piece[1][8]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[1][8] += String(sq) + ", "
    }

    str_bb_piece[1][9] = "BB_WPRO_PAWN : ";
    bb = bt.BB_Piece[1][9]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[1][9] += String(sq) + ", "
    }

    str_bb_piece[1][10] = "BB_WPRO_LANCE : ";
    bb = bt.BB_Piece[1][10]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[1][10] += String(sq) + ", "
    }

    str_bb_piece[1][11] = "BB_WPRO_KNIGHT : ";
    bb = bt.BB_Piece[1][11]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[1][11] += String(sq) + ", "
    }

    str_bb_piece[1][12] = "BB_WPRO_SILVER : ";
    bb = bt.BB_Piece[1][12]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[1][12] += String(sq) + ", "
    }

    str_bb_piece[1][14] = "BB_WHORSE : ";
    bb = bt.BB_Piece[1][14]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[1][14] += String(sq) + ", "
    }

    str_bb_piece[1][15] = "BB_WDRAGON : ";
    bb = bt.BB_Piece[1][15]
    while bb > 0 {
        let sq = Square_NB - bb.trailingZeroBitCount - 1
        bb ^= ABB_Mask[sq]
        str_bb_piece[1][15] += String(sq) + ", "
    }

    str_sq_king[1] = "SQ_WKING : " + String(bt.SQ_King[1])

    let filePath = NSString(string: "files/debug_log.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    do {
        try out_board.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        var temp_s = "先手持ち駒：" + str_hand[0]
        print(temp_s)
        try temp_s.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        temp_s = "後手持ち駒：" + str_hand[1]
        print(temp_s)
        try temp_s.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        print("file written!: \(fileURL.path)")
        for c in 0...1 {
            for pc in 1...15 {
                if pc == 13 {
                    continue;
                }
                temp_s = str_bb_piece[c][pc]
                print(temp_s)
                try temp_s.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
            }
            //try str_bb_pawn_attacks[c].write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
            //try str_bb_total_gold[c].write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
            //try str_bb_bh[c].write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
            //try str_bb_rd[c].write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
            //try str_bb_hdk[c].write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
            print(str_sq_king[c])
            try str_sq_king[c].write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        }
    } catch {
        print("file can't written!: \(error.localizedDescription)")
    }
}
