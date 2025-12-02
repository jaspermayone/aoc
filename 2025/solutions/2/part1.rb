# frozen_string_literal: true

line = File.readlines('input.txt')[0]
arr = line.split(',')

# puts arr

invalid_ids = []

arr.each do |range_str |
  start_str, end_str = range_str.split('-', 2)
  start_num = Integer(start_str)
  end_num   = Integer(end_str)


  (start_num..end_num).each do |i|
    str = i.to_s
    length = str.length
    midpoint = (length / 2.0).ceil # Use ceil to handle odd-length strings, putting the extra char in the first half

    first_half = str[0, midpoint]
    second_half = str[midpoint..]

    invalid_ids.push(i) if first_half == second_half
  end
end

puts "sum #{invalid_ids.sum}"
