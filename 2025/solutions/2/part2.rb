# frozen_string_literal: true

line = File.readlines('input.txt')[0]
arr = line.split(',')

# puts arr

invalid_ids = []

def repeated_pattern?(str)
  len = str.length
  # Try base lengths that divide the total length (only up to half)
  (1..(len / 2)).each do |base_len|
    next unless (len % base_len).zero?

    base = str[0, base_len]
    repeats = len / base_len
    return true if base * repeats == str
  end
  false
end

arr.each do |range_str|
  start_str, end_str = range_str.split('-', 2)
  start_num = Integer(start_str)
  end_num   = Integer(end_str)

  (start_num..end_num).each do |i|
    str = i.to_s
    next if str.length < 2 # needs at least 2 repeats

    invalid_ids << i if repeated_pattern?(str)
  end
end


puts "sum #{invalid_ids.sum}"
