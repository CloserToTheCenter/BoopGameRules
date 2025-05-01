
pub type Side {
  Orange
  Grey
}

pub type Piece {
  Chonky(side: Side)
  Kitten(side: Side)
}

pub fn can_push(first: Piece, second: Piece) {
  case first, second {
    Kitten(_), Chonky(_) -> False
    _, _ -> True
  }
}

pub fn other_side(side) -> Side {
  case side {
    Orange -> Grey
    Grey -> Orange
  }
}

pub fn show(piece: Piece) {
  case piece {
    Chonky(Orange) -> "_000_"
    Kitten(Orange) -> "_ooo_"
    Chonky(Grey) -> "_G_G_"
    Kitten(Grey) -> "_g_g_"
  }
}
