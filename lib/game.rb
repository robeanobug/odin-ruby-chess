require_relative 'board'
require_relative 'player'

class Game
  def initialize
    @player1 = Player.new("White", :white)
    @player2 = Player.new("Black", :black)
    @current_player = @player1
    @board = Board.new
  end

  def switch_turn
    @current_player = @current_player == @player1 ? @player2 : @player1
  end

  def play
    loop do
      @board.print_board

      # gets input from player
      puts "#{@current_player.name}'s turn, enter your move (e.g. \"e2 e4\" or \"q\" to quit): "
      input = gets.strip
      break if input == "q"

      # converts input to array format, e.g. d7 d6 => [[6, 3], [5, 3]]
      move = @board.parse_move(input)

      # checks to ensure 
      if move.nil? || move.any?(&:nil?)
        puts "Invalid input format. Try again."
        next
      end

      from, to = move

      # Return the piece at a given pos
      piece = @board.get_piece(from)

      if piece.nil?
        puts "There's no piece there. Try again."
        next
      end

      unless piece.color == @current_player.color
        puts "That's the other player's piece. Try again."
        next
      end

      unless @board.move_piece(from, to)
        puts "Invalid move. Try again."
        next
      end

      enemy = @current_player == @player1 ? @player2 : @player1

      if @board.in_check?(enemy.color)
        if @board.checkmate?(enemy.color)
          @board.print_board
          puts "Checkmate! Congrats #{@current_player.name}, you win!"
          break
        else
          puts "#{enemy.color.capitalize} is in check!"
        end
      end

      if @board.checkmate?(@current_player.color)
        puts "Congrats #{@current_player.name}! You are the winner!"
        break
      end

      switch_turn
    end
    puts "Thanks for playing!"
  end
end

game = Game.new
game.play