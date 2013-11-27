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
