# frozen_string_literal: true

pos = 50
zeros = 0

File.foreach('input.txt') do |line|

  direction = line[0]
  distance  = line[1..].strip.to_i

  case direction
  when 'L'
    pos = (pos - distance) % 100

  when 'R'
    pos = (pos + distance) % 100
  end

  zeros += 1 if pos.zero?
end

puts "zeros #{zeros}"
