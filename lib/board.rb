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

    moves = piece.valid_moves([from_row, from_col], self)
    return false unless moves.include?([to_row, to_col])

    captured_piece = @grid[to_row][to_col]

    @grid[from_row][from_col] = " "
    @grid[to_row][to_col] = piece

    if in_check?(piece.color)
      @grid[from_row][from_col] = piece
      @grid[to_row][to_col] = captured_piece
      return false
    end
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

  def get_path_to_king(from_pos, to_pos, attacker)
    path = []
  
    return path if attacker.is_a?(Knight) || attacker.is_a?(Pawn)
  
    from_row, from_col = from_pos
    to_row, to_col = to_pos
  
    row_step = (to_row <=> from_row)
    col_step = (to_col <=> from_col)
  
    current_row = from_row + row_step
    current_col = from_col + col_step
  
    while [current_row, current_col] != to_pos
      path << [current_row, current_col]
      current_row += row_step
      current_col += col_step
    end
  
    path
  end

  def simulate_move_and_check(from, to, color)
    from_row, from_col = from
    to_row, to_col = to
  
    piece = @grid[from_row][from_col]
    captured_piece = @grid[to_row][to_col]
  
    @grid[to_row][to_col] = piece
    @grid[from_row][from_col] = " "
  
    in_check = in_check?(color)
  
    @grid[from_row][from_col] = piece
    @grid[to_row][to_col] = captured_piece
  
    !in_check
  end

  def checkmate?(color)
    return false unless in_check?(color)

    king_pos = find_king(color)
    king = get_piece(king_pos)
    king_moves = king.valid_moves(king_pos, self)

    # enemy_color = color == :white ? :black : :white
    enemy_moves = []
    attackers = []

    @grid.flatten.each do |piece|
      next if piece.nil? || piece == ' ' || piece.color == color

      from = find_piece_position(piece)
      piece_moves = piece.valid_moves(from, self)
      enemy_moves.concat(piece_moves)
      attackers << piece if piece_moves.include?(king_pos)
    end
    
    safe_king_moves = king_moves.select do |move|
      simulate_move_and_check(king_pos, move, color)
    end

    # Can the king move to safety?
    return false unless safe_king_moves.empty?

    # Is the king being double attacked?
    # If so we cannot block and/or capture both attackers.
    return true if attackers.length > 1

    attacker = attackers[0]

    attacker_pos = find_piece_position(attacker)
    attack_path = get_path_to_king(attacker_pos, king_pos, attacker)

    @grid.flatten.each do |ally|
      next if ally.nil? || ally == " " || ally.color != king.color
    
      from = find_piece_position(ally)
      ally_moves = ally.valid_moves(from, self)
    
      # Can we capture the attacker?
      return false if ally_moves.include?(attacker_pos)

      # Remove king moves because king can't block his own attack
      ally_moves -= king_moves
    
      # Can we block the attack?
      attack_path.each do |block_square|
        return false if ally_moves.include?(block_square)
      end
    end
    true
  end
end

