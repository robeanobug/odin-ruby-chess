require_relative 'piece'

class Board
  attr_accessor :grid

  def initialize
    @grid = Array.new(8) { Array.new(8, " ") }
    setup_pieces
  end

  def setup_pieces
    # Black back row
    @grid[0] = [
      Rook.new(:black),
      Knight.new(:black),
      Bishop.new(:black),
      Queen.new(:black),
      King.new(:black),
      Bishop.new(:black),
      Knight.new(:black),
      Rook.new(:black)
    ]
    @grid[1] = Array.new(8) { Pawn.new(:black) }

    # White pawns and back row
    @grid[6] = Array.new(8) { Pawn.new(:white) }
    @grid[7] = [
      Rook.new(:white),
      Knight.new(:white),
      Bishop.new(:white),
      Queen.new(:white),
      King.new(:white),
      Bishop.new(:white),
      Knight.new(:white),
      Rook.new(:white)
    ]
  end

  def print_board
    letters = ('a'..'h').to_a
    separator = "  |---+---+---+---+---+---+---+---|"

    puts "\n"

    puts "    " + letters.join("   ")
    puts separator

    (0..7).each do |i|
      rank = i + 1
      row = @grid[i].map do |cell|
        " #{cell == " " || cell.nil? ? " " : cell.symbol} "
      end.join("|")
      puts "#{rank} |" + row + "| #{rank}"
      puts separator
    end
    puts "    " + letters.join("   ")
    puts "\n"
  end

  def parse_move(input)
    from_str, to_str = input.strip.downcase.split
    raise "Invalid input format" if from_str.nil? || to_str.nil?
  
    from = pos_to_indices(from_str)
    to = pos_to_indices(to_str)
    raise "Invalid position" if from.nil? || to.nil?
  
    [from, to]
  rescue => e
    puts "Invalid input: #{e.message}"
    nil
  end

  def pos_to_indices(pos)
    return nil if pos.length != 2

    letter, rank = pos[0], pos[1].to_i
    row = rank - 1
    col = ("a".."h").to_a.index(letter)

    return nil if row.nil? || col.nil? || row < 0 || row > 7 || col < 0 || col > 7

    [row, col]
  end

  def move_piece(from_pos, to_pos)
    from_row, from_col = from_pos
    to_row, to_col = to_pos

    piece = @grid[from_row][from_col]
    return false if piece.nil?

    valid_moves = piece.valid_moves([from_row, from_col], self)
    return false unless valid_moves.include?([to_row, to_col])

    @grid[from_row][from_col] = " "
    @grid[to_row][to_col] = piece
    true
  end

  def empty?(pos)
    row, col = pos
    return false unless on_board?(pos)
    cell = @grid[row][col]
    cell.nil? || cell == " "
  end
  
  def enemy_at?(pos, color)
    row, col = pos
    piece = @grid[row][col]
    piece.is_a?(Piece) && piece.color != color
  end
  
  def on_board?(pos)
    row, col = pos
    row.between?(0, 7) && col.between?(0, 7)
  end

  def get_piece(pos)
    row, col = pos
    @grid[row][col]
  end

  def find_king(color)
    @grid.each_with_index do |row, r|
      row.each_with_index do |piece, c|
        return [r, c] if piece.is_a?(King) && piece.color == color
      end
    end
    nil
  end

  def in_check?(color)
    king_pos = find_king(color)
    enemy_color = color == :white ? :black : :white
  
    # Go through all enemy pieces
    @grid.flatten.each do |piece|
      next unless piece.is_a?(Piece) && piece.color == enemy_color
    
      piece_pos = find_piece_position(piece)
      return true if piece.valid_moves(piece_pos, self).include?(king_pos)
    end
    false
  end
  
  def find_piece_position(piece)
    @grid.each_with_index do |row, r|
      row.each_with_index do |p, c|
        return [r, c] if p == piece
      end
    end
  end

  # def checkmate?(color)
  #   puts "Is #{color} in check? #{in_check?(color)}"
  #   return false unless in_check?(color)
  
  #   # For all pieces of the player
  #   @grid.flatten.each do |piece|
  #     next if piece == " " || piece.nil? || piece.color != color
    
  #     from = find_piece_position(piece)
  #     puts "Testing moves for #{piece.class} at #{from}:"
  #     piece.valid_moves(from, self).each do |to|
  #       puts "Trying move to #{to}"
  #       dup_board = self.dup
  #       dup_board.move_piece(from, to)
  #       puts "Still in check after move? #{dup_board.in_check?(color)}"
  #       return false unless dup_board.in_check?(color)
  #     end
  #   end
  #   puts "Checkmate detected for #{color}"
  #   true
  # end
end

