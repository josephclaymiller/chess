# encoding: utf-8

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

  def to_s
    "#{self.piece_sym[self.color]}"
  end

  def is_valid?(new_move, old_move = self.position)
    return false unless new_move.all? {|pos| pos >= 0 && pos < 8 }
    case @color
    when :white
      return false if @board.black_pieces.any? {|p| p.position == old_move}
      return false unless @board.white_pieces.none? do |white_piece|
        white_piece.position == new_move
      end
    when :black
      return false if @board.white_pieces.any? do |p|
        p.position == old_move
      end
      return false unless @board.black_pieces.none? do |black_piece|
        black_piece.position == new_move
      end
    end
    true
  end

  def move_into_check?(target_pos)
    next_move_board = @board.dup_board
    current_pos = self.position
    next_move_board.move!(current_pos, target_pos)
    next_move_board.in_check?(self.color)
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
    old_move = self.position
    while self.is_valid?(new_move,old_move)
      moves << new_move
      old_move = new_move
      new_move = [(old_move[0] + offset[0]),(old_move[1] + offset[1])]
    end
    moves
  end


end

class Bishop < SlidingPiece
  def piece_sym
    {:white => '♗', :black => '♝'}
  end

  def move_dirs
    :diagonal
  end
end

class Rook < SlidingPiece
  def piece_sym
    {:white => '♖', :black => '♜'}
  end

  def move_dirs
    :straight
  end
end

class Queen < SlidingPiece
  def piece_sym
    {:white => '♕', :black => '♛'}
  end

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
  def piece_sym
    {:white => '♔', :black => '♚'}
  end

  def move_offsets
    [[1,1],[1,0],[1,-1],[0,1],[0,-1],[-1,1],[-1,0],[-1,-1]]


  end


end

class Knight < SteppingPiece
  def piece_sym
    {:white => '♘', :black => '♞'}
  end

  def move_offsets
    [[2,1],[2,-1],[-2,1],[-2,-1],[1,2],[1,-2],[-1,2],[-1,-2]]
  end

end

class Pawn < Piece
  def piece_sym
    {:white => '♙', :black => '♟'}
  end

  def initialize(position, color, board)
    super(position, color, board)
    case self.color
    when :white
      @start_row = 6
      @offset = [-1, 0]
      @attack_offsets = [[-1,1],[-1,-1]]
    when :black
      @start_row = 1
      @offset = [1, 0]
      @attack_offsets = [[1,1],[1,-1]]
    end
  end

  def moves
    moves = []
    new_spot = [self.position[0] + @offset[0], self.position[1] + @offset[1]]
    moves << new_spot if @board.grid[new_spot[0]][new_spot[1]].nil?
    if self.position[0] == @start_row
      second_new_spot = [self.position[0] + (@offset[0]*2), self.position[1] + (@offset[1]*2)]
      moves << second_new_spot if @board.grid[second_new_spot[0]][second_new_spot[1]].nil?
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

