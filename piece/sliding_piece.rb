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