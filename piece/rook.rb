# encoding: utf-8

class Rook < SlidingPiece
  def piece_sym
    {:white => '♖', :black => '♜'}
  end

  def move_dirs
    :straight
  end
end