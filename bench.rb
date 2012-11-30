#!/usr/bin/env ruby

RESULTS_DIR = "./bench_results"
BENCH_DIR = "./benchmark"
GOOD_BENCH = "./miniruby_bench"
MAX_THREADS = 2

def bench(script, nthreads) 
  bench_pattern = /bm_(.*?\.rb)/
  match = bench_pattern.match(script)
  if not match
    return
  end

  prepare_script = "prepare_#{match[1]}"
  
  bench_out = "#{RESULTS_DIR}/#{script}_#{nthreads}_out"
  puts "Benching #{script}"
  
  if File.exist? prepare_script
    system ruby #{BENCH_DIR}/#{prepare_script}
  end

  retval = system "./miniruby #{BENCH_DIR}/#{script} > #{bench_out}"

  if retval
    puts "#{script} succeeded"
    `cp ./benchmark/#{script} #{GOOD_BENCH}`        
  else
    puts("#{script} failed")
    `rm #{bench_out}`
  end 
end

 
def compile(nthreads)
  system "make clean"
  system("make GC_OPTS=\"-DNTHREADS=#{nthreads} -DBENCH=1\" miniruby")   
end


def bench_all
  `mkdir -p #{RESULTS_DIR}`
  `mkdir -p #{GOOD_BENCH}`

  (1..MAX_THREADS).each do |nthreads|
    puts "Benching with #{nthreads} threads..."
    compile(nthreads)
    Dir.new(BENCH_DIR).each do |script|
      if File.directory? script 
        next 
      end
      bench(script, nthreads)      
    end
  end
end

bench_all
