# frozen_string_literal: true

def max_subsequence_k_digits(digits, k)
  stack = []
  drops_remaining = digits.length - k

  digits.each do |d|
    while !stack.empty? && stack[-1] < d && drops_remaining > 0
      stack.pop
      drops_remaining -= 1
    end
    stack << d
  end

  stack.first(k)
end

sum = 0

File.readlines('tmp.txt', chomp: true).each do |line|
  next unless line.match?(/\A\d+\z/)
  digits = line.chars.map { |c| c.ord - 48 }
  kept = max_subsequence_k_digits(digits, 12)
  sum += kept.join.to_i
end

puts sum
