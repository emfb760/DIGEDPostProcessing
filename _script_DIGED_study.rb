#============================ Modifiable variables to port script over to further studies ========================================

in_qzFilename = "cs10_basicOutput_fall13_QuizResponses.csv"
in_srvyFilename = "cs10_basicOutput_fall13_FollowUpSurvey.csv"

out_zyFilename = "debug/step1_Zyante.csv"
out_txtFilename = "debug/step1_Textbook.csv"

out_excFilename = "debug/Exclusions_FromCriteria.csv"
out_excDupRespFilename = "debug/Exclusions_QuizDuplicateResponses.csv"
out_excLogFilename = "debug/ExclusionCriteria.log"

out_zyPreQFilename = "debug/step2_Zyante_PreQ.csv"
out_zyPostQFilename = "debug/step2_Zyante_PostQ.csv"
out_txtPreQFilename = "debug/step2_Textbook_PreQ.csv"
out_txtPostQFilename = "debug/step2_Textbook_PostQ.csv"

out_zyPreQNoDupFilename = "debug/step3_Zyante_PreQ_NoDuplicates.csv"
out_zyPostQNoDupFilename = "debug/step3_Zyante_PostQ_NoDuplicates.csv"
out_txtPreQNoDupFilename = "debug/step3_Textbook_PreQ_NoDuplicates.csv"
out_txtPostQNoDupFilename = "debug/step3_Textbook_PostQ_NoDuplicates.csv"

out_zyPreQScoreFilename = "SCORES/SCORES_Zyante_PreQ.csv"
out_zyPostQScoreFilename = "SCORES/SCORES_Zyante_PostQ.csv"
out_txtPreQScoreFilename = "SCORES/SCORES_Textbook_PreQ.csv"
out_txtPostQScoreFilename = "SCORES/SCORES_Textbook_PostQ.csv"

out_statsFilename = "debug/STATS_cs10_basicOutput_fall13.txt"

preQ_regex = /QpreLesson/
postQ_regex = /QpostLesson/

excludedIDs = ["3132","2124"]

#=================================================================================================================================

#========================================== Create directories to store results ==================================================

if Dir.exists?("debug")
	Dir.foreach("debug") do |x|
		if x != "." && x != ".."
			File.delete("debug/"+x)
		end
	end
	
	Dir.rmdir("debug")
end
debug = Dir.mkdir("debug",0777)

if Dir.exists?("SCORES")
	Dir.foreach("SCORES") do |x|
		if x != "." && x != ".."
			File.delete("SCORES/"+x)
		end
	end
	
	Dir.rmdir("SCORES")
end
debug = Dir.mkdir("SCORES",0777)

#================================================================================================================================

#================================== Exclude the manually entered IDs to be excluded =============================================

def manualExclusions(excludedIDs,out_excLogFilename)

	excLogFile = File.new(out_excLogFilename,'w')
	
	excludedIDs = excludedIDs.sort
	
	excLogFile.puts("Excluded the following IDs as specified by the user:")
	excLogFile.puts()
	if excludedIDs.length == 0
		excLogFile.puts("NONE")
	else
		excludedIDs.each { |x| excLogFile.puts(x) }
	end

	excLogFile.close
end

#================================================================================================================================


#============================================ Find duplicate userID entries in survey ===========================================

def findDuplicatesInSurvey(excludedIDs,in_srvyFilename,out_excLogFilename)

	followUpSurveyFile = File.new(in_srvyFilename,'r')
	excLogFile = File.new(out_excLogFilename,'a')
	
	allIDs = []

	lines = followUpSurveyFile.each_line
	lines.next

	lines.each do |l|
		l_arr = l.split(',').map(&:strip)
		allIDs.push(l_arr[1])
	end

	repeats = allIDs.group_by { |e| e }.select { |k, v| v.size > 1 }.map(&:first)
	repeats = repeats.sort
	
	excLogFile.puts("\n\nExcluded the following IDs for duplicate followup survey entries:")
	excLogFile.puts()
	if repeats.length == 0
		excLogFile.puts("NONE")
	else
		repeats.each do |x|
			excludedIDs.push(x)
			excLogFile.puts(x)
		end
	end
	
	followUpSurveyFile.close
	excLogFile.close

end
#==================================================================================================================================


#================================ Use the follow up survey to distinguish zyante from textbook participants =======================

