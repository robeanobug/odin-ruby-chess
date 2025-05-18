require_relative 'board'
require_relative 'player'
require 'yaml'

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

  def save_game(filename = "saved_game.yaml")
    File.open(filename, "w") { |file| file.puts YAML.dump(self) }
    puts "Game saved successfully!"
  end

  def self.load_game(filename = "saved_game.yaml")
    YAML.safe_load(
    File.read("saved_game.yaml"),
    permitted_classes: [Game, Board, Rook, Knight, Bishop, Queen, King, Pawn, Player, Symbol],
    aliases: true
    )
  end

  def play
    loop do
      @board.print_board

      # gets input from player
      puts "#{@current_player.name}'s turn, enter your move (e.g. \"e2 e4\" or \"q\" to quit): "
      input = gets.strip.downcase
      if input == "q"
        puts "Save game before quitting? (y/n): "
        save_input = gets.strip.downcase
        case save_input
        when "y"
          save_game
          break
        when "n"
          puts "Game not saved. Goodbye!"
          break
        else
          puts "Invalid choice. Game will not be saved."
          break
        end
      end

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
          puts "Checkmate! Congrats #{@current_player.name}, you are the winner!"
          break
        else
          puts "#{enemy.color.capitalize} is in check!"
        end
      end

      switch_turn
    end
    puts "Thanks for playing!"
  end
end

puts "Welcome to Chess!"
puts "Type 'l' to load saved game or anything else to start a new one:"
choice = gets.strip.downcase

game = choice == "l" && File.exist?("saved_game.yaml") ? Game.load_game : Game.new
game.play