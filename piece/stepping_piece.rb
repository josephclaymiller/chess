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