def findZyanteVsTextbookIDs(excludedIDs,zyanteIDs,textbookIDs,in_srvyFilename,out_excLogFilename)

	followUpSurveyFile = File.new(in_srvyFilename,'r')
	excLogFile = File.new(out_excLogFilename,'a')
	
	noCategoryIDs = []
	
	lines = followUpSurveyFile.each_line
	lines.next

	lines.each do |l|
		l_arr = l.split(',').map(&:strip)

		if !(excludedIDs.include? l_arr[1]) && l_arr[3] == "zyante"
			zyanteIDs.push(l_arr[1])
		elsif !(excludedIDs.include? l_arr[1]) && l_arr[3] == "textbook"
			textbookIDs.push(l_arr[1])
		elsif !(excludedIDs.include? l_arr[1])
			noCategoryIDs.push(l_arr[1])
		end
	end

	noCategoryIDs = noCategoryIDs.uniq
	noCategoryIDs = noCategoryIDs.sort
	
	excLogFile.puts("\n\nExcluded the following IDs for not having zyante/textbook included in survey entry:")
	excLogFile.puts()
	if noCategoryIDs.length == 0
		excLogFile.puts("NONE")
	else
		noCategoryIDs.each do |x| 
			excludedIDs.push(x)
			excLogFile.puts(x)
		end
	end
	
	followUpSurveyFile.close
	excLogFile.close
	
end

#==================================================================================================================================

#============================= Separate the entries given the IDs for zyante/textbook/excluded ====================================

def separateZyanteVsTextbookEntries(excludedIDs,zyanteIDs,textbookIDs,in_qzFilename,out_zyFilename,out_txtFilename,out_excFilename,out_excLogFilename)
	
	inFile = File.new(in_qzFilename,'r')
	zFile = File.new(out_zyFilename,'w')
	tFile = File.new(out_txtFilename,'w')
	excFile = File.new(out_excFilename,'w')
	excLogFile = File.new(out_excLogFilename,'a')
	
	noSurveyEntryIDs = []
	
	inFileLines = inFile.each_line
	inFileLines.next

	inFileLines.each do |l|
		l_arr = l.split('","').map(&:strip)
		if zyanteIDs.include? l_arr[1]
			zFile.puts(l)
		elsif textbookIDs.include? l_arr[1]
			tFile.puts(l)
		elsif !(excludedIDs.include? l_arr[1])
			noSurveyEntryIDs.push(l_arr[1])
			excFile.puts(l)
		else
			excFile.puts(l)
		end
	end

	noSurveyEntryIDs = noSurveyEntryIDs.uniq
	noSurveyEntryIDs = noSurveyEntryIDs.sort
	
	excLogFile.puts("\n\nExcluded the following IDs for not having a survey entry:")
	excLogFile.puts()
	if noSurveyEntryIDs.length == 0
		excLogFile.puts("NONE")
	else
		noSurveyEntryIDs.each do |x|
			excludedIDs.push(x)
			excLogFile.puts(x)
		end
	end
	
	inFile.close
	zFile.close
	tFile.close
	excFile.close
	excLogFile.close
	
end

#==================================================================================================================================

#==================================== Find IDs from survey that have no quiz responses ============================================

def findIDsFromSurveyNotInQuiz(zyanteIDs,textbookIDs,excludedIDs,in_qzFilename,out_excLogFilename)
	
	quizFile = File.new(in_qzFilename,'r')
	excLogFile = File.new(out_excLogFilename,'a')
	
	srvyIDs = []
	quizIDs = []
	noQuizEntries = []
	
	qlines = quizFile.each_line
	qlines.next
	
	qlines.each do |l|
		l_arr = l.split('","').map(&:strip)
		
		quizIDs.push(l_arr[1])
	end
	
	quizIDs = quizIDs.uniq
	
	zyanteIDs.each { |x| srvyIDs.push(x) }
	textbookIDs.each { |x| srvyIDs.push(x) }
	
	srvyIDs.each do |x|
		if !(quizIDs.include? x)
			excludedIDs.push(x)
			noQuizEntries.push(x)
		end
	end
	
	noQuizEntries = noQuizEntries.sort
	
	excLogFile.puts("\n\nExcluded the following IDs from survey that do not have any quiz entries:")
	excLogFile.puts()
	if noQuizEntries.length == 0
		excLogFile.puts("NONE")
	else
		noQuizEntries.each do |x|
			excLogFile.puts(x)
		end
	end
	
	quizFile.close
	excLogFile.close
	
end

#==================================================================================================================================

#================================== Separate the entries by pre vs post quiz responses ============================================

