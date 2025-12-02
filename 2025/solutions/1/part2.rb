# frozen_string_literal: true

pos = 50
zeros = 0

File.foreach('input.txt') do |line|
  direction = line[0]
  distance  = line[1..].strip.to_i

  case direction
  when 'L'
    (1..distance).each do |_i|
      pos = (pos - 1) % 100
      zeros += 1 if pos.zero?
    end

  when 'R'
    (1..distance).each do |_i|
      pos = (pos + 1) % 100
      zeros += 1 if pos.zero?
    end
  end
end

puts "zeros #{zeros}"
