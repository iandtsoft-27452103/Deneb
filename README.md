# About Pull Request

This repository is read-only, so Pull Request is not accepted. Thank you for your understanding.

# Deneb

Deneb is a shogi engine framework, written by Go.

Shogi is game like chess.

## Source Code Explanation

(1) AttackOperations.swift : Functions of piece attacks.

(2) Board.swift : Functions of shogi board.

(3) Common.swift : Common constants and variables.

(4) CSA.swift : Functions of CSA format.

(5) Deneb.swift: The entry point of this software.

(6) GenMoves.swift : Functions for generating moves.

(7) Hash.swift : Functions of hash values.

(8) IO.swift : Functions for reading records.

(9) Mate.swift : Functions for mate search.

(10) Mate1Ply.swift : Function for mate in one ply.

(11) Move.swift : Functions for moves.

(12) Record.swift : Class for records.

(13) SFEN.swift : Functions for SFEN.

(14) Test.swift : Functions for testing.

(15) TT.swifto :Functions for transposition table.

## Operating environment

(1) OS: Windows 11 Pro

(2) Swift Version: 6.2.1

I think this software will work on Mac as well.

## How to build

Start console and execute the command below.

swift build

## References

I developed this software referring to the softwares as below.

(1) Bonanza

(2) Apery

(3) YaneuraOu

(4) Gikou

(5) dlshogi

As far as I know, the source code for Bonanza and dlshogi is currently not publicly available.

## About the future

I think I'll add search functions and analyze records functions.
