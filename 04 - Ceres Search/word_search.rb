class WordSearch
  SEARCH_WORD = "XMAS".freeze
  CROSS_SEARCH = "MAS".freeze

  def initialize(path_to_input_file)
    @puzzle_grid = File.read(path_to_input_file).split("\n").map(&:chars)
  end

  def count_words
    right_diagonals = right_diagonals(SEARCH_WORD.size)
    left_diagonals = left_diagonals(SEARCH_WORD.size)
    [rows, columns, *right_diagonals, *left_diagonals].map do |puzzle|
      puzzle.map.with_index do |row, i|
        row.each_cons(SEARCH_WORD.size).count { |letters| letters == SEARCH_WORD.chars || letters == SEARCH_WORD.chars.reverse }
      end.sum
    end.sum
  end

  def count_crosses
    right_diagonals = right_diagonals(CROSS_SEARCH.size)
    left_diagonals = left_diagonals(CROSS_SEARCH.size)
    diagonals = right_diagonals.zip(left_diagonals).map { |diagonal| diagonal.map { |d| d.select { |row| row.none?('.') } } }
    diagonals.map do |right_diagonal, left_diagonal|
      right_diagonal.zip(left_diagonal.reverse.map(&:reverse)).count do |cross|
        (cross.first == CROSS_SEARCH.chars || cross.first == CROSS_SEARCH.chars.reverse) && (cross.last == CROSS_SEARCH.chars || cross.last == CROSS_SEARCH.chars.reverse)
      end
    end.sum
  end

  private

  def rows
    @puzzle_grid
  end

  def columns
    @puzzle_grid.transpose
  end

  def right_diagonals(group_size)
    @puzzle_grid.dup.each_cons(group_size).select { |group| group.size == group_size }.map.with_index do |group, i|
      group.map.with_index do |row, j|  
        row.dup.rotate(j).tap { |r| r.pop(j); r.concat(Array.new(j) { '.' }) }
      end
    end.map(&:transpose).compact
  end

  def left_diagonals(group_size)
    @puzzle_grid.dup.each_cons(group_size).select { |group| group.size == group_size }.map.with_index do |group, i|
      group.map.with_index do |row, j|
        row.dup.rotate(-j).reverse.tap { |r| r.pop(j); r.concat(Array.new(j) { '.' }.reverse) }
      end
    end.map(&:transpose).compact
  end
end

word_search = WordSearch.new("input.txt")
p word_search.count_words
p word_search.count_crosses