require "pry"

class PatrolMap
  PATH = "X"
  OBSTACLE = "#"
  OPEN = "."
  NEW_OBSTACLE = "O"
  PREVIEW_PATH_VERTICAL = "|"
  PREVIEW_PATH_HORIZONTAL = "-"
  PREVIEW_PATH_TURN = "+"
  PATH_CHARS = [PATH, PREVIEW_PATH_VERTICAL, PREVIEW_PATH_HORIZONTAL, PREVIEW_PATH_TURN]

  attr_reader :guard, :trap, :patrol_map

  def initialize(map:, preview: false, debug: false)
    @patrol_map = map
    @preview = preview
    @debug = debug
    print_map if @debug
    @guard = Guard.new(char: find_guard_char, x: guard_row.find_index(find_guard_char), y: @patrol_map.find_index(guard_row))
  end

  def self.initialize_from_file(filepath:, preview: false, debug: false)
    new(map: File.read(filepath).split("\n").map(&:chars), preview:, debug:)
  end

  def patrol!
    counter = 0
    loop do
      on_map = !!guard_row
      puts "on map: #{on_map}"
      break unless on_map
      counter += 1
      move_guard!
      guard_char = @preview ? PREVIEW_PATH_TURN : @guard.char
      @guard.log_move!(x: guard_row.find_index(guard_char), y: @patrol_map.find_index(guard_row))
      if @guard.trapped?
        # binding.pry
        @trap = true
        puts "trap!"
        print_map
        break
      end

      @guard.turn!
      puts "count: #{counter}"
      print_map if @debug
    end
    @patrol_map
  end

  def distinct_patrol_positions
    @patrol_map.flatten.select { |p| PATH_CHARS.include?(p) }
  end

  private

  def find_guard_char
    guard_row.find { |c| Guard.is_guard?(c) }
  end

  def guard_row
    @patrol_map.find { |r| r.find { |c| Guard.is_guard?(c) } }
  end

  def move_guard!
    transpose_map
    split_guard_row = guard_row.dup.chunk_while { |j| [OPEN, *PATH_CHARS].include?(j) }.to_a
    guard_segment = split_guard_row.find { |segment| segment.any? { |c| [@guard.char, PREVIEW_PATH_TURN].include?(c) } }
    guard_segment_index = split_guard_row.find_index(guard_segment)
    transposed_guard_segment = Array.new(guard_segment.size.pred, path_char).append(@guard.next_guard.char)
    transposed_guard_segment[0] = PREVIEW_PATH_TURN if @preview
    split_guard_row[guard_segment_index] = transposed_guard_segment
    transposed_guard_row = split_guard_row.join.chars
    if transposed_guard_row.last == @guard.next_guard.char
      transposed_guard_row[transposed_guard_row.find_index(@guard.next_guard.char)] = path_char
    end
    @patrol_map[@patrol_map.find_index(guard_row)] = transposed_guard_row

    transpose_map(undo: true)
  end

  def transpose_map(undo: false)
    @patrol_map = case @guard.direction
    when :up
      @patrol_map.transpose
    when :down
      undo ? @patrol_map.map(&:reverse).transpose : @patrol_map.transpose.map(&:reverse)
    when :left
      @patrol_map.map(&:reverse)
    when :right
      @patrol_map
    else
      @patrol_map
    end
  end

  def print_map
    @patrol_map.map { |r| p r }
    puts "---" * 10
  end

  def print_moves
    puts "moves: #{@moves}"
    puts "---" * 10
  end

  def path_char
    if @preview
      case @guard.direction
      when :up, :down
        PREVIEW_PATH_VERTICAL
      when :left, :right
        PREVIEW_PATH_HORIZONTAL
      end
    else
      PATH
    end
  end
end

class TrapMapper
  attr_reader :original_map, :generated_maps, :traps

  def initialize(original_map:, debug: false)
    puts "initializing trap mapper"
    @original_map = original_map
    @debug = debug
    @number_of_possible_maps = @original_map.patrol_map.flatten.count { |el| el == PatrolMap::OPEN }
  end

  def generate!
    puts "generating #{@number_of_possible_maps} maps"
    @generated_maps = generate_maps!
    @generated_maps.map(&:patrol!)
    @traps = @generated_maps.select(&:trap)
  end

  def generate_maps!
    @original_map.patrol_map.map.with_index do |row, row_index|
      row.map.with_index do |position, position_index|
        puts "#{row_index} #{position_index}"
        next if PatrolMap::OBSTACLE == position
        next if Guard.is_guard?(position)
        new_map = @original_map.patrol_map.map(&:dup)
        new_map[row_index][position_index] = PatrolMap::NEW_OBSTACLE
        PatrolMap.new(map: new_map, preview: true, debug: @debug)
      end.compact
    end.compact.flatten(1);
  end
end

class Guard
  attr_reader :char, :direction, :coordinates

  CHAR_DIRECTIONS = {
    "^" => :up,
    ">" => :right,
    "v" => :down,
    "<" => :left
  }
  CHARS = CHAR_DIRECTIONS.keys
  Coordinates = Struct.new(:x, :y, keyword_init: true)
  Move = Struct.new(:start_coordinates, :end_coordinates, :char, :direction, keyword_init: true)

  def self.is_guard?(char)
    CHARS.include?(char)
  end

  def initialize(char:, x: 0, y: 0, history: Set.new)
    @char = char
    @direction = CHAR_DIRECTIONS[char]
    @history = history
    @coordinates = Coordinates.new(x:, y:)
  end

  def log_move!(x:, y:)
    unless @history.add?(Move.new(start_coordinates: @coordinates, end_coordinates: Coordinates.new(x:, y:), char: @char, direction: @direction))
      @trapped = true
    end
  end

  def turn!
    @direction = next_guard.direction.clone
    @char = next_guard.char.clone
  end

  def next_guard
    Guard.new(char: next_char, history: @history)
  end

  def trapped?
    @trapped
  end

  private

  def next_char
    CHARS.rotate(CHARS.find_index(@char))[1]
  end

  def next_direction
    CHAR_DIRECTIONS[next_char]
  end
end

# patrol_map = PatrolMap.initialize_from_file("input.txt", true);
# patrol_map.patrol!
# p patrol_map.distinct_patrol_positions.count

DEBUG = false
patrol_map = PatrolMap.initialize_from_file(filepath: "test_input.txt", debug: DEBUG)
trap_generator = TrapMapper.new(original_map: patrol_map, debug: DEBUG)
trap_generator.generate!
traps = trap_generator.traps
# traps.map { |trap| trap.patrol_map.map { |row| p row }; puts "***" * 10 }
p traps.count
