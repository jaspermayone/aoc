# frozen_string_literal: true

require 'set'

grid = File.readlines('input.txt', chomp: true).map(&:chars)

ROWS = grid.length
COLS = grid.first.length

start_row = nil
start_col = nil
grid.each_with_index do |row, r|
  c = row.index('S')
  next unless c

  start_row = r
  start_col = c
  break
end

def in_bounds?(r, c, rows, cols)
  r >= 0 && r < rows && c >= 0 && c < cols
end

# Just count how many timelines are at each position
current_states = { [start_row, start_col] => 1 }

ROWS.times do
  next_states = Hash.new(0)

  current_states.each do |(r, c), count|
    nr = r + 1
    break if nr >= ROWS
    next unless in_bounds?(nr, c, ROWS, COLS)

    cell = grid[nr][c]

    case cell
    when '.'
      next_states[[nr, c]] += count
    when '^'
      lc = c - 1
      rc = c + 1
      # Each timeline at this position splits into 2
      next_states[[nr, lc]] += count if in_bounds?(nr, lc, ROWS, COLS)
      next_states[[nr, rc]] += count if in_bounds?(nr, rc, ROWS, COLS)
    else
      next_states[[nr, c]] += count
    end
  end

  break if next_states.empty?

  current_states = next_states
end

total_timelines = current_states.values.sum
puts "Total timelines: #{total_timelines}"
