load 'piece.rb'

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
    board_string = "_ A B C D E F G H \n"
    @grid.each_with_index do |row,index|
      row_string = "#{index + 1} "
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

  def play
    while make_move
    end
  end


  def make_move
    puts self
    if checkmate?
      puts "Checkmate.  #{@turn} lost."
      return false
    end

    begin
      puts "What is the location of the piece you would like to move?"
      move_from = gets.chomp
      move_from_row = move_from.scan(/\d/).first.to_i - 1
      move_from_col = (move_from.scan(/[a-h]|[A-H]/).first.downcase.ord) - "a".ord
      move_from_array = [move_from_row,move_from_col]
      puts "What position would you like to move it to?"
      move_to = gets.chomp
      move_to_row = move_to.scan(/\d/).first.to_i - 1
      move_to_col = (move_to.scan(/[a-h]|[A-H]/).first.downcase.ord) - "a".ord
      move_to_array = [move_to_row,move_to_col]

      move(move_from_array, move_to_array)

    rescue => error
      puts "#{error}"
      retry
    end

    change_turn
    true
  end

  def change_turn
    if @turn == :white
      @turn = :black
    else
      @turn = :white
    end
  end

  def checkmate?
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

    raise "No piece error" if piece.nil?
    raise "That is not your piece" unless piece.color == @turn
    raise "You cannot move there" unless piece.moves.include?(pos2)
    raise "You cannot move into check!" if piece.move_into_check?(pos2)
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