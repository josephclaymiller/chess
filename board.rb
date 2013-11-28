require 'colorize'
require_relative 'pieces'


class InvalidMoveError < StandardError
end

class Board
  attr_accessor :grid, :white_pieces, :black_pieces

  def initialize(new_board=true)
    @grid = Array.new(8) {Array.new(8) {nil}}
    @turn = :white
    pieces_setup if new_board
  end

  def [](pos)
    @grid[pos[0]][pos[1]]
  end

  def []= (pos, value)
    @grid[pos[0]][pos[1]] = value
  end

  def pieces
    @grid.flatten.compact
  end

  def pieces_by_color(color)
    self.pieces.select do |piece|
      piece.color == color
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

  def formatted_tile(white_color, piece_string = " ")
    if white_color
      (" " + piece_string + " ").black.on_white
    else
      (" " + piece_string + " ").black.on_green
    end
  end

  def to_s
    white_color = true
    board_string = "   A  B  C  D  E  F  G  H \n"
    @grid.each_with_index do |row, row_index|
      row_string = "#{row_index + 1} "
      row.each_with_index do |space, col_index|
        white_color = (row_index + col_index) % 2 == 0
        if space.nil?
          row_string << formatted_tile(white_color)
        else
          row_string << formatted_tile(white_color, space.to_s)
        end
      end
      board_string += (row_string + "\n")
    end
    board_string
  end

  def play
    begin
      until checkmate?
        puts self
        puts "#{@turn} is in check" if in_check?(@turn)
        puts "#{@turn}'s turn"
        make_move
      end
      puts self
      puts "Checkmate. #{@turn} lost."
    rescue InvalidMoveError => error
      puts "#{error}"
      retry
    end
  end


  def make_move
    begin
      # Move piece from
      puts "What is the location of the piece you would like to move?"
      move_from_array = get_position
      piece = self[move_from_array]
      raise InvalidMoveError.new("There is no piece there") if piece.nil?
      unless piece.color == @turn
        raise InvalidMoveError.new("That is not your piece")
      end

      # Move piece to
      puts "What position would you like to move it to?"
      move_to_array = get_position

      move(move_from_array, move_to_array)

    rescue InvalidMoveError => error
      puts "#{error}"
      retry
    end

    change_turn
    true
  end

  def get_position
    move = gets.chomp
    # Row
    move_row_arr = move.scan(/[1-8]/)
    unless move_row_arr.length == 1
      raise InvalidMoveError.new("Please enter a valid row")
    end
    move_row = move_row_arr.first.to_i - 1

    # Col
    move_col_arr = (move.scan(/[a-h]|[A-H]/))
    unless move_col_arr.length == 1
      raise InvalidMoveError.new("Please enter a valid column")
    end
    move_col = move_col_arr.first.downcase.ord - "a".ord
    [move_row, move_col]
  end

  def change_turn
    if @turn == :white
      @turn = :black
    else
      @turn = :white
    end
  end

  def checkmate?
    return false unless self.in_check?(@turn)
    pieces_by_color(@turn).each do |piece|
      return false unless piece.moves.all? do |move|
        piece.move_into_check?(move)
      end
    end
    true
  end

  def move(pos1,pos2)

    piece = self[pos1]

    unless piece.moves.include?(pos2)
      raise InvalidMoveError.new("You cannot move there")
    end
    if piece.move_into_check?(pos2)
      raise InvalidMoveError.new("You cannot move into check!")
    end

    move!(pos1, pos2)
  end

  def move!(pos1, pos2)
    piece = self[pos1]
    piece.position = pos2
    self[pos2] = piece
    self[pos1] = nil
  end

  def dup_board
    board_dup = Board.new(false)
    self.pieces.each do |piece|
      dup_piece = piece.class.new(piece.position.dup, piece.color, board_dup)
      board_dup[piece.position] = dup_piece
    end
    board_dup
  end

  def other_color(color)
    if color == :white
      :black
    else
      :white
    end
  end

  def in_check?(color)
    king_spot = king_pos(color)
    pieces_by_color(other_color(color)).each do |piece|
      return true if piece.moves.include?(king_spot)
    end
    false
  end

  def king_pos(color)
    pieces_by_color(color).each do |piece|
      return piece.position if piece.class == King
    end
  end
end


if __FILE__ == $PROGRAM_NAME
  game = Board.new()
  game.play
end