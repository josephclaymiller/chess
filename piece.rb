# require './board.rb'

class Piece
  attr_accessor :position
  attr_reader :color

  def initialize(position, color, board)
    @position = position
    @color = color
    @board = board
  end

  def moves
    raise "No method error"
  end

  def is_valid?(new_move)
    return false unless new_move.all? {|pos| pos >= 0 && pos < 8 }
    case @color
    when :white
      @board.white_pieces.none? {|white_piece| white_piece.position == new_move}
    when :black
      @board.black_pieces.none? {|black_piece| black_piece.position == new_move}
    end
  end

end

class SlidingPiece < Piece
  DIAG_OFFSETS = [[1,1],[1,-1],[-1,1],[-1,-1]]
  STRAIGHT_OFFSETS = [[1,0],[-1,0],[0,1],[0,-1]]

  def moves
    moves = []
    direction = self.move_dirs
    case direction
    when direction == :diagonal
      self.diag_moves
    when direction == :straight
      self.straight_moves
    when direction == :all
      self.straight_and_diag_moves
    end
  end

  def straight_and_diag_moves
    self.diag_moves + self.straight_moves
  end

  def diag_moves
    moves = []

    DIAG_OFFSETS.each do |offset|
      moves += self.possible_moves(offset)
    end
      moves
  end

  def straight_moves
    moves = []

    STRAIGHT_OFFSETS.each do |offset|
      moves += self.possible_moves(offset)
    end
    moves
  end

  def possible_moves(offset)
    moves = []
    new_move = [(@position[0] + offset[0]),(@position[1] + offset[1])]
    while self.is_valid?(new_move)
      moves << new_move
      new_move = [(new_move[0] + offset[0]),(new_move[1] + offset[1])]
    end
    moves
  end


end

class Bishop < SlidingPiece
  def move_dirs
    :diagonal
  end
end

class Rook < SlidingPiece
  def move_dirs
    :straight
  end
end

class Queen < SlidingPiece
  def move_dirs
    :all
  end
end


class SteppingPiece < Piece
  def moves(type)
  end
end

class King < SteppingPiece
  def move_type
    :king
  end

end

class Knight < SteppingPiece
  def move_type
    :knight
  end
end

class Pawn < Piece
end