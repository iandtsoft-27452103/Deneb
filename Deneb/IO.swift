import Foundation

func read_records(str_file_name: String) -> [Record] {
    var records:[Record] = []
    let filePath = NSString(string: str_file_name).expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    do {
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        contents.enumerateLines { line, stop in
            let parts = line.split(separator: ",")
            let r = Record()
            let str_winner = String(parts[0])
            if str_winner == "B" {
                r.winner = Color.Black.rawValue
            }
            else if str_winner == "W" {
                r.winner = Color.White.rawValue
            }
            else {
                r.winner = 2 // Draw case.
            }
           r.ply = parts.count
           let limit = r.ply - 1
           for i in 2...limit {
               let temp_s = String(parts[i])
               r.str_moves.append(temp_s)
           }
           records.append(r)
        }
    } catch {
        print("file not found.\(error.localizedDescription)")
    }
    return records
}

func init_abb_cross()->[[UInt128: UInt128]] {
    var abb_cross_attacks: [[UInt128: UInt128]] = [[:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:]]
    let filePath = NSString(string: "files/abb_cross_attacks.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    do {
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        contents.enumerateLines { line, stop in
            let parts = line.split(separator: ",")
            let sq: Int! = Int(parts[0])
            let sq2 = sq - 1
            let k: UInt128! = UInt128(parts[1])
            let v: UInt128! = UInt128(parts[2])
            abb_cross_attacks[sq2][k] = v
            // stop.pointee = true
        }
    } catch {
        print("file not found.\(error.localizedDescription)")
    }
    return abb_cross_attacks
}

func init_abb_diag()->[[UInt128: UInt128]] {
    var abb_diag_attacks: [[UInt128: UInt128]] = [[:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:]]
    let filePath = NSString(string: "files/abb_diagonal_attacks.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    do {
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        contents.enumerateLines { line, stop in
            let parts = line.split(separator: ",")
            let sq: Int! = Int(parts[0])
            let sq2 = sq - 1
            let k: UInt128! = UInt128(parts[1])
            let v: UInt128! = UInt128(parts[2])
            abb_diag_attacks[sq2][k] = v
            // stop.pointee = true
        }
    } catch {
        print("file not found.\(error.localizedDescription)")
    }
    return abb_diag_attacks
}

func init_abb_file()->[[UInt128: UInt128]] {
    var abb_file_attacks: [[UInt128: UInt128]] = [[:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:]]
    let filePath = NSString(string: "files/abb_file_attacks.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    do {
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        contents.enumerateLines { line, stop in
            let parts = line.split(separator: ",")
            let sq: Int! = Int(parts[0])
            let sq2 = sq - 1
            let k: UInt128! = UInt128(parts[1])
            let v: UInt128! = UInt128(parts[2])
            abb_file_attacks[sq2][k] = v
            // stop.pointee = true
        }
    } catch {
        print("file not found.\(error.localizedDescription)")
    }
    return abb_file_attacks
}

func init_abb_rank()->[[UInt128: UInt128]] {
    var abb_rank_attacks: [[UInt128: UInt128]] = [[:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:]]
    let filePath = NSString(string: "files/abb_rank_attacks.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    do {
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        contents.enumerateLines { line, stop in
            let parts = line.split(separator: ",")
            let sq: Int! = Int(parts[0])
            let sq2 = sq - 1
            let k: UInt128! = UInt128(parts[1])
            let v: UInt128! = UInt128(parts[2])
            abb_rank_attacks[sq2][k] = v
            // stop.pointee = true
        }
    } catch {
        print("file not found.\(error.localizedDescription)")
    }
    return abb_rank_attacks
}

func init_abb_diag1()->[[UInt128: UInt128]] {
    var abb_diag1_attacks: [[UInt128: UInt128]] = [[:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:]]
    let filePath = NSString(string: "files/abb_diag1_attacks.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    do {
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        contents.enumerateLines { line, stop in
            let parts = line.split(separator: ",")
            let sq: Int! = Int(parts[0])
            let sq2 = sq - 1
            let k: UInt128! = UInt128(parts[1])
            let v: UInt128! = UInt128(parts[2])
            abb_diag1_attacks[sq2][k] = v
            // stop.pointee = true
        }
    } catch {
        print("file not found.\(error.localizedDescription)")
    }
    return abb_diag1_attacks
}

func init_abb_diag2()->[[UInt128: UInt128]] {
    var abb_diag2_attacks: [[UInt128: UInt128]] = [[:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:]]
    let filePath = NSString(string: "files/abb_diag2_attacks.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    do {
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        contents.enumerateLines { line, stop in
            let parts = line.split(separator: ",")
            let sq: Int! = Int(parts[0])
            let sq2 = sq - 1
            let k: UInt128! = UInt128(parts[1])
            let v: UInt128! = UInt128(parts[2])
            abb_diag2_attacks[sq2][k] = v
            // stop.pointee = true
        }
    } catch {
        print("file not found.\(error.localizedDescription)")
    }
    return abb_diag2_attacks
}

func init_abb_lance() -> [[[UInt128: UInt128]]] {
    let a: [[UInt128: UInt128]] = [[:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:]]
    let b: [[UInt128: UInt128]] = [[:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:],
                                                  [:], [:], [:], [:], [:], [:], [:], [:], [:]]
    var d = [a, b]
    let filePath = NSString(string: "files/abb_lance_attacks.txt").expandingTildeInPath
    let fileURL = URL(fileURLWithPath: filePath)

    do {
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        contents.enumerateLines { line, stop in
            let parts = line.split(separator: ",")
            let c: Int! = Int(parts[0])
            let c2 = c - 1
            let sq: Int! = Int(parts[1])
            let sq2 = sq - 1
            let k: UInt128! = UInt128(parts[2])
            let v: UInt128! = UInt128(parts[3])
            d[c2][sq2][k] = v
            // stop.pointee = true
        }
    } catch {
        print("file not found.\(error.localizedDescription)")
    }
    return d
}
