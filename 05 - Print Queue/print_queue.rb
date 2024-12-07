class PrintQueue
  def initialize(path_to_input_file)
    raw_ordering_rules, raw_updates = File.read(path_to_input_file).split("\n\n")
    @ordering_rules = raw_ordering_rules.split("\n").map { |rule| rule.split("|").map(&:to_i) }
    @updates = raw_updates.split("\n").map { |u| u.split(",").map(&:to_i) }
  end

  def valid_middle_pages
    valid_updates.map { |u| u[u.count / 2] }
  end

  def fixed_middle_pages
    fixed_updates.map { |u| u[u.count / 2] }
  end

  private

  def valid_updates
    @updates.select do |update|
      @ordering_rules.select { |rule| update.include?(rule.first) && update.include?(rule.last) }.all? do |rule|
        update.find_index(rule.first) < update.find_index(rule.last)
      end
    end
  end

  def fixed_updates
    invalid_updates = @updates - valid_updates
    invalid_updates.each do |update|
      is_valid = false
      while !is_valid do
        @ordering_rules.select { |rule| update.include?(rule.first) && update.include?(rule.last) }.sort_by { |rule| [-rule.first, -rule.last] }.each do |rule|
          first_index = update.find_index(rule.first)
          last_index = update.find_index(rule.last)
          if last_index < first_index
            update[first_index], update[last_index] = update[last_index], update[first_index]
          else
            update[first_index], update[last_index] = update[first_index], update[last_index]
          end

          is_valid = @ordering_rules.select { |rule| update.include?(rule.first) && update.include?(rule.last) }.all? do |rule|
            update.find_index(rule.first) < update.find_index(rule.last)
          end
        end
      end
    end
  end
end

print_queue = PrintQueue.new("input.txt")
# p print_queue.valid_middle_pages.sum
p print_queue.fixed_middle_pages.sum