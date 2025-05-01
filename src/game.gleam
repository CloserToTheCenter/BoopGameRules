import bench
import gleam/bool
import gleam/dict
import gleam/io
import gleam/list
import gleam/string
import triple

import board
import helpers.{eq, there_are}
import piece.{type Piece}

pub type Move {
  Place(piece: Piece, tile: board.XY)
  Score(tiles: List(board.XY))
}

fn score_triple(row: triple.Triple(board.XY)) {
  Score(triple.to_list(row))
}

fn score_single(tile) {
  Score([tile])
}

type DeciderFunc =
  fn(Game, List(Move)) -> Move

pub type Game {
  Game(
    board: board.Board,
    bench: bench.Bench,
    active_player: piece.Side,
    p1: DeciderFunc,
    p2: DeciderFunc,
  )
}

pub fn new(p1, p2) -> Game {
  Game(
    board.new(),
    bench.new(), 
    active_player: piece.Orange,
    p1:,
    p2:,
  )
}

// picking moves //

pub fn legal_placements(game: Game) -> List(Move) {
  use piece <- list.flat_map(bench.available_pieces(
    game.bench,
    game.active_player,
  ))

  use tile <- list.map(board.empty_tiles(game.board))

  Place(piece, tile)
}

pub fn legal_scorings(game: Game) -> List(Move) {
  let active_cat = fn(cat: Piece) { cat.side == game.active_player }

  // first consider rows of three

  let row_based_scorings = board.row_of_three(game.board, where: active_cat)

  use <- bool.guard(
    when: there_are(row_based_scorings),
    return: list.map(row_based_scorings, score_triple),
  )

  // otherwise we consider direct kitten graduations

  let candidate_tiles =
    game.board
    |> dict.filter(fn(_, value) { active_cat(value) })
    |> dict.keys

  case list.length(candidate_tiles) {
    x if x < 8 -> []
    8 -> list.map(candidate_tiles, score_single)
    _ -> panic
  }
}

// checking victory //

fn is_won_with_eight_cats_in_play(game: Game) {
  dict.values(game.board)
  |> list.count(eq(piece.Chonky(game.active_player)))
  |> eq(8)
}

fn is_won_with_a_row_of_three(game: Game) {
  there_are({
    use cat <- board.row_of_three(game.board)
    cat == piece.Chonky(game.active_player)
  })
}

pub fn is_won(game: Game) {
  is_won_with_a_row_of_three(game) || is_won_with_eight_cats_in_play(game)
}

// enacting the choices //

pub fn score_several(current: Game, squares) -> Game {
  use game, square <- list.fold(squares, from: current)

  // all legal graduations will target the current player's pieces
  let assert Ok(cat) = dict.get(game.board, square)
  let assert True = game.active_player == cat.side

  Game(
    ..game,
    board: dict.delete(game.board, square),
    bench: bench.restock(game.bench, piece.Chonky(game.active_player)),
  )
}

pub fn place_cat(current: Game, booper: Piece, at spot: board.XY) -> Game {
  let assert Error(_) = dict.get(current.board, spot)

  use game, #(_, target, destination) <- list.fold(
    board.radiate(board.eight_directions, from: spot),
    Game(
      ..current,
      bench: current.bench |> bench.take(booper),
      board: current.board |> dict.insert(spot, booper),
    ),
  )

  case current.board |> board.at_square(target) {
    board.EmptyTile | board.OutOfBounds -> game
    board.Full(boopee) -> {
      use <- bool.guard(!piece.can_push(booper, boopee), return: game)

      case current.board |> board.at_square(destination) {
        board.Full(_) -> game

        board.OutOfBounds -> {
          io.println("booped off the edge!")
          Game(
            ..game,
            bench: game.bench |> bench.restock(boopee),
            board: game.board |> dict.delete(target),
          )
        }

        board.EmptyTile -> {
          io.println("booped!")
          Game(
            ..game,
            board: game.board
              |> dict.delete(target)
              |> dict.insert(destination, boopee),
          )
        }
      }
    }
  }
}

fn switch_sides(game: Game) -> Game {
  case game.active_player {
    piece.Orange -> Game(..game, active_player: piece.Grey)
    piece.Grey -> Game(..game, active_player: piece.Orange)
  }
}

fn player_acts(game: Game, legal_moves) -> Game {
  case legal_moves {
    [] -> game
    _ -> do_player_action(game, legal_moves)
  }
}

fn do_player_action(game: Game, legal_moves: List(Move)) {
  let active_player = case game.active_player {
    piece.Orange -> game.p1
    piece.Grey -> game.p2
  }

  let chosen_move = active_player(game, legal_moves)

  let chosen_move = case list.contains(legal_moves, chosen_move) {
    True -> chosen_move
    False -> {
      io.println("illegal move specified, using a default instead")
      let assert Ok(move) = list.first(legal_moves)
      move
    }
  }

  io.println("performing" <> string.inspect(chosen_move))

  case chosen_move {
    Place(piece, square) -> place_cat(game, piece, square)
    Score(squares) -> score_several(game, squares)
  }
}

pub fn keep_playing_to_the_end(game: Game) -> Game {
  let game = player_acts(game, legal_placements(game))

  // the returned game state has the winner as the "active player"
  use <- bool.guard(is_won(game), return: game)

  let game = player_acts(game, legal_scorings(game))

  switch_sides(game) |> keep_playing_to_the_end
}
