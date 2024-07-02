#!/usr/bin/env bash

if [ $API_KEY ] && [ $API_SIGNATURE ]
then 
	# Recreate the output
	rm -f output.json 
	touch output.json 
	echo "# " $(date) >> output.json 
	# echo "[" >> output.json -- Add a '[' to wrap the output, but the new API does this for us. 2024/07.

	echo -e "\n\n FETCHING API DATA on $(date) \n\n"

	venue_codes=(29 152)

	for venue in "${venue_codes[@]}"
	do
		echo -e "\n\nLOOKING UP FOR VENUE $venue \n\n"
		i=0
		complete=false 

		while [ complete==false ]
		do
			echo "Fetching records ${i} to $((i + 99))"
			raw_result=$(curl "https://api.edinburghfestivalcity.com/events?key=$API_KEY&signature=$API_SIGNATURE&pretty=1&festival=fringe&venue_code=${venue}&from=${i}&size=100")

			# Each venue pull will be wrapped in [], so strip that so all the venues are together in one [].
			result=$(echo "${raw_result}" | sed -E '1s/\[//' | sed -E 's/\(.*\)\]//' )

			len="${#result}" # How many characters is the response? If it's <5, assume we've run out of data 
			if [ $len -lt 5 ]
				then
					complete=true
					break 
				else 
					if [ $i -gt 0 ]
					then 
						echo "," >> output.json 
					fi
					echo "${result}" >> output.json 
			fi 

			i=$((i + 99)) 
			echo "LINE COUNT:"
			cat output.json | wc -l
			echo "NEXT LOOP STARTS FROM: $i"

		done
		if [ $venue != ${venue_codes[${#venue_codes[@]}-1]} ]
		then 
			echo "," >> output.json 
		fi

	done

	# echo "]" >> output.json See L9.

	mv output.json _data/shows.json 
else
	echo "Environment variables not present, aborting."
fi 