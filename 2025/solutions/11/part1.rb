# Read all lines from STDIN and build adjacency list
adj = Hash.new { |h, k| h[k] = [] }

ARGF.each_line do |line|
  line = line.strip
  next if line.empty?
  # Example: "bbb: ddd eee"
  name, rest = line.split(':', 2)
  unless rest
    # No outputs; treat as node with no children
    adj[name.strip] = []
    next
  end
  children = rest.strip.split(/\s+/)
  adj[name.strip] = children
end

start = "you"
target = "out"

# Memoization for number of paths from node to target
memo = {}
# Current recursion stack to detect cycles
on_stack = {}

# DFS that returns count of paths from node to target
def count_paths(node, target, adj, memo, on_stack)
  return 1 if node == target
  return 0 unless adj.key?(node) # node not present → dead end
  return memo[node] if memo.key?(node)

  if on_stack[node]
    # Cycle detected within current path; do not count paths through this cycle
    return 0
  end

  on_stack[node] = true
  total = 0
  adj[node].each do |child|
    total += count_paths(child, target, adj, memo, on_stack)
  end
  on_stack.delete(node)

  memo[node] = total
  total
end

paths = count_paths(start, target, adj, memo, on_stack)
puts paths