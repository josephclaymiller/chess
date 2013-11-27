# encoding: utf-8
class Pawn < Piece
  def piece_sym
    {:white => '♙', :black => '♟'}
  end

  def initialize(position, color, board)
    super(position, color, board)
    case self.color
    when :white
      @start_row = 6
      @offset = [-1, 0]
      @attack_offsets = [[-1,1],[-1,-1]]
    when :black
      @start_row = 1
      @offset = [1, 0]
      @attack_offsets = [[1,1],[1,-1]]
    end
  end

  def moves
    moves = []
    new_spot = [self.position[0] + @offset[0], self.position[1] + @offset[1]]
    moves << new_spot if @board.grid[new_spot[0]][new_spot[1]].nil?
    if self.position[0] == @start_row
      second_new_spot = [self.position[0] + (@offset[0]*2), self.position[1] + (@offset[1]*2)]
      moves << second_new_spot if @board.grid[second_new_spot[0]][second_new_spot[1]].nil?
    end
    attack_spots = @attack_offsets.map do |attack_offset|
      [self.position[0] + attack_offset[0], self.position[1] + attack_offset[1]]
    end
    case @color
    when :white
      @board.black_pieces.each do |p|
        moves << p.position if attack_spots.include?(p.position)
      end
    when :black
      @board.white_pieces.each do |p|
        moves << p.position if attack_spots.include?(p.position)
      end
    end

    moves
  end
end

