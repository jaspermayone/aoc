# frozen_string_literal: true

grid = File.readlines('input.txt', chomp: true).map(&:chars)

# puts grid.inspect
grid.each { |row| puts row.join }

ROWS = grid.length
COLS = grid.first.length
split_count = 0

start_row = nil
start_col = nil

grid.each_with_index do |row, r|
  c = row.index('S')
  next unless c

  start_row = r
  start_col = c
  break
end

active = [[start_row, start_col]]

def in_bounds?(r, c, rows, cols)
  r >= 0 && r < rows && c >= 0 && c < cols
end

def render_with_beams(grid, beam_positions)
  canvas = grid.map(&:dup)
  beam_positions.each do |(r, c)|
    next unless in_bounds?(r, c, grid.length, grid.first.length)

    # don't overwrite splitters or S; overlay a beam if it's empty
    canvas[r][c] = '|' if canvas[r][c] == '.'
  end
  canvas.map(&:join).join("\n")
end

# Simulation loop:
# Advance all beams one row down at a time. Splitting happens when a beam's next cell is '^'.
while active.any?
  next_active = []

  active.each do |(r, c)|
    nr = r + 1
    nc = c

    # off-grid → beam disappears
    next unless in_bounds?(nr, nc, ROWS, COLS)

    cell = grid[nr][nc]

    if cell == '.'
      # continue downward
      next_active << [nr, nc]
    elsif cell == '^'
      # split: count and create left/right new beams
      split_count += 1

      left_c = nc - 1
      right_c = nc + 1

      # New beams start at the splitter row, left/right of '^'
      next_active << [nr, left_c] if in_bounds?(nr, left_c, ROWS, COLS)
      next_active << [nr, right_c] if in_bounds?(nr, right_c, ROWS, COLS)
      # The original beam is stopped (not added)
    else
      # Any other character (including 'S') treated as empty traversal
      next_active << [nr, nc]
    end
  end

  # Optional dedupe to avoid explosion when multiple beams converge
  next_active = next_active.uniq

  puts render_with_beams(grid, next_active)
  puts

  active = next_active
end

puts "Total splits: #{split_count}"
