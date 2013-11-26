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
    case self.move_dirs
    when :diagonal
      build_moves(DIAG_OFFSETS)
    when :straight
      build_moves(STRAIGHT_OFFSETS)
    when :all
      build_moves(STRAIGHT_OFFSETS) + build_moves(DIAG_OFFSETS)
    end
  end

  def build_moves(offsets)
    moves = []

    offsets.each do |offset|
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
  def possible_move(offset)
    [(@position[0] + offset[0]),(@position[1] + offset[1])]
  end

  def moves
    moves = []
    self.move_offsets.each do |offset|
      new_move = possible_move(offset)
      moves << new_move if self.is_valid?(new_move)
    end
    moves
  end


end

class King < SteppingPiece
  def move_offsets
    [[1,1],[1,0],[1,-1],[0,1],[0,-1],[-1,1],[-1,0],[-1,-1]]
  end


end

class Knight < SteppingPiece
  def move_offsets
    [[2,1],[2,-1],[-2,1],[-2,-1],[1,2],[1,-2],[-1,2],[-1,-2]]
  end

end

class Pawn < Piece
  attr_accessor :moved

  def initialize
    super
    @moved = false

    case self.color
    when :white
       @offset = [1, 0]
       @attack_offsets = [[1,1],[1,-1]]
    when :black
       @offset = [-1, 0]
       @attack_offsets = [[-1,1],[-1,-1]]
    end
  end

  def moved?
    @moved
  end

  def moves
    moves = []
    moves << [self.position[0] + @offset[0], self.position[1] + @offset[1]]
    unless moved?
      moves << [self.position[0] + (@offset[0]*2), self.position[1] + (@offset[1]*2)]
    end
    attack_spots = @attack_offsets.map do |attack_offset|
      [self.position[0] + attack_offset[0], self.position[1] + attack_offset[1]]
    end
    case @color
    when :white
      @board.black_pieces.each do |p|
        moves << p.position if attack_spots.include?(p.position)
      end
    when :black
      @board.white_pieces.each do |p|
        moves << p.position if attack_spots.include?(p.position)
      end
    end

    moves
  end
end