def separatePreVsPostQuizResponses(in_filename,out_preQFilename,out_postQFilename,out_excFilename,out_excLogFilename,preQ_regex,postQ_regex)

	inFile = File.new(in_filename,'r')
	preQFile = File.new(out_preQFilename,'w')
	postQFile = File.new(out_postQFilename,'w')
	excFile = File.new(out_excFilename,'a')
	excLogFile = File.new(out_excLogFilename,'a')
	
	preVsPostStatusMissingIDs = []
	
	lines = inFile.each_line
	
	lines.each do |l|
		l_arr = l.split('","').map(&:strip)
		
		if preQ_regex.match(l_arr[3])
			preQFile.puts(l)
		elsif postQ_regex.match(l_arr[3])
			postQFile.puts(l)
		else
			preVsPostStatusMissingIDs.push(l_arr[3])
			excFile.puts(l)
		end
	end
	
	preVsPostStatusMissingIDs = preVsPostStatusMissingIDs.uniq
	preVsPostStatusMissingIDs = preVsPostStatusMissingIDs.sort
	
	excLogFile.puts("\n\nExcluded the following IDs from "+in_filename+" for not having a pre vs post quiz identifier:")
	excLogFile.puts()
	if preVsPostStatusMissingIDs.length == 0
		excLogFile.puts("NONE")
	else
		preVsPostStatusMissingIDs.each { |x| excLogFile.puts(x) }
	end
	
	inFile.close
	preQFile.close
	postQFile.close
	excFile.close
	excLogFile.close

end

#==================================================================================================================================

#================================================ Remove Duplicate Responses ======================================================

def removeDuplicates(in_filename,out_filename,out_excDupRespFilename)
	
	inFile = File.new(in_filename,'r')
	outFile = File.new(out_filename,'w')
	excFile = File.new(out_excDupRespFilename,'a')
	
	responsesHash = {}
	responsesArray = []
	
	lines = inFile.each_line
	
	lines.each do |l|
		l_arr = l.split(',').map(&:strip)
		
		if !responsesHash[l_arr[1]+l_arr[3]].nil?
			excFile.puts(responsesHash[l_arr[1]+l_arr[3]])
		end
		
		responsesHash[l_arr[1]+l_arr[3]] = l
	end
	
	responsesHash.each { |id,line| responsesArray.push(line) }
	responsesArray = responsesArray.sort
	
	responsesArray.each { |x| outFile.puts(x) }
	
	inFile.close
	outFile.close
	
end

#====================================================================================================================================

#=============================================== Tabulate the scores for each ID ====================================================

def tabulateScores(in_filename,out_filename)
	
	inFile = File.new(in_filename,'r')
	outFile = File.new(out_filename,'w')
	
	scoresHash = {}
	
	lines = inFile.each_line
	
	lines.each do |l|
		l_arr = l.split('","').map(&:strip)
		
		if l_arr[3] != "ScppBasicOutput_QpostLessonMC_5" && l_arr[3] != "ScppBasicOutput_QpostLessonSA_3"
			scoresHash[l_arr[1]] = scoresHash[l_arr[1]].nil? ? l_arr[4].to_i : scoresHash[l_arr[1]]+l_arr[4].to_i
		end
	end
	
	scoresHash.sort.map do |userID,score|
		outFile.puts(userID+","+score.to_s)
	end
	
	inFile.close
	outFile.close
	
end

#====================================================================================================================================

#====================================== Get general stats for entries and participants lost =========================================

