# frozen_string_literal: true

points = File.readlines('input.txt', chomp: true).map { |l| l.split(',').map!(&:to_i) }
n = points.length
raise 'Need at least 2 points' if n < 2

class DSU
  attr_reader :components

  def initialize(n)
    @parent = (0...n).to_a
    @rank = Array.new(n, 0)
    @size = Array.new(n, 1)
    @components = n
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

    @components -= 1
    true
  end
end

def dist2(a, b)
  dx = a[0] - b[0]
  dy = a[1] - b[1]
  dz = a[2] - b[2]
  dx*dx + dy*dy + dz*dz
end

# Build all pairwise edges with deterministic tiebreak (distance, i, j)
edges = []
(0...n).each do |i|
  (i+1...n).each do |j|
    edges << [dist2(points[i], points[j]), i, j]
  end
end
edges.sort_by! { |d, i, j| [d, i, j] }

dsu = DSU.new(n)

last_i = nil
last_j = nil

edges.each do |d, i, j|
  if dsu.union(i, j)
    last_i = i
    last_j = j
    break if dsu.components == 1
  end
end

# Safety: if components > 1 here, graph wasn’t fully connected by edges (shouldn’t happen)
if last_i.nil? || last_j.nil?
  abort 'Could not connect all points into one circuit.'
end

x1 = points[last_i][0]
x2 = points[last_j][0]
puts x1 * x2
