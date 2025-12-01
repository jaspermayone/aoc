# frozen_string_literal: true

require 'optparse'

def main(argv)
  options = {}
  OptionParser.new do |opts|
    opts.banner = 'Usage: part1.rb [options]'
    opts.on('-fFILE', '--file=FILE', 'File to scan') { |v| options[:file] = v }
  end.parse!(argv)

  file = options[:file]

  pos = 50
  zeros = 0

  File.foreach(file) do |line|

    direction = line[0]
    distance  = line[1..].strip.to_i

    case direction
    when 'L'
      pos = (pos - distance) % 100

    when 'R'
      pos = (pos + distance) % 100
    end

    if pos == 0
      zeros += 1
    end

  end

  puts "zeros #{zeros}"


end

if __FILE__ == $PROGRAM_NAME
  main(ARGV)
end