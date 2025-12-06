# frozen_string_literal: true

lines = File.readlines('input.txt', chomp: true)

# Pad all lines to the same length
max_len = lines.map(&:length).max
grid = lines.map { |line| line.ljust(max_len).chars }

num_rows = grid.length
num_cols = max_len

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

problems = []
current_numbers = []
current_op = nil

(num_cols - 1).downto(0) do |col|
  column = (0...num_rows).map { |row| grid[row][col] }

  if column.all? { |c| c == ' ' }
    if current_numbers.any?
      problems << { numbers: current_numbers.reverse, op: current_op }
      current_numbers = []
      current_op = nil
    end
    next
  end

  bottom = column.last
  if operator?(bottom)
    current_op = bottom
    digits = column[0...-1].select { |c| c =~ /\d/ }.join
  else
    digits = column.select { |c| c =~ /\d/ }.join
  end

  if digits.length.positive?
    current_numbers << digits.to_i
  end
end

if current_numbers.any?
  problems << { numbers: current_numbers.reverse, op: current_op }
end

total = 0
problems.each_with_index do |prob, idx|
  result = apply_op(prob[:numbers], prob[:op])
  total += result
end

puts total
