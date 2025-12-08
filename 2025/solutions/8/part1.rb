# frozen_string_literal: true

points = File.readlines('input.txt', chomp: true).map { |l| l.split(',').map!(&:to_i) }
n = points.length
ATTEMPTS = 1000 # use 1000 for the full puzzle, or 10 with test case

class DSU
  def initialize(n)
    @parent = (0...n).to_a
    @rank = Array.new(n, 0)
    @size = Array.new(n, 1)
  end

  def find(x)
    @parent[x] = find(@parent[x]) if @parent[x] != x
    @parent[x]
  end

  def union(a, b)
    ra = find(a)
    rb = find(b)
    return false if ra == rb

    if @rank[ra] < @rank[rb]
      @parent[ra] = rb
      @size[rb] += @size[ra]
    elsif @rank[ra] > @rank[rb]
      @parent[rb] = ra
      @size[ra] += @size[rb]
    else
      @parent[rb] = ra
      @rank[ra] += 1
      @size[ra] += @size[rb]
    end
    true
  end

  def component_sizes
    roots = {}
    (0...@parent.length).each do |i|
      r = find(i)
      roots[r] = @size[r]
    end
    roots.values
  end
end

def dist2(a, b)
  dx = a[0] - b[0]
  dy = a[1] - b[1]
  dz = a[2] - b[2]
  dx*dx + dy*dy + dz*dz
end

edges = []
(0...n).each do |i|
  (i+1...n).each do |j|
    edges << [dist2(points[i], points[j]), i, j]
  end
end
# deterministic tiebreaking
edges.sort_by! { |d, i, j| [d, i, j] }

dsu = DSU.new(n)

attempts = 0
successful = 0
trace = []

edges.each do |d, i, j|
  attempts += 1
  merged = dsu.union(i, j)
  successful += 1 if merged
  trace << { i: i, j: j, d2: d, merged: merged }
  break if attempts == ATTEMPTS
end

sizes = dsu.component_sizes.sort.reverse
sizes.fill(1, sizes.length...3) if sizes.length < 3
answer = sizes[0] * sizes[1] * sizes[2]

puts "points: #{n}, attempts: #{attempts}, successful: #{successful}"
puts "trace (i,j,d2,merged):"
trace.each_with_index do |t, idx|
  puts "#{idx+1}. (#{t[:i]}, #{t[:j]}) d2=#{t[:d2]} merged=#{t[:merged]}"
end
puts "sizes_desc: #{sizes.inspect}"
puts answer
