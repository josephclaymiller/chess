require './piece.rb'

class Board
  attr_accessor :grid, :white_pieces, :black_pieces

  def initialize
    @grid = Array.new(8) {Array.new(8) {nil}}
    @white_pieces = Array.new(16) {nil}
    @black_pieces = Array.new(16) {nil}
  end

end