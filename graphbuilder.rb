require 'rubygems'
require 'gexf'

$count = 1
def write(root)
    graph = GEXF::Graph.new
    def build_graph(graph, cur)
        v = cur[:value]
        node = graph.create_node(:label => v)
        cur[:node] = node
        cur[:children].each {|c| build_graph(graph, c) }
        cur[:children].each {|c| node.connect_to(c[:node])}
    end
    build_graph(graph, root)
    file = File.new("graph#{$count}.gexf", 'w')
    file.write(graph.to_xml)
    file.close
    $count += 1
end

def averagedepth(root)
    def traverse(node, depth, ds)
        if node[:children].empty?
            ds.push(depth)
            1.0
        else
            node[:children].map do |c|
                traverse(c, depth+1, ds)
            end.inject(:+)
        end
    end
    ds = []
    c = traverse(root, 0.0, ds)
    return ds.max, ds.inject(:+)/c, ds.min
end

def fanout(root)
    def compute_fanout(node)
        if node[:children].empty?
            1
        else
            1 + node[:children].map do |c|
                compute_fanout(c)
            end.inject(:+)
        end
    end
    root[:children].map {|c|compute_fanout c}
end

root = {:value => 'Root', :children => []}
stack = []
getvalue = false
File.open('gcpicture.dat', 'r').each do |line|
    if (getvalue)
        stack.last[:value] = line
        getvalue = false
    else
        case line.strip()
        when 'rs'
            root = {:value => 'Root', :children => []}
            stack.push(root)
        when 'ns'
            node = {:children => []}
            stack.last[:children].push(node)
            stack.push(node)
            getvalue = true
        when 'ne'
            stack.pop()
        when 're'
            puts "Size: #{root[:children].size}"
            h = Hash.new(0)
            fanout(root).each{|c| h[c]+=1}
            h.sort.each {|c, n| puts "#{c}: #{n}"}
            puts '\n'
        end
    end
end

