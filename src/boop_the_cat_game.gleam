import gleam/erlang
import gleam/list

import game.{type Game, type Move}
import interface

fn show_and_random(game: Game, moves: List(Move)) -> Move {
  interface.show_game(game)
  interface.pick_random_move(moves)
}

fn show_and_text_input(game: Game, moves: List(Move)) -> Move {
  let _ = erlang.get_line("")
  interface.show_game(game)

  // each gamestate has at least one legal move
  let assert True = list.length(moves) > 0

  // and we find it here
  let assert Ok(move) = case list.first(moves) {
    Ok(game.Place(_, _)) -> Ok(interface.placement_choice(moves))
    _ -> interface.itemized_choice(moves)
  }

  // could improve type safety be using a list with min length 1
  move
}

pub fn main() {
  game.new(show_and_random, show_and_text_input)
  |> game.keep_playing_to_the_end()
}
