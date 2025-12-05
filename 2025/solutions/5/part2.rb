# frozen_string_literal: true

INPUT_PATH = 'input.txt'

fresh_ranges = []

File.foreach(INPUT_PATH, chomp: true) do |line|
  if line =~ /\A\s*(-?\d+)\s*-\s*(-?\d+)\s*\z/
    a = Regexp.last_match(1).to_i
    b = Regexp.last_match(2).to_i
    fresh_ranges << (a..b)
  else
    warn "Skipping invalid range line: #{line.inspect}"
  end
end

puts fresh_ranges.inspect

merged = fresh_ranges.sort_by(&:begin).each_with_object([]) do |r, acc|
  if acc.empty? || r.begin > acc.last.end + 0 # disjoint
    acc << (r.begin..r.end)
  else
    # overlap: extend the last range's end
    last = acc.pop
    acc << (last.begin..[last.end, r.end].max)
  end
end

unique_count = merged.sum(&:size)

puts unique_count