def getStats(srvyFilename,qzFilename,excFilename,excDupRespFilename,excludedIDs,out_statsFilename)

	srvyFile = File.new(srvyFilename,'r')
	quizFile = File.new(qzFilename,'r')
	exc1File = File.new(excFilename,'r')
	exc2File = File.new(excDupRespFilename,'r')
	statsFile = File.new(out_statsFilename,'w')
	
	totalUserIDs = {}
	totalEntries = 0
	excludedEntries = 0
	
	lines_srvy = srvyFile.each_line
	lines_srvy.next
	lines_srvy.each do |l|
		l_arr = l.split(',').map(&:strip)
		totalUserIDs[l_arr[1]] = 1
	end
	
	lines_quiz = quizFile.each_line
	lines_quiz.next
	lines_quiz.each do |l|
		l_arr = l.split('","').map(&:strip)
		totalUserIDs[l_arr[1]] = 1
		totalEntries = totalEntries+1
	end
	
	lines_exc1 = exc1File.each_line
	lines_exc1.each do |l|
		excludedEntries = excludedEntries+1
	end
	
	lines_exc2 = exc2File.each_line
	lines_exc2.each do |l|
		excludedEntries = excludedEntries+1
	end
	
	entryPercentage = ((1.0-(excludedEntries.to_f/totalEntries.to_f))*100)
	participantPercentage = ((1.0-(excludedIDs.length.to_f/totalUserIDs.length.to_f))*100)
	
	puts "Total Entries: "+totalEntries.to_s
	puts "Total Participants: "+totalUserIDs.length.to_s
	puts
	puts "Total Excluded Entries: "+excludedEntries.to_s
	puts "Total Excluded Participants: "+excludedIDs.length.to_s
	puts
	puts "Percentage of Entries Remaining: %0.3f%" % [entryPercentage]
	puts "Percentage of Participants Remaining: %0.3f%" % [participantPercentage]
	puts
	
	statsFile.puts("Total Entries: "+totalEntries.to_s)
	statsFile.puts("Total Participants: "+totalUserIDs.length.to_s)
	statsFile.puts()
	statsFile.puts("Total Excluded Entries: "+excludedEntries.to_s)
	statsFile.puts("Total Excluded Participants: "+excludedIDs.length.to_s)
	statsFile.puts()
	statsFile.puts("Percentage of Entries Remaining: %0.3f%" % [entryPercentage])
	statsFile.puts("Percentage of Participants Remaining: %0.3f%" % [participantPercentage])
	
	srvyFile.close
	quizFile.close
	exc1File.close
	exc2File.close
	statsFile.close
	
end

#====================================================================================================================================

#========================================== Main code implementing functions calls ==================================================

zyanteIDs = []
textbookIDs = []

puts "Processing..."
puts

manualExclusions(excludedIDs,out_excLogFilename)
findDuplicatesInSurvey(excludedIDs,in_srvyFilename,out_excLogFilename)

puts "Exclusion criteria created (view "+out_excLogFilename+" for info)"
puts

findZyanteVsTextbookIDs(excludedIDs,zyanteIDs,textbookIDs,in_srvyFilename,out_excLogFilename)
separateZyanteVsTextbookEntries(excludedIDs,zyanteIDs,textbookIDs,in_qzFilename,out_zyFilename,out_txtFilename,out_excFilename,out_excLogFilename)

puts "Entries separated by 'Zyante vs Textbook'"
puts

puts "Searching for IDs found in survey but not in quiz..."
puts

findIDsFromSurveyNotInQuiz(zyanteIDs,textbookIDs,excludedIDs,in_qzFilename,out_excLogFilename)

puts "Search complete. Results stored in "+out_excLogFilename
puts

separatePreVsPostQuizResponses(out_zyFilename,out_zyPreQFilename,out_zyPostQFilename,out_excFilename,out_excLogFilename,preQ_regex,postQ_regex)
separatePreVsPostQuizResponses(out_txtFilename,out_txtPreQFilename,out_txtPostQFilename,out_excFilename,out_excLogFilename,preQ_regex,postQ_regex)

puts "Entries separated by 'Pre vs Post'"
puts

removeDuplicates(out_zyPreQFilename,out_zyPreQNoDupFilename,out_excDupRespFilename)
removeDuplicates(out_zyPostQFilename,out_zyPostQNoDupFilename,out_excDupRespFilename)
removeDuplicates(out_txtPreQFilename,out_txtPreQNoDupFilename,out_excDupRespFilename)
removeDuplicates(out_txtPostQFilename,out_txtPostQNoDupFilename,out_excDupRespFilename)

puts "Duplicate quiz responses excluded"
puts

tabulateScores(out_zyPreQNoDupFilename,out_zyPreQScoreFilename)
tabulateScores(out_zyPostQNoDupFilename,out_zyPostQScoreFilename)
tabulateScores(out_txtPreQNoDupFilename,out_txtPreQScoreFilename)
tabulateScores(out_txtPostQNoDupFilename,out_txtPostQScoreFilename)

puts "Scores tabulated excluding Question MC5 and Question SA3"
puts

getStats(in_srvyFilename,in_qzFilename,out_excFilename,out_excDupRespFilename,excludedIDs,out_statsFilename)

puts "Stats stored in "+out_statsFilename
puts

puts "Processing Complete!"
puts

#=====================================================================================================================================

#======================================================== END SCRIPT =================================================================