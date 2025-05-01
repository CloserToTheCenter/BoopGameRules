pub type Triple(a) =
  #(a, a, a)

pub fn all(triple: Triple(a), condition) {
  condition(triple.0) && condition(triple.1) && condition(triple.2)
}

pub fn map(triple: Triple(a), func) {
  #(func(triple.0), func(triple.1), func(triple.2))
}

pub fn to_list(triple: Triple(a)) {
  [triple.0, triple.1, triple.2]
}