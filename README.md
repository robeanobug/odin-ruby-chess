Currently I am missing the checkmate logic. Here is the pseudocode I have so far.

1. Are we in check?
    - Game continues. Not checkmate.

2. Can the king escape?
    - Grab the king's valid moves.
    - Grab all enemy moves.
    - If the king has a place to run that’s not attacked? Not checkmate.

3. Can we capture the attacker?
    - Identify which enemy piece(s) are putting the king in check.
    - If there’s just one, see if any of our pieces can take it out.
    - If we can kill it? Not checkmate.

4. Can we block the attack path?
    - Only applies to sliding pieces (rook, bishop, queen).
    - Get the spaces between the attacker and our king.
    - If we can move any piece into one of those squares? Not checkmate.

5. If none of the above works…
    - Game Over. That’s checkmate.

I also need to add the game_save logic.

1. Save instance variable grid in Board class which will save all the positions of every piece on the board.
2. Save who's turn it is.
3. Convert game saving information using json.
4. Prompt the player with a save option when quitting the game.
5. Prompt the player with a load option when starting the game.
6. Convert saved game information from json back into game variables.
