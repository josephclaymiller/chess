# encoding: utf-8
class Queen < SlidingPiece
  def piece_sym
    {:white => '♕', :black => '♛'}
  end

  def move_dirs
    :all
  end
end