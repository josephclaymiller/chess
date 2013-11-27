# encoding: utf-8
class Bishop < SlidingPiece
  def piece_sym
    {:white => '♗', :black => '♝'}
  end

  def move_dirs
    :diagonal
  end
end