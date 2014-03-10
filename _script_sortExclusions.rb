inFile = File.new("Quiz_Exclusions.csv","r")
outFile = File.new("Quiz_Exclusions_Sorted.csv","w")

lines_arr = []

exc_lines = inFile.each_line

exc_lines.each do |l|
	l_arr = l.split(',').map(&:strip)
	
	lines_arr.push(l_arr)
end

lines_arr.sort! do |a,b|
  [a[1],a[0]] <=> [b[1], b[0]]
end

lines_arr.each { |e| outFile.puts(e.join(",")) }