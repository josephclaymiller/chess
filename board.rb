require 'colorize'
load 'piece.rb'


class InvalidMoveError < StandardError
end

class Board
  attr_accessor :grid, :white_pieces, :black_pieces

  def initialize(new_board=true)
    @grid = Array.new(8) {Array.new(8) {nil}}
    @turn = :white
    pieces_setup if new_board
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
    white_color = true
    board_string = "   A  B  C  D  E  F  G  H \n"
    @grid.each_with_index do |row, row_index|
      row_string = "#{row_index + 1} "
      row.each_with_index do |space, col_index|
        white_color = (row_index + col_index) % 2 == 0
        if space.nil?
          if white_color
            row_string << "   ".on_white
          else
            row_string << "   ".on_green
          end
        else

          if white_color
            row_string << (" " + space.to_s + " ").black.on_white
          else
            row_string << (" " + space.to_s + " ").black.on_green
          end

        end
        # no spaces between squares
      end
      board_string += (row_string + "\n")
    end
    board_string
  end

  def play
    begin
      while make_move
      end
    rescue InvalidMoveError => error
      puts "#{error}"
      retry
    end
  end


  def make_move
    puts self
    if checkmate?
      puts "Checkmate.  #{@turn} lost."
      return false
    end

    begin
      # Move piece from
      puts "What is the location of the piece you would like to move?"
      move_from_array = get_position
      piece = @grid[move_from_array[0]][move_from_array[1]]
      # No piece there
      raise InvalidMoveError.new("There is no piece there") if piece.nil?
      # Not your piece
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
    if @turn == :white
      self.white_pieces.each do |piece|
        return false unless piece.moves.all? {|move| piece.move_into_check?(move)}
      end
    else
      self.black_pieces.each do |piece|
        return false unless piece.moves.all? {|move| piece.move_into_check?(move)}
      end
    end
    true
  end

  def move(pos1,pos2)

    piece = @grid[pos1[0]][pos1[1]]

    raise InvalidMoveError.new("You cannot move there") unless piece.moves.include?(pos2)
    raise InvalidMoveError.new("You cannot move into check!") if piece.move_into_check?(pos2)
    move!(pos1, pos2)
  end

  def move!(pos1, pos2)
    piece = @grid[pos1[0]][pos1[1]]
    piece.position = pos2
    @grid[pos2[0]][pos2[1]], @grid[pos1[0]][pos1[1]] = piece, nil
  end

  def dup_board
    board_dup = Board.new(false)
    self.grid.each do |row|
      row.each do |piece|
        next unless piece
        dup_piece = piece.class.new(piece.position.dup, piece.color, board_dup)
        board_dup.grid[piece.position[0]][piece.position[1]] = dup_piece
      end
    end
    board_dup
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


if __FILE__ == $PROGRAM_NAME
  game = Board.new()
  game.play
end