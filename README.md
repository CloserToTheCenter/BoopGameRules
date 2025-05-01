# Boop Game

Boop is a strategy game, roughly equal to chess in strategic depth. You can [read an overview here](https://boardgamegeek.com/boardgame/355433/boop).

This repo includes a rules engine and command line interface.

The [main file](https://github.com/CloserToTheCenter/BoopGameRules/blob/1faaa709a17c63fa80f08bbdccb808cf3c6552ec/src/boop_the_cat_game.gleam#L29) runs a game between a randomly choosing bot (p1), and a text-input player (p2). You can write your own players or swap these out.

```
PS C:\Users\Documents\gleam\boop_the_cat_game> gleam run
   Compiled in 0.04s
    Running boop_the_cat_game.main

   _____ _____ _____ _____ _____ _____ : 6
   _____ _____ _____ _____ _____ _____ : 5
   _____ _____ _____ _____ _____ _____ : 4
   _____ _____ _____ _____ _____ _____ : 3
   _____ _____ _____ _____ _____ _____ : 2
   _____ _____ _____ _____ _____ _____ : 1
 ->   1     2     3     4     5     6  --/
Grey bench: 8 | 0
Orange bench: 8 | 0
performingPlace(Kitten(Orange), #(4, 4))


   _____ _____ _____ _____ _____ _____ : 6
   _____ _____ _____ _____ _____ _____ : 5
   _____ _____ _____ _ooo_ _____ _____ : 4
   _____ _____ _____ _____ _____ _____ : 3
   _____ _____ _____ _____ _____ _____ : 2
   _____ _____ _____ _____ _____ _____ : 1
 ->   1     2     3     4     5     6  --/
Grey bench: 8 | 0
Orange bench: 7 | 0
over > 3
up   > 4
performingPlace(Kitten(Grey), #(3, 3))
booped!

   _____ _____ _____ _____ _____ _____ : 6
   _____ _____ _____ _____ _____ _____ : 5
   _____ _____ _g_g_ _____ _ooo_ _____ : 4
   _____ _____ _____ _____ _____ _____ : 3
   _____ _____ _____ _____ _____ _____ : 2
   _____ _____ _____ _____ _____ _____ : 1
 ->   1     2     3     4     5     6  --/
```

