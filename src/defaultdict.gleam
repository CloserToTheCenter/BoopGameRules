import gleam/dict.{type Dict}
import gleam/list
import gleam/result

pub opaque type DefaultDict(a, b) {
  DefaultDict(items: Dict(a, b), default: b)
}

// Create
pub fn new(with default) {
  DefaultDict(dict.new(), default)
}

pub fn from_list(pairs: List(#(a, b)), default default) {
  pairs
  |> list.filter(fn(pair) {
    let #(_, val) = pair
    val != default
  })
  |> dict.from_list
  |> DefaultDict(default)
}

// Check Contents
pub fn get(dd: DefaultDict(a, b), key) -> b {
  dict.get(dd.items, key) |> result.unwrap(or: dd.default)
}

pub fn specified(dd: DefaultDict(a, b), key) -> Bool {
  dict.has_key(dd.items, key)
}

// Modify at some Key
pub fn insert(dd: DefaultDict(a, b), key, val) {
  case val == dd.default {
    True -> dict.delete(dd.items, key)
    False -> dict.insert(dd.items, key, val)
  }
  |> DefaultDict(dd.default)
}

pub fn upsert(dd: DefaultDict(a, b), key, transform) {
  get(dd, key) |> transform |> insert(dd, key, _)
}

pub fn reset(dd: DefaultDict(a, b), at key: a) -> DefaultDict(a, b) {
  dict.delete(dd.items, key) |> DefaultDict(dd.default)
}

pub fn reset_many(dd: DefaultDict(a, b), keys keys: List(a)) {
  list.fold(keys, from: dd.items, with: dict.delete) |> DefaultDict(dd.default)
}

pub fn reset_every(dd: DefaultDict(a, b)) -> DefaultDict(a, b) {
  DefaultDict(dict.new(), dd.default)
}

pub fn retain(dd: DefaultDict(a, b), only keys: List(a)) -> DefaultDict(a, b) {
  use items, key <- list.fold(keys, from: new(dd.default))
  insert(items, key, get(items, key))
}

pub fn current_keys(dd: DefaultDict(a, b)) -> List(a) {
  dict.keys(dd.items)
}

pub fn has_nondefault_key(dd: DefaultDict(a, b), key: a) -> Bool {
  dict.has_key(dd.items, key)
}

// combine makes less sense because the defaults would etc
pub fn merge(
  first: DefaultDict(a, b),
  second: DefaultDict(a, b),
  with func: fn(b, b) -> b,
  default default: b,
) -> DefaultDict(a, b) {
  list.append(dict.keys(first.items), dict.keys(second.items))
  |> list.unique
  |> list.map(fn(key) { #(key, func(get(first, key), get(second, key))) })
  |> dict.from_list
  |> DefaultDict(default)
}
