# frozen_string_literal: true

grid = File.readlines('input.txt', chomp: true).map(&:chars)
rows = grid.length
cols = rows.zero? ? 0 : grid[0].length

def find_neighbors(grid, row, col)
  directions = [
    [-1, -1], [-1, 0], [-1, 1], # NW, N, NE
    [0, -1],           [0, 1],   # W,     E
    [1, -1], [1, 0], [1, 1],     # SW, S, SE
  ]

  rows = grid.length
  cols = rows.zero? ? 0 : grid[0].length

  directions.each_with_object([]) do |(dr, dc), acc|
    r = row + dr
    c = col + dc
    acc << [r, c] if r.between?(0, rows - 1) && c.between?(0, cols - 1)
  end
end

def accessible?(grid, row, col)
  return false unless grid[row][col] == '@'

  neighbors = find_neighbors(grid, row, col)
  neighbors.count { |r, c| grid[r][c] == '@' } < 4
end

def find_all_accessible(grid)
  rows = grid.length
  cols = rows.zero? ? 0 : grid[0].length
  acc = []
  rows.times do |r|
    cols.times do |c|
      acc << [r, c] if accessible?(grid, r, c)
    end
  end
  acc
end

def print_grid(grid)
  grid.each { |row| puts row.join }
end

total_removed = 0
step = 0

loop do
  to_remove = find_all_accessible(grid)
  break if to_remove.empty?

  step += 1
  puts "Step #{step}: removing #{to_remove.length} rolls"

  to_remove.each do |r, c|
    grid[r][c] = '.'
  end

  total_removed += to_remove.length

  # Optional: visualize recently removed positions with 'x' snapshot
  # Make a snapshot grid to show what changed this step
  snapshot = grid.map(&:dup)
  to_remove.each { |r, c| snapshot[r][c] = 'x' }
  print_grid(snapshot)
  puts
end

puts "Total removed: #{total_removed}"
puts 'Final state:'
print_grid(grid)
