class HumanPlayer
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def move_input
    positions = []

    puts "#{@name}, what piece would you like to move?"
    puts "Example: A3"
    user_input = gets.chomp.split

    positions << format_move(user_input)

    puts "Where would you like to move it?"
    user_input = gets.chomp.split(",")
    positions << format_move(user_input)
  end

  private
  def format_move(user_input)
    moves = []
    horizontal_directional = ("A".."H").to_a

    user_input.each do |move|
      moves << [(8 - move[1].to_i), horizontal_directional.index(move[0].upcase)]
    end

    moves
  end
end