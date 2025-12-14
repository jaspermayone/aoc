# frozen_string_literal: true

def log(msg)
  puts msg if DEBUG
end

# Parse input, normalize tokens (strip + downcase)
adj = Hash.new { |h, k| h[k] = [] }

ARGF.each_line do |line|
  line = line.strip
  next if line.empty?

  name, rest = line.split(':', 2)
  name = name.strip.downcase
  children = rest ? rest.strip.split(/\s+/).map { |c| c.strip.downcase } : []
  adj[name] = children
end

start  = 'svr'
target = 'out'
must1  = 'dac'
must2  = 'fft'
required = [must1, must2]

log '=== Parsed Adjacency ==='
adj.each { |k, v| log("#{k}: #{v.join(' ')}") }
log '=== Presence Checks ==='
log "has svr? #{adj.key?(start)}"
log "has out? #{adj.key?(target)} (ok if false; target is treated as terminal)"
log "has dac? #{adj.key?(must1)}"
log "has fft? #{adj.key?(must2)}"

memo = {}
on_stack = {}

def count_paths(node, target, adj, memo, on_stack, seen1, seen2, must1, must2)
  puts "ENTER node=#{node} seen_dac=#{seen1} seen_fft=#{seen2}" if ENV['DEBUG'] == '1'

  # If we've reached target, count based on flags; target may not exist in adj.
  if node == target
    res = seen1 && seen2 ? 1 : 0
    puts "TARGET node=#{node} flags(dac=#{seen1},fft=#{seen2}) -> #{res}" if ENV['DEBUG'] == '1'
    return res
  end

  # For non-target nodes, if node has no outgoing edges and isn't in adj, it's a dead end.
  unless adj.key?(node)
    puts "DEAD node=#{node} not in graph -> 0" if ENV['DEBUG'] == '1'
    return 0
  end

  # Update flags with current node BEFORE memo key
  seen1 ||= (node == must1)
  seen2 ||= (node == must2)
  puts "UPDATE node=#{node} -> seen_dac=#{seen1} seen_fft=#{seen2}" if ENV['DEBUG'] == '1'

  key = [node, seen1, seen2]
  if memo.key?(key)
    puts "MEMO HIT node=#{node} flags(dac=#{seen1},fft=#{seen2}) -> #{memo[key]}" if ENV['DEBUG'] == '1'
    return memo[key]
  end

  if on_stack[node]
    puts "CYCLE DETECTED at node=#{node} -> 0" if ENV['DEBUG'] == '1'
    memo[key] = 0
    return 0
  end

  on_stack[node] = true
  total = 0
  children = adj[node]
  puts "CHILDREN of #{node}: #{children.join(' ')}" if ENV['DEBUG'] == '1'

  children.each do |child|
    total += count_paths(child, target, adj, memo, on_stack, seen1, seen2, must1, must2)
  end

  on_stack.delete(node)
  memo[key] = total
  puts "EXIT node=#{node} flags(dac=#{seen1},fft=#{seen2}) -> total=#{total}" if ENV['DEBUG'] == '1'
  total
end

puts count_paths(start, target, adj, memo, on_stack, false, false, must1, must2)
