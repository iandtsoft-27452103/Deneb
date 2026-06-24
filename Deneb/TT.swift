import Foundation

public class TT {
    public var value:[UInt128: Int]
    public var color:[UInt128: Int]
    public var is_check:[UInt128: Bool]
    public var move:[UInt128: UInt32]
    public var ply:[UInt128: Int]
    private let queue = DispatchQueue(label: "safe.tt.queue")
    public init () {
        self.value = [:]
        self.color = [:]
        self.is_check = [:]
        self.move = [:]
        self.ply = [:]
    }
    public func clear () {
        self.value.removeAll()
        self.color.removeAll()
        self.is_check.removeAll()
        self.move.removeAll()
        self.ply.removeAll()
    }
    public func store (k: UInt128, v: Int, c: Int, ch: Bool, m: UInt32, param_ply: Int) {
        self.queue.sync {
             self.value[k] = v
        }
        self.queue.sync {
             self.color[k] = c
        }
        self.queue.sync {
             self.is_check[k] = ch
        }
        self.queue.sync {
            self.move[k] = m
        }
        self.queue.sync {
            self.ply[k] = param_ply
        }
    }
}
