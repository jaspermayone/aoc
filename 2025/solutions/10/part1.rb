# frozen_string_literal: true

def parse_machines(path)
  File.readlines(path, chomp: true).map do |line|
    match = line.match(/\[(?<lights>[.#]+)\]\s+(?<buttons>(\(\d+(?:,\d+)*\)\s*)+)\s+\{(?<jolts>\d+(?:,\d+)*)\}/)
    raise "Invalid line format: #{line}" unless match

    lights = match[:lights].chars.map { |c| c == '#' }
    buttons = match[:buttons].scan(/\((\d+(?:,\d+)*)\)/).map { |group| group.first.split(',').map(&:to_i) }
    [lights, buttons]
  end
end

# Build GF(2) system (matrix a, vector b)
def build_system(lights, buttons)
  m = lights.length
  n = buttons.length
  a = Array.new(m) { Array.new(n, 0) }
  b = lights.map { |v| v ? 1 : 0 }

  buttons.each_with_index do |indices, j|
    indices.each do |i|
      raise "Button index #{i} out of range for #{m} lights" if i.negative? || i >= m

      a[i][j] ^= 1
    end
  end

  [a, b]
end

# Gaussian elimination over GF(2): returns [solvable, x0, nullspace]
def gf2_eliminate(a_in, b_in)
  a = a_in.map(&:dup)
  b = b_in.dup
  m = a.length
  n = m.zero? ? 0 : a[0].length

  row = 0
  col = 0
  pivot_rows = Array.new(n, nil)

  while row < m && col < n
    pivot = (row...m).find { |r| a[r][col] == 1 }
    if pivot.nil?
      col += 1
      next
    end

    if pivot != row
      a[row], a[pivot] = a[pivot], a[row]
      b[row], b[pivot] = b[pivot], b[row]
    end

    pivot_rows[col] = row

    (0...m).each do |r|
      next if r == row

      if a[r][col] == 1
        (0...n).each { |c| a[r][c] ^= a[row][c] }
        b[r] ^= b[row]
      end
    end

    row += 1
    col += 1
  end

  (0...m).each do |r|
    return [false, [], []] if a[r].all?(&:zero?) && b[r] == 1
  end

  x0 = Array.new(n, 0)
  pivot_cols = pivot_rows.each_index.reject { |c| pivot_rows[c].nil? }
  free_cols = (0...n).to_a - pivot_cols

  pivot_cols.each do |c|
    r = pivot_rows[c]
    sum = 0
    (0...n).each do |j|
      next if j == c

      sum ^= (a[r][j] & x0[j])
    end
    x0[c] = b[r] ^ sum
  end

  nullspace = []
  free_cols.each do |f|
    v = Array.new(n, 0)
    v[f] = 1
    pivot_cols.each do |c|
      r = pivot_rows[c]
      sum = 0
      (0...n).each do |j|
        next if j == c

        sum ^= (a[r][j] & v[j])
      end
      v[c] = sum
    end
    nullspace << v
  end

  [true, x0, nullspace]
end

def minimize_presses(x0, nullspace)
  k = nullspace.length
  n = x0.length

  best_x = x0.dup
  best_w = x0.count(1)

  if k <= 20
    limit = 1 << k
    (0...limit).each do |mask|
      x = x0.dup
      k.times do |i|
        (0...n).each { |j| x[j] ^= nullspace[i][j] } if (mask & (1 << i)) != 0
      end
      w = x.count(1)
      if w < best_w
        best_w = w
        best_x = x
      end
    end
    [best_x, best_w]
  else
    x = x0.dup
    improved = true
    while improved
      improved = false
      nullspace.each do |v|
        candidate = x.each_with_index.map { |bit, j| bit ^ v[j] }
        if candidate.count(1) < x.count(1)
          x = candidate
          improved = true
        end
      end
    end
    [x, x.count(1)]
  end
end

def solve_factory(path)
  machines = parse_machines(path)
  total = 0
  per = []

  machines.each_with_index do |(lights, buttons), idx|
    a, b = build_system(lights, buttons)
    solvable, x0, nullspace = gf2_eliminate(a, b)
    raise "Machine #{idx + 1} unsolvable" unless solvable

    _x, presses = minimize_presses(x0, nullspace)
    per << presses
    total += presses
  end

  { per_machine: per, total: total }
end

if __FILE__ == $PROGRAM_NAME
  input_path = ARGV[0] || 'input.txt'
  result = solve_factory(input_path)
  puts "Per-machine minimal presses: #{result[:per_machine].inspect}"
  puts "Total minimal presses: #{result[:total]}"
end
