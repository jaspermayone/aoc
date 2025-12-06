# frozen_string_literal: true

grid = File.readlines('input.txt', chomp: true)
           .map { |line| line.strip.split(' ') }
           .map { |row| row.map { |t| Integer(t, exception: false) || t } }

def operator?(char)
  %w[* + - /].include?(char)
end

def apply_op(values, op)
  case op
  when '*'
    values.reduce(1, :*)
  when '+'
    values.reduce(0, :+)
  when '-'
    values.reduce(:-)
  when '/'
    values.reduce(:/)
  else
    raise "Unknown operator: #{op}"
  end
end

# Convert tokens to integers, leaving non-numerics intact
def to_i_or_str(token)
  Integer(token, exception: false) || token
end

def compute_columns(grid)
  num_cols = grid.map(&:length).max || 0

  (0...num_cols).map do |col|
    column = grid.map { |row| row[col] }
    # Drop nils (ragged rows) and convert tokens
    tokens = column.compact.map { |t| to_i_or_str(t) }

    op = tokens.last
    values = tokens[0...-1]

    result = apply_op(values, op)
    { column: col, op: op, values: values, result: result }
  end
end


results = compute_columns(grid)
results_sum = 0

results.each do |r|
  puts "col #{r[:column]} (#{r[:op]}): #{r[:values].inspect} => #{r[:result]}"
  results_sum += r[:result]
end

puts results_sum
