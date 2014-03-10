inFile = File.new("quiz_last_response.csv","r")
outFile = File.new("quiz_last_response_fixed.csv","w")

lines = inFile.each_line
line = 1

lines.each do |l|
	if line % 2 == 1
		outFile.puts(l)
	end
	line = line + 1
end

inFile.close
outFile.close