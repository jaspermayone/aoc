# frozen_string_literal: true

def parse_machines(path)
  File.readlines(path, chomp: true).map do |line|
    match = line.match(/\[(?<lights>[.#]+)\]\s+(?<buttons>(\(\d+(?:,\d+)*\)\s*)+)\s+\{(?<jolts>\d+(?:,\d+)*)\}/)
    raise "Invalid line format: #{line}" unless match

    buttons = match[:buttons].scan(/\((\d+(?:,\d+)*)\)/).map { |group| group.first.split(',').map(&:to_i) }
    jolts = match[:jolts].split(',').map(&:to_i)
    [buttons, jolts]
  end
end

def build_system_jolts(buttons, jolts)
  m = jolts.length
  n = buttons.length
  b = Array.new(m) { Array.new(n, 0) }
  buttons.each_with_index do |indices, j|
    indices.each do |i|
      raise "Button index #{i} out of range for #{m} counters" if i.negative? || i >= m

      b[i][j] = 1
    end
  end
  [b, jolts]
end

def component_decomposition(b, t)
  m = b.length
  n = b[0].length
  # Build bipartite graph: counters 0..m-1, buttons m..m+n-1
  visited = Array.new(m + n, false)
  adj = Array.new(m + n) { [] }
  m.times do |i|
    n.times do |j|
      if b[i][j].positive?
        adj[i] << (m + j)
        adj[m + j] << i
      end
    end
  end
  comps = []
  (0...(m + n)).each do |v|
    next if visited[v]

    # skip isolated vertices with zero demand & no edges
    if v < m
      next if t[v].zero? && adj[v].empty?
    elsif adj[v].empty?
      next
    end
    # BFS
    queue = [v]
    visited[v] = true
    counters = []
    buttons = []
    while (u = queue.shift)
      if u < m
        counters << u
      else
        buttons << (u - m)
      end
      adj[u].each do |w|
        next if visited[w]

        visited[w] = true
        queue << w
      end
    end
    comps << [counters, buttons]
  end
  comps
end

def solve_component(b_full, t_full, counters, buttons)
  m = counters.length
  n = buttons.length
  b = Array.new(m) { Array.new(n, 0) }
  t = Array.new(m, 0)
  m.times do |ii|
    t[ii] = t_full[counters[ii]]
    n.times { |jj| b[ii][jj] = b_full[counters[ii]][buttons[jj]] }
  end

  return 0 if t.all?(&:zero?)

  # Build augmented matrix [B | t] and solve using Gaussian elimination
  # We want to minimize sum(x) subject to B*x = t, x >= 0

  # Convert to rational arithmetic for exact computation
  aug = Array.new(m) { |i| Array.new(n + 1) { |j| j < n ? Rational(b[i][j]) : Rational(t[i]) } }

  # Gaussian elimination to row echelon form
  pivot_cols = []
  row = 0
  n.times do |col|
    # Find pivot
    pivot = (row...m).find { |r| aug[r][col] != 0 }
    next unless pivot

    # Swap rows
    aug[row], aug[pivot] = aug[pivot], aug[row]

    # Scale pivot row
    scale = aug[row][col]
    (col..n).each { |j| aug[row][j] /= scale }

    # Eliminate other rows
    m.times do |r|
      next if r == row || aug[r][col].zero?
      factor = aug[r][col]
      (col..n).each { |j| aug[r][j] -= factor * aug[row][j] }
    end

    pivot_cols << col
    row += 1
    break if row >= m
  end

  # Check for inconsistency
  (row...m).each do |r|
    if aug[r][n] != 0 && aug[r][0...n].all?(&:zero?)
      raise 'Inconsistent system'
    end
  end

  # Free variables are columns not in pivot_cols
  free_cols = (0...n).to_a - pivot_cols

  # Express pivot variables in terms of free variables
  # x[pivot_cols[i]] = aug[i][n] - sum(aug[i][free_col] * x[free_col])

  # If no free variables, solution is unique
  if free_cols.empty?
    x = Array.new(n, Rational(0))
    pivot_cols.each_with_index do |col, i|
      x[col] = aug[i][n]
    end
    return nil if x.any?(&:negative?) || x.any? { |v| v.denominator != 1 }
    return x.map(&:to_i).sum
  end

  # Exhaustive enumeration with early termination
  best = Float::INFINITY
  max_val = t.max

  check_solution = lambda do |free_vals|
    x = Array.new(n, Rational(0))
    free_cols.each_with_index { |f, i| x[f] = Rational(free_vals[i]) }
    pivot_cols.each_with_index do |col, i|
      x[col] = aug[i][n]
      free_cols.each_with_index { |f, j| x[col] -= aug[i][f] * free_vals[j] }
    end
    return nil if x.any?(&:negative?) || x.any? { |v| v.denominator != 1 }
    x.map(&:to_i).sum
  end

  enumerate = lambda do |idx, free_vals|
    return if free_vals.sum >= best # prune if free vars alone exceed best

    if idx == free_cols.size
      total = check_solution.call(free_vals)
      best = total if total && total < best
      return
    end

    (0..max_val).each do |val|
      enumerate.call(idx + 1, free_vals + [val])
    end
  end

  if free_cols.size <= 3
    enumerate.call(0, [])
  else
    # For many free variables, use random sampling + local search
    1000.times do
      vals = free_cols.map { rand(0..max_val) }
      total = check_solution.call(vals)
      best = total if total && total < best
    end
  end

  raise "No solution found (m=#{m}, n=#{n}, free=#{free_cols.size})" if best.infinite?
  best
end

def solve_factory_part2(path)
  machines = parse_machines(path)
  total = 0
  per = []

  machines.each do |(buttons, jolts)|
    b, t = build_system_jolts(buttons, jolts)
    comps = component_decomposition(b, t)
    presses_sum = 0
    comps.each do |counters, btns|
      presses_sum += solve_component(b, t, counters, btns)
    end
    per << presses_sum
    total += presses_sum
  end

  { per_machine: per, total: total }
end

if __FILE__ == $PROGRAM_NAME
  input_path = ARGV[0] || 'input.txt'
  result = solve_factory_part2(input_path)
  puts "Per-machine minimal joltage presses: #{result[:per_machine].inspect}"
  puts "Total minimal joltage presses: #{result[:total]}"
end
