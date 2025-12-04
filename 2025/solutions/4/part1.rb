# frozen_string_literal: true

grid = File.readlines('logan-input.txt', chomp: true).map(&:chars)
rows = grid.length
cols = rows.zero? ? 0 : grid[0].length

def find_neighbors(grid, row, col)
  directions = [
    [-1, -1], [-1, 0], [-1, 1], # NW, N, NE
    [0, -1], [0, 1], # W,     E
    [1, -1], [1, 0], [1, 1], # SW, S, SE
  ]

  rows = grid.length
  cols = rows.zero? ? 0 : grid[0].length

  result = []
  directions.each do |dr, dc|
    r = row + dr
    c = col + dc
    result << [r, c] if r.between?(0, rows - 1) && c.between?(0, cols - 1)
  end
  result
end

def accessible?(grid, row, col)
  return false unless grid[row][col] == '@'

  neighbors = find_neighbors(grid, row, col)
  count_at = neighbors.count { |r, c| grid[r][c] == '@' }
  count_at < 4
end

accessible_count = 0
rows.times do |r|
  cols.times do |c|
    accessible_count += 1 if accessible?(grid, r, c)
  end
end

# puts grid[0].inspect
puts accessible_count
