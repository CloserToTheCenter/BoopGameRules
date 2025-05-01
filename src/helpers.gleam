import gleam/list

pub fn both(a, b, check) {
  check(a) && check(b)
}

pub fn either(a, b, check) {
  check(a) || check(b)
}

pub fn eq(x) {
  fn(y) { x == y }
}

pub fn there_are(xs) {
  !list.is_empty(xs)
}

