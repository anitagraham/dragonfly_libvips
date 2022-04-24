#!/usr/bin/ruby

require 'vips'

x = Vips::Image.new_from_file ARGV[0]

%w(dz hdr jpc jpt jp2 j2c j2k webp).each do |format|
  begin
    buf = x.write_to_buffer ".#{format}"
    puts "#{format}: written #{buf.length} bytes"
  rescue Vips::Error
    puts "#{format}: buffer write not supported"
  end
end

# imagemagick-based savers need to be told the for format to write twice :(
%w(bmp gif heif avif ppm pfm pgm pbm).each do |format|
  buf = x.write_to_buffer ".#{format}"
  puts "#{format}: written #{buf.length} bytes"
end

%w(bmp gif).each do |format|
  begin
    buf = x.write_to_buffer ".#{format}", format: format
    puts "#{format}: written #{buf.length} bytes"
  rescue Vips::Error
    puts "#{format}: buffer write not supported"
  end
end

# libheif buffer savers need to be told the format too
buf = x.write_to_buffer ".heif", compression: "hevc"
puts "heic: written #{buf.length} bytes"

buf = x.write_to_buffer ".heif", compression: "av1"
puts "avif: written #{buf.length} bytes"
