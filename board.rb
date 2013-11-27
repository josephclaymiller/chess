require './piece.rb'

class Board
  attr_accessor :grid, :white_pieces, :black_pieces

  def initialize
    @grid = Array.new(8) {Array.new(8) {nil}}
    @turn = :white
    pieces_setup
    make_move
  end

  def white_pieces
    @grid.flatten.select do |piece|
      piece.color == :white if piece
    end
  end

  def black_pieces
    @grid.flatten.select do |piece|
      piece.color == :black if piece
    end
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


  def make_move
    puts self
    begin
      puts "What is the location of the piece you would like to move?"
      move_from = gets.chomp.scan(/\d/).map {|i| i.to_i}

      puts "What position would you like to move it to?"
      move_to = gets.chomp.scan(/\d/).map {|i| i.to_i}

      move(move_from, move_to)

    rescue => error
      puts "#{error}"
      retry
    end

    change_turn


    #self.make_move

  end

  def change_turn
    if @turn == :white
      @turn = :black
    else
      @turn = :white
    end
  end

  def move(pos1,pos2)
    piece = @grid[pos1[0]][pos1[1]]

    raise "No piece error" if piece.nil?
    raise "That is not your piece" unless piece.color == @turn
    raise "You cannot move there" unless piece.moves.include?(pos2)
    piece.position = pos2
    @grid[pos2[0]][pos2[1]], @grid[pos1[0]][pos1[1]] = piece, nil
  end

  def in_check?(color)
    king_spot = king_pos(color)
    case color
    when :white
      self.black_pieces.each do |piece|
        return true if piece.moves.include?(king_spot)
      end
    when :black
      self.white_pieces.each do |piece|
        return true if piece.moves.include?(king_spot)
      end
    end
    false
  end

  def king_pos(color)
    case color
    when :white
      self.white_pieces.each do |piece|
        return piece.position if piece.class == King
      end
    when :black
      self.black_pieces.each do |piece|
        return piece.position if piece.class == King
      end
    end
  end

end