# frozen_string_literal: true

sum = 0

File.readlines('input.txt', chomp: true).each do |line|
  digits = line.chars.map(&:to_i)
  n = digits.length

  next if n < 2

  # Compute suffix max (max digit from position i+1 to end)
  suffix_max = Array.new(n, 0)
  suffix_max[n - 1] = digits[n - 1]
  (n - 2).downto(0) do |i|
    suffix_max[i] = [digits[i], suffix_max[i + 1]].max
  end

  # Find max two-digit number: first digit at position i, second is max of remaining
  max_joltage = 0
  (0...(n - 1)).each do |i|
    joltage = digits[i] * 10 + suffix_max[i + 1]
    max_joltage = [max_joltage, joltage].max
  end

  sum += max_joltage
end

puts sum
