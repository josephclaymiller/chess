# encoding: utf-8
class Knight < SteppingPiece
  def piece_sym
    {:white => '♘', :black => '♞'}
  end

  def move_offsets
    [[2,1],[2,-1],[-2,1],[-2,-1],[1,2],[1,-2],[-1,2],[-1,-2]]
  end

end