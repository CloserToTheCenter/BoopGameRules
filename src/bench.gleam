import gleam/list

import defaultdict.{type DefaultDict}
import piece.{type Piece}

pub type Bench =
  DefaultDict(Piece, Int)

pub fn new() -> Bench {
  defaultdict.from_list(
    [#(piece.Kitten(piece.Orange), 8), #(piece.Kitten(piece.Grey), 8)],
    default: 0,
  )
}

pub fn available_pieces(bench: Bench, for side) -> List(Piece) {
  defaultdict.current_keys(bench)
  |> list.filter(fn(cat) { cat.side == side })
}

pub fn restock(bench: Bench, with piece) {
  defaultdict.upsert(bench, piece, fn(i) { i + 1 })
}

pub fn take(bench: Bench, piece) {
  let assert True = defaultdict.has_nondefault_key(bench, piece)
  defaultdict.upsert(bench, piece, fn(i) { i - 1 })
}

pub fn count(bench, of piece) -> Int {
  defaultdict.get(bench, piece)
}