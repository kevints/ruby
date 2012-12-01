require 'csv'
MAX_THREADS = 16

def parse_file_name(fname)
  pattern = /(.*?)\.rb_(\d+)_out/
  
  match = pattern.match(fname)
  
  if match.nil?
    throw ArgumentError.new("Bad filename")
  end

  return match[1..2]
end



#nthreads bench bench

def extract_times(fname)
  num_calls = 0
  times = 0.0
  results = Hash.new {|hash, key| hash[key] = [0, 0.0] }

  File.open(fname) do |f|
    f.each_line do |l|
      parsed = parse_line(l)
      if not parsed
        next
      end      

      if parsed[:time] < 0
        next
      end
      res = results[parsed[:type]] 
      res[0] += 1
      res[1] += parsed[:time]
    end
  end
  
  avgs = Hash[results.each_pair.map do |key, res|
    [key, res[1] / res[0]] unless res[0] == 0
  end]

  return avgs
end


def extract_all
  CSV.open("./results.csv", 'wb') do |csv|
    serial_done = false
    csv << ["nthreads"] + Dir.glob("./miniruby_bench/*.rb")
    (1..MAX_THREADS).each do |i|
      row = [i]
      serial_row = ["serial"]
      Dir.glob("./bench_results/*.rb_#{i}_out").each do |fname|
        res = extract_times(fname)

        serial_row << res[:serial]
        row << res[:parallel]
      end

      if not serial_done
        serial_done = true
        csv << serial_row        
      end
      csv << row
    end
  end
end

def parse_line(l)
  rtn = Hash.new

  par_pattern = /(gc_mark_parallel)\(objspace\):(.*)/
  serial_pattern = /(gc_start_mark)\(objspace\):(.*)/

  begin 
    match = par_pattern.match(l) || serial_pattern.match(l)
  rescue
    match = nil
  end
  return nil unless match
  rtn[:type] = match[1] == "gc_mark_parallel" ? :parallel : :serial
  rtn[:time] = match[2].to_f
  
  return rtn
end

extract_all
