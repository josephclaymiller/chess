# encoding: utf-8
class King < SteppingPiece
  def piece_sym
    {:white => '♔', :black => '♚'}
  end

  def move_offsets
    [[1,1],[1,0],[1,-1],[0,1],[0,-1],[-1,1],[-1,0],[-1,-1]]


  end


end