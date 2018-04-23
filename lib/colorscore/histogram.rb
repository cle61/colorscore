require "shellwords"

module Colorscore
  class Histogram
    def initialize(image_path, colors=16, depth=8)
      output = `convert #{image_path.shellescape} -resize 400x400 -format %c -dither None -quantize YIQ -colors #{colors.to_i} -depth #{depth.to_i} histogram:info:-`
      @lines = output.lines.sort.reverse.map(&:strip).reject(&:empty?)
    end

    def get_lines
      @lines
    end

    def rgb(r, g, b)
      "##{to_hex r}#{to_hex g}#{to_hex b}"
    end
    def to_hex(n)
      n.to_s(16).rjust(2, '0').upcase
    end

    # Returns an array of colors in descending order of occurances.
    def colors
      colors = []
      @lines.each do |line|
        color = line.scan(/\d{1,3},\d{1,3},\d{1,3}/).first
        next if color.blank?
        color = color.split(',')
        colors << rgb(color[0].to_i, color[1].to_i, color[2].to_i)
      end
      colors
    end

    def color_counts
      @lines.map { |line| line.split(':')[0].to_i }
    end

    def scores
      total = color_counts.inject(:+).to_f
      scores = color_counts.map { |count| count / total }
      scores.zip(colors)
    end
  end
end
