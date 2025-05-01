import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string

import helpers.{both}
import piece.{type Piece}
import triple

const board_size = 6

pub type XY =
  #(Int, Int)

fn sum(vectors: List(XY)) {
  use a, b <- list.fold(vectors, from: #(0, 0))
  #(a.0 + b.0, a.1 + b.1)
}

const four_directions = [
  // looks in four of eight directions
  // for scanning all three-in-a-rows
  // the search head starts in the top left and scans
  // using every direction here would double-count triplets

  //
  //   @-
  //  /|\

  #(1, 0),
  #(1, -1),
  #(0, -1),
  #(-1, -1),
]

pub const eight_directions = [
  // every direction, used to boop pieces on placement

  //   \|/
  //   -@-
  //   /|\

  // this set of four same as above
  #(1, 0),
  #(1, -1),
  #(0, -1),
  #(-1, -1),
  // this set are the complementary directions
  #(-1, 0),
  #(-1, 1),
  #(0, 1),
  #(1, 1),
]

pub fn radiate(dirs: List(XY), from square: XY) -> List(#(XY, XY, XY)) {
  use dir <- list.map(dirs)
  #(square, sum([square, dir]), sum([square, dir, dir]))
}

pub type Board =
  Dict(XY, Piece)

pub fn new() -> Board {
  dict.new()
}

pub type TileStatus {
  Full(piece: Piece)
  EmptyTile
  OutOfBounds
}

fn in_bounds(tile: XY) {
  use i <- both(tile.0, tile.1)
  0 <= i && i <= board_size
}

pub fn at_square(board: Board, at tile: XY) -> TileStatus {
  use <- bool.guard(when: !in_bounds(tile), return: OutOfBounds)

  dict.get(board, tile)
  |> result.map(Full)
  |> result.unwrap(or: EmptyTile)
}

fn enumerate_tiles() {
  use x <- list.flat_map(list.range(1, board_size))
  use y <- list.map(list.range(1, board_size))
  #(x, y)
}

pub fn row_of_three(on board: Board, where criteria) {
  enumerate_tiles()
  |> list.flat_map(radiate(four_directions, from: _))
  |> list.filter(fn(row) {
    use tile <- triple.all(row)
    case at_square(board, tile) {
      Full(cat) -> criteria(cat)
      _ -> False
    }
  })
}

pub fn empty_tiles(board) {
  enumerate_tiles()
  |> list.filter_map(fn(xy) {
    case board |> at_square(xy) {
      EmptyTile -> Ok(xy)
      _ -> Error(Nil)
    }
  })
}

pub fn show_single_row(board: Board, col_num: Int) -> String {
  {
    use row_num <- list.map(list.range(1, 6))

    case board |> at_square(#(row_num, col_num)) {
      OutOfBounds -> panic as "game should never print outofbounds squares"
      EmptyTile -> "_____"
      Full(cat) -> piece.show(cat)
    }
  }
  |> string.join(" ")
}
