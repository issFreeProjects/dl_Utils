#!/bin/bash

############################################################################################
# Download Command Examples:
#   for usual download: 
#       /bin/wget
#       recommended: /bin/aria2c
# 
#   also you can use youtube-dl:
#	  /use/bin/youtube-dl
#
# only change the following line with pattern ( DL=(your choice) )
  DL=/bin/wget
############################################################################################
LN=1							# line number counter
LNN=1							# line's that not commented number counter
TLN=`grep "^[^#\!]" $1 | wc -l | awk '{print $1}'`	# number of input file lines
ERRC=0							# errors count
DATE=`date`						# using for log

for line in `cat $1`
do
    if echo $line | grep "^[^#!]" >> /dev/null  	# lines that don't start with !(failure) and #(done)
    then
	echo "$(tput bold 0)$(tput setab 4) Downloading: " $LNN "/" $TLN "$(tput sgr 0)"
	$DL $line  # run download command 
	stat=$?    # fetch exit code
	if [[ stat -eq 0 ]]
	then    # downloaded Successfully
		echo "$(tput bold 0)$(tput setab 2) "Success" $(tput sgr 0)"
		sed -i "$LN {s/^/#/}" $1   # adding # to the beginning of the line
	else    # error
		# if this error be the first error
		[[ ERRC -eq 0 ]] && echo "####################  at:     $DATE  ####################" >> failedList
		echo "$(tput bold 0)$(tput setab 1) "some failure! - exit code=$stat" $(tput sgr 0)"
		if [ "$2" != "--ignore" ] && [ "$2" != '-i' ]
		then
			sed -i "$LN {s/^/\!/}" $1  # adding ! to the beginning of the line
		fi
		echo $line >> failedList   # add line to failedList log file
		let ERRC++
	fi
	let LNN++ # increase not commented lines counter
    fi
    let LN++  # increase the line counter
done

[[ ERRC -gt 0 ]] && echo -e "####################  end of: $DATE  #################### count of fails=${ERRC}\n\n" >> failedList
