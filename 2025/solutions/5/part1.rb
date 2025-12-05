# frozen_string_literal: true

INPUT_PATH = "input.txt"

ingredients = []
fresh_ranges = []


left_side = true

File.foreach(INPUT_PATH, chomp: true) do |line|
  # Detect the blank line separating the two sections
  if line.strip.empty?
    left_side = false
    next
  end

  if left_side
    # Parse "A-B" into a Ruby Range
    if line =~ /\A\s*(-?\d+)\s*-\s*(-?\d+)\s*\z/
      a = Regexp.last_match(1).to_i
      b = Regexp.last_match(2).to_i
      fresh_ranges << (a..b)
    else
      warn "Skipping invalid range line: #{line.inspect}"
    end
  else
    # Parse a single integer
    if line =~ /\A\s*(-?\d+)\s*\z/
      ingredients << Regexp.last_match(1).to_i
    else
      warn "Skipping invalid number line: #{line.inspect}"
    end
  end
end

fresh_count = ingredients.count { |n| fresh_ranges.any? { |r| r.cover?(n) } }

puts fresh_count
