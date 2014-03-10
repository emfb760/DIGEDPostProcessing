srvyFile = File.new("cs10_basicOutput_fall13_FollowUpSurvey.csv",'r')
quizFile = File.new("cs10_basicOutput_fall13_QuizResponses.csv",'r')

quizIDs = File.new("IDs_quiz.txt",'w')
srvyIDs = File.new("IDs_survey.txt",'w')

q_arr = []
s_arr = []

qlines = quizFile.each_line
qlines.next

qlines.each do |l|
	l_arr = l.split('","').map(&:strip)
	
	q_arr.push(l_arr[1])
end

q_arr = q_arr.uniq
q_arr = q_arr.sort

slines = srvyFile.each_line
slines.next

slines.each do |l|
	l_arr = l.split(',').map(&:strip)
	
	s_arr.push(l_arr[1])
end

s_arr = s_arr.uniq
s_arr = s_arr.sort

q_arr.each { |x| quizIDs.puts(x) }
s_arr.each { |x| srvyIDs.puts(x) }

quizFile.close
srvyFile.close
quizIDs.close
srvyIDs.close