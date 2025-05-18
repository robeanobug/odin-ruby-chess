class Piece
  attr_reader :color, :symbol, :name

  def initialize(color, symbol, name)
    @color = color
    @symbol = symbol
    @name = name
  end
end



class Pawn < Piece
  def initialize(color)
    super(color, color == :white ? "♙" : "♟", "pawn")
  end

  def valid_moves(pos, board)
    row, col = pos
    moves = []
    direction = color == :white ? -1 : 1
    start_row = color == :white ? 6 : 1

    # one square forward
    one_ahead = [row + direction, col]

    if board.empty?(one_ahead)
      moves << one_ahead

      # 2 squares forward (only if at start)
      two_ahead = [row + 2 * direction, col]
      if row == start_row && board.empty?(two_ahead)
        moves << two_ahead
      end
    end

    # Captures
    [-1, 1].each do |side|
      diag = [row + direction, col + side]

      if board.on_board?(diag) && board.enemy_at?(diag, color)
        moves << diag
      end
    end
    moves
  end
end

class Rook < Piece
  def initialize(color)
    super(color, color == :white ? "♖" : "♜", "rook")
  end

  def valid_moves(pos, board)
    row, col = pos
    moves = []

    directions = [
      [-1, 0], # up
      [1, 0],  # down
      [0, -1], # left
      [0, 1]   # right
    ]

    directions.each do |row_change, col_change|
      r, c = row + row_change, col + col_change

      while board.on_board?([r, c])
        if board.empty?([r, c])
          moves << [r, c]
        elsif board.enemy_at?([r, c], color)
          moves << [r, c]
          break
        else
          break
        end
        r += row_change
        c += col_change
      end
    end
    moves
  end
end

class Knight < Piece
  def initialize(color)
    super(color, color == :white ? "♘" : "♞", "knight")
  end

  def valid_moves(pos, board)
    row, col = pos
    moves = []

    directions = [
    [2, 1],
    [1, 2],
    [-1, 2],
    [-2, 1],
    [-2, -1],
    [-1, -2],
    [1, -2],
    [2, -1]
    ]

    directions.each do |row_change, col_change|
      r, c = row + row_change, col + col_change

      next unless board.on_board?([r, c])
      if board.empty?([r, c]) || board.enemy_at?([r, c], color)
        moves << [r, c]
      end
    end
    moves
  end
end

class Bishop < Piece
  def initialize(color)
    super(color, color == :white ? "♗" : "♝", "bishop")
  end

  def valid_moves(pos, board)
    row, col = pos
    moves = []

    directions = [
      [1, 1],
      [-1, 1],
      [-1, -1],
      [1, -1]
    ]

    directions.each do |row_change, col_change|
      r, c = row + row_change, col + col_change

      while board.on_board?([r, c])
        if board.empty?([r, c])
          moves << [r, c]
        elsif board.enemy_at?([r, c], color)
          moves << [r, c]
        else
          break
        end
        r += row_change
        c += col_change
      end
    end
    moves
  end
end

class Queen < Piece
  def initialize(color)
    super(color, color == :white ? "♕" : "♛", "queen")
  end

  def valid_moves(pos, board)
    row, col = pos
    moves = []

    directions = [
      [1, 0],
      [1, 1],
      [0, 1],
      [-1, 1],
      [-1, 0],
      [-1, -1],
      [0, -1],
      [1, -1]
    ]

    directions.each do |row_change, col_change|
      r, c = row + row_change, col + col_change

      while board.on_board?([r, c])
        if board.empty?([r, c])
          moves << [r, c]
        elsif board.enemy_at?([r, c], color)
          moves << [r, c]
          break
        else
          break
        end
        r += row_change
        c += col_change
      end
    end
    moves
  end
end

class King < Piece
  def initialize(color)
    super(color, color == :white ? "♔" : "♚", "king")
  end

  def valid_moves(pos, board)
    row, col = pos
    moves = []

    directions = [
      [1, 0],
      [1, 1],
      [0, 1],
      [-1, 1],
      [-1, 0],
      [-1, -1],
      [0, -1],
      [1, -1]
    ]

    directions.each do |row_change, col_change|
      r, c = row + row_change, col + col_change

      next unless board.on_board?([r, c])
      if board.empty?([r, c]) || board.enemy_at?([r, c], color)
        moves << [r, c]
      end
    end
    moves
  end
end