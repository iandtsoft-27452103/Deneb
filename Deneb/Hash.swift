// This file is derived from Bonanza's rand.c and hash.c .
// PRNG based on Mersenne Twister ( M.Matsumoto and T.Nishimura, 1998 )

public struct RandWorkT {
    public var count: UInt64
    public var cnst: [UInt64]
    public var vec: [UInt64]
    public init (u:UInt64) {
        var v = u
        self.count = RandN
        self.cnst = [0, 0x9908b0df]
        self.vec = []
        for _ in 1...RandN {
            self.vec.append(0)
        }
        let limit = RandN - 1
        for i in 1...limit {
            v = (i + 1812433253 * (v ^ (v >> 30)))
            v &= Mask32
            self.vec[Int(i)] = v
        }
    }
}

public struct Hash {
    public var PieceRand :[[[UInt128]]]
    public var rand_work : RandWorkT
    public init () {
        self.PieceRand = [[[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]],[[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]]]
        self.rand_work = RandWorkT(u:5489)
        let limit = Square_NB - 1
        for c in Color.Black.rawValue...Color.White.rawValue {
            for pc in Piece.Pawn.rawValue...Piece.Dragon.rawValue {
                for _ in 0...limit {
                    self.PieceRand[c][pc].append(0)
                }
            }
        }
    }
    public mutating func rand32() -> UInt64 {
        var u: UInt64 = 0
        var u0: UInt64 = 0
        var u1: UInt64 = 0
        var u2: UInt64 = 0
        var i:Int = 0
        if self.rand_work.count == RandN {
            self.rand_work.count = 0
            var limit = RandN - RandM
            while i < limit {
                u = rand_work.vec[i] & MaskU
                u |= rand_work.vec[i + 1] & MaskL

                u0 = rand_work.vec[i + Int(RandM)]
                u1 = u >> 1
                u2 = rand_work.cnst[Int(u & 1)]

                rand_work.vec[i] = u0 ^ u1 ^ u2

                i += 1
            }
            limit = RandN - 1
            while i < limit {
                u = rand_work.vec[i] & MaskU
                u |= rand_work.vec[i + 1] & MaskL

                u0 = rand_work.vec[i + Int(RandM) - Int(RandN)]
                u1 = u >> 1;
                u2 = rand_work.cnst[Int(u & 1)];

                self.rand_work.vec[i] = u0 ^ u1 ^ u2
                i += 1
            }
            u = rand_work.vec[Int(RandN) - 1] & MaskU
            u |= rand_work.vec[0] & MaskL

            u0 = rand_work.vec[Int(RandM) - 1]
            u1 = u >> 1
            u2 = rand_work.cnst[Int(u & 1)]

            self.rand_work.vec[Int(RandN) - 1] = u0 ^ u1 ^ u2
        }

        u = rand_work.vec[Int(rand_work.count)]
        rand_work.count += 1
        u ^= (u >> 11)
        u ^= (u << 7) & 0x9d2c5680
        u ^= (u << 15) & 0xefc60000
        u ^= (u >> 18)

        return u
    }

    public mutating func rand64() -> UInt64 {
        let h = rand32()
        let l = rand32()

        return l | (h << 32)
    }

    public mutating func rand128() -> UInt128 {
        let h = UInt128(rand64())
        let l = UInt128(rand64())

        return l | (h << 64)
    }

    public mutating func ini_random_table() {
        let limit = Square_NB - 1
        for c in Color.Black.rawValue...Color.White.rawValue {
            for pc in Piece.Pawn.rawValue...Piece.Dragon.rawValue {
                for sq in 0...limit {
                    self.PieceRand[c][pc][sq] = rand128()
                }
            }
        }
    }

    public mutating func hash_func(bt: BoardTree) -> UInt128 {
        var bb: UInt128 = 0
        var key: UInt128 = 0
        for c in Color.Black.rawValue...Color.White.rawValue {
            for pc in Piece.Pawn.rawValue...Piece.Dragon.rawValue {
                bb = bt.BB_Piece[c][pc]
                while bb > 0 {
                    let sq = Square_NB - bb.trailingZeroBitCount - 1
                    bb ^= ABB_Mask[sq]
                    key ^= self.PieceRand[c][pc][sq]
                }
            }
        }
        return key
    }
}
