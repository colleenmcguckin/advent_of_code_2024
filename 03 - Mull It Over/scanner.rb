class Scanner
  MATCH_REGEX = /mul[(]\d+,\d+[)]/
  DISABLE_REGEX = /(?=don't[(][)]).*?(?<=do[(][)])/

  def initialize(path_to_input_file)
    @instructions = File.read(path_to_input_file).gsub(/\s/, "")
    @instructions_to_disable = @instructions.scan(DISABLE_REGEX)
    @instructions_to_disable.each do |instruction|
      @instructions.gsub!(instruction, "")
    end
    @multipliers = @instructions.scan(MATCH_REGEX)
  end

  def multiplied_instructions
    @multipliers.map { |instruction| instruction.scan(/\d+/).map(&:to_i).reduce(:*) }
  end
end

scanner = Scanner.new("input.txt")
puts scanner.multiplied_instructions.sum

