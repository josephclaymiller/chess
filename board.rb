require './piece.rb'

class Board
  attr_accessor :grid, :white_pieces, :black_pieces

  def initialize
    @grid = Array.new(8) {Array.new(8) {nil}}
    @white_pieces = Array.new(16) {nil}
    @black_pieces = Array.new(16) {nil}
    pieces_setup
  end

  def pieces_setup
    royalty_setup(:black)
    royalty_setup(:white)
    pawn_setup(:black)
    pawn_setup(:white)
  end

  def royalty_setup(c)
    row = (c == :black ? 0 : 7)
    @grid[row][3] = Queen.new([row, 3], c, self)
    @grid[row][4] = King.new([row, 4], c, self)
    @grid[row][2] = Bishop.new([row, 2], c, self)
    @grid[row][5] = Bishop.new([row, 5], c, self)
    @grid[row][1] = Knight.new([row, 1], c, self)
    @grid[row][6] = Knight.new([row, 6], c, self)
    @grid[row][0] = Rook.new([row, 0], c, self)
    @grid[row][7] = Rook.new([row, 7], c, self)
  end

  def pawn_setup(c)
    row = (c == :black ? 1 : 6)
    8.times do |col|
      @grid[row][col] = Pawn.new([row, col], c, self)
    end
  end

  def to_s
    board_string = ""
    @grid.each do |row|
      row_string = ""
      row.each do |space|
        if space.nil?
          row_string << "_"
        else
          row_string << space.to_s
        end
        row_string << " "
      end
      board_string += (row_string + "\n")
    end
    board_string
  end

end