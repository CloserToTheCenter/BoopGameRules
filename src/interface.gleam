import gleam/erlang
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

import bench
import board
import game
import piece

pub fn show_game(game: game.Game) {
  show_board(game.board)
  show_bench(game.bench)
}

fn show_board(board: board.Board) {
  list.map(list.range(1, 6), fn(i) {
    let row_num = 7 - i

    io.print("\n   ")
    io.print(board.show_single_row(board, row_num))
    io.print(" : " <> int.to_string(row_num))
  })

  io.println("\n ->   1     2     3     4     5     6  --/")
}

fn show_bench(bench: bench.Bench) {
  bench |> show_half(piece.Grey) |> io.println
  bench |> show_half(piece.Orange) |> io.println
}

fn show_half(bench, side) {
  [
    string.inspect(side),
    "bench:",
    bench.count(bench, piece.Kitten(side)) |> int.to_string,
    "|",
    bench.count(bench, piece.Chonky(side)) |> int.to_string,
  ]
  |> string.join(" ")
}

pub fn itemized_choice(moves: List(game.Move)) {
  case moves {
    [] -> Error(Nil)
    [single] -> Ok(single)
    many -> {
      list.index_map(many, fn(x, y) { #(y, x) })
      |> do_itemized_choice
      |> Ok
    }
  }
}

pub fn pick_random_move(moves: List(game.Move)) {
  let index = int.random(list.length(moves))
  let assert Ok(move) = list.drop(moves, index) |> list.first
  move
}

fn do_itemized_choice(indexed_moves: List(#(Int, game.Move))) -> game.Move {
  {
    use #(idx, option) <- list.each(indexed_moves)
    io.println(string.inspect(idx) <> ". " <> string.inspect(option))
  }

  let choice = list.key_find(indexed_moves, ask_for_number(">"))

  case choice {
    Error(Nil) -> {
      io.println("not understood, try again")
      do_itemized_choice(indexed_moves)
    }
    Ok(move) -> move
  }
}

fn ask_for_number(prompt) {
  erlang.get_line(prompt <> " ")
  |> result.unwrap("")
  |> string.trim
  |> int.parse
  |> result.unwrap(-1)
}

pub fn placement_choice(moves: List(game.Move)) -> game.Move {
  let x = ask_for_number("over >")
  let y = ask_for_number("up   >")

  let potential_moves: List(game.Move) =
    list.filter_map(moves, fn(move) {
      case move {
        game.Place(_, tile) if tile == #(x, y) -> Ok(move)
        _ -> Error(Nil)
      }
    })

  case potential_moves {
    [] -> {
      io.println("invalid square, try again")
      placement_choice(moves)
    }
    [single] -> single
    many -> {
      list.index_map(many, fn(x, y) { #(y, x) })
      |> do_itemized_choice
    }
  }
}
