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

  def other_color
    if @color == :white
      :black
    else
      :white
    end
  end

  def to_s
    "#{self.piece_sym[self.color]}"
  end

  def is_valid?(new_move, old_move = self.position)
    return false unless new_move.all? {|pos| pos >= 0 && pos < 8 }

    return false if @board.pieces_by_color(self.other_color).any? do |p|
      p.position == old_move
    end
    return false unless @board.pieces_by_color(@color).none? do |white_piece|
      white_piece.position == new_move
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
