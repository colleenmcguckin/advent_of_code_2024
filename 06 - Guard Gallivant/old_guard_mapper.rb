require "pry"

class GuardMapper
  attr_reader :map
  OBSTACLE = "#"
  GUARD = {
    "^" => :up,
    ">" => :right,
    "v" => :down,
    "<" => :left
  }
  OPEN = "."
  PATH = "X"
  def initialize(path_to_input_file)
    @map = File.read(path_to_input_file).split("\n").map(&:chars)
  end

  def draw_guard_path
    on_map = true
    
    while on_map do
      @map.map { |r| p r }
      direction = GUARD[@map.find { |r| r.find { |c| GUARD.keys.include?(c) } }.reject { |c| [OPEN, OBSTACLE, PATH].include?(c) }.first]
      current_guard = GUARD.invert[direction]
      next_guard = next_guard(current_guard)
      @map = @map.transpose.map(&:reverse) if [:up, :down].include?(direction)
      guard_row = @map.find { |r| r.find { |c| c == current_guard } }
      split_guard_row = guard_row.chunk_while { |_, j| j == OPEN }.to_a
      guard_segment = split_guard_row.find { |segment| segment.any? { |c| c == current_guard } }
      guard_segment_index = split_guard_row.find_index(guard_segment)
      transposed_guard_segment = Array.new(guard_segment.size.pred, PATH).append(next_guard)
      split_guard_row[guard_segment_index] = transposed_guard_segment
      transposed_guard_row = split_guard_row.join.chars
      
      if transposed_guard_row.last == next_guard
        transposed_guard_row[transposed_guard_row.find_index(next_guard)] = PATH
        @map[@map.find_index(guard_row)] = transposed_guard_row
        turn!
        on_map = false
      else
        @map[@map.find_index(guard_row)] = transposed_guard_row
        turn!
      end
      puts "--------------------------------"
    end
    @map.map { |r| p r }
  end

  def turn!
    @map = @map.transpose.map(&:reverse)
  end

  def next_guard(current_guard)
    case current_guard
    when GUARD.invert[:up]
      GUARD.invert[:right]
    when GUARD.invert[:right]
      GUARD.invert[:down]
    when GUARD.invert[:down]
      GUARD.invert[:left]
    when GUARD.invert[:left]
      GUARD.invert[:up]
    end
  end
end

guard_mapper = GuardMapper.new("test_input.txt").draw_guard_path

