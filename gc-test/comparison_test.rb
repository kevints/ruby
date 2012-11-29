#!/usr/bin/env ruby

require 'set'

TEST_LINE_PATTERN = /^GCTest:(.*)$/

def extract_marked_sets
  first_run = Set.new
  second_run = Set.new
  cur_set = first_run
  ARGF.each_line do |l|
    match = TEST_LINE_PATTERN.match(l) 
    next unless match
    
    payload = match[1].strip

    case payload
    when "A"
      cur_set = first_run
    when "B"
      cur_set = second_run
    when /\d+/
      cur_set << payload.to_i
    when "END"
      next
    else
      raise ArgumentError.new("Couldn't recognize payload: #{payload}")
    end
  end

  if first_run != second_run
    puts "Got differences between runs"
    puts "Only in first: #{(first_run - second_run).to_a.join("\n")}"
    puts "Only in second: #{(second_run - first_run).to_a.join("\n")}"
  end

end

extract_marked_sets
