class ListDiff
  def initialize(path_to_input_file)
    @left = File.read(path_to_input_file).split("\n").map { |line| line.split("   ").first.to_i }.sort
    @right = File.read(path_to_input_file).split("\n").map { |line| line.split("   ").last.to_i }.sort
  end

  def distance
    @left.zip(@right).map { |a, b| (a.to_i - b.to_i).abs }.sum
  end

  def similarity_score
    @left.map { |location_id| @right.count(location_id) * location_id }.sum
  end
end