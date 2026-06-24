public class Record {
    public var str_moves: [String]
    public var winner: Int
    public var ply: Int
    public init() {
        self.str_moves = []
        self.winner = 0
        self.ply = 0
    }
}
