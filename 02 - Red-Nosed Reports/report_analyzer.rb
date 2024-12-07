class ReportAnalyzer
  attr_reader :safe_reports, :unsafe_reports, :problem_dampened_reports

  def initialize(path_to_input_file)
    @reports = File.read(path_to_input_file).split("\n").map { |line| line.split(" ").map(&:to_i) }
  end

  def analyze
    @safe_reports, @unsafe_reports = @reports.partition { |report| is_safe?(report) }
    @safe_reports.concat(@unsafe_reports.select { |report| is_safe_by_problem_dampener?(report) })
  end

  private

  def is_safe?(report)
    is_decreasing_or_increasing?(report) && within_adjacent_diff_range?(report)
  end

  def is_decreasing_or_increasing?(report)
    report.sort == report || report.sort.reverse == report
  end

  def within_adjacent_diff_range?(report)
    report.each_cons(2).all? { |a, b| [1, 2, 3].include?((a - b).abs) }
  end

  def is_safe_by_problem_dampener?(report)
    new_reports = report.map.with_index do |_, index|
      new_report = report.dup
      new_report.delete_at(index)
      new_report
    end

    new_reports.select { |report| is_safe?(report) }.any?
  end
end

analysis = ReportAnalyzer.new("input.txt")
analysis.analyze
p analysis.safe_reports.count