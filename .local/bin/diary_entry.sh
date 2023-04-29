#!/bin/sh
#This script is designed to dynamically create a folder tree for the
#current date and start the newest diary entry.

#Made by David

###############
#CONFIGURATION#
###############

config_file="/home/bubbles/.config/nvim/init.vim"
editor_path=/usr/bin/nvim

##############################
#leave everything else below!#
##############################

[ ! -z "$1" ] && custom_date="on"

while getopts :d:m:y: option
do
	case "$option" in
		d)
			(( $OPTARG >= 1 && $OPTARG <= 31 )) || { echo "Invalid Day. Must be an integer 1-31";exit; }
			[[ $OPTARG =~ ^[1-9]$ ]] && OPTARG="0$OPTARG"
			day=$OPTARG;;

		m)
			#There is a bug if you try using a argument of "J" because this can match June July January
			#But it is good enough for my use case
			month_list=( "January 01" "February 02" "March 03" "April 04" "May 05" "June 06" "July 07" "August 08" "September 09" "October 10" "November 11" "December 12" )
			[[ $OPTARG =~ ^[1-9]$ ]] && OPTARG="0$OPTARG"
			month=$(printf '%s\n' "${month_list[@]}" | sed -n "/$OPTARG/s/\(^[[:alnum:]]*\) .*/\1/p")
			[ -z $month ] && { echo "Invalid Month. Must be capital month name or number. ex) January or Jan or 01";exit; };;

		y)
			[[ $OPTARG =~ ^[0-9]{4}$ ]] || { echo "Invalid Year. Must be an integer 0000-9999";exit; }
			year=$OPTARG;;

		*)
			echo "Unkown option"
			exit;;
	esac
done

[ -e $config_file ] || { echo "that is not a valid config file";exit; }

declare -a wiki_dir wiki_name

#retrieve vimwiki from config
for i in $(awk '/g:vimwiki_list/,/\]/ {split($0,paths,"\047");print paths[4]}' $config_file)
do
	#variable path expansion
	i="${i/#\~/$HOME}"
	wiki_dir+=("$i")
	wiki_name+=("$(echo $i |rev|sed 's/\/.*//'|rev)")
done

Menu() {
	echo -e "Here are the vimwiki's I found:\n"
	for (( i=0;i<${#wiki_name[@]};++i ));
	do
		printf "\t%-20s%s\n\n" ${wiki_name[$i]} $i\)
	done
	read -p "Please input desired entry: " opt
}

while :
do
	Menu
	#check for invalid characters
	[[ $opt =~ [0-9] ]] || continue
	if printf '%s\n' "${wiki_name[@]}" | grep "^${wiki_name[$opt]}$"
	then
		break
	else
		echo "wiki dosn't exist"
		exit
	fi
done

[[ ${wiki_dir[$opt]} =~ .*"/"$ ]] || wiki_dir[$opt]+="/"
diary_file=${wiki_dir[$opt]}"diary/diary.md"

#the entry template file can be either plain text file or script to create
#a dynamic template for the current date/time or other custom commands.
entry_template=${wiki_dir[$opt]}"diary/entry_template"

[ -z "$year" ] && year=$(date +%Y)
[ -z "$month" ] && month=$(date +%B)
[ -z "$day" ] && day=$(date +%d)

#the first array index is a place holder while checking the diary_file status
date_path=( "" $year $year/$month $year/$month/$day )
date=( "" $year $month $day )
date_plain=( "" "Year" "Month" "Day" )

for (( i=0;i<${#date_path[@]};i++ ));
do
	add1=$(( $i + 1 ))
	paths=${wiki_dir[$opt]}"diary/"${date_path[$i]}
	md_template="[${date[$add1]}][${date[$add1]}/${date[$add1]}.md]"
	md_file="$paths/${date[$i]}.md"
	date_template="==${date_plain[$add1]}==\n$md_template"

	#create directories dynamically to what date it is
	[ -d $paths ] || { mkdir -p $paths; }

	if [ ! -f $entry_template ]
	then
		clear
		echo "looks like you don't have a template set for new journal entries."
		echo "I will make a file here: $entry_template"
		echo "This template can be either plain-text or a shell script."
		echo -e "If you don't want any template, just save and quit as a empty file\n"
		read -n 1 -p "Press any key to continue"
		$editor_path $entry_template
	fi

	#check for plain text or script file template
	if [ $i -eq 3 ] && [[ $(sed '1q' $entry_template) =~ ^#!$SHELL ]]
	then
		#in the script file  you can use the redirection operator ">>" to append STDOUT to
		#the $1 command line arguement path of the md_file
		[ $custom_date == "on" ] && source $entry_template "$md_file" "$day" "$month" "$year" || source $entry_template "$md_file"
		exit
	elif [ $i -eq 3 ]
	then
		$editor_path +":r $entry_template" $md_file
		exit
	fi

	#check for diary file and update or create as needed
	[ $i -eq 0 ] && [ ! -e $diary_file ] && { echo -e $date_template > $diary_file; continue; }
	[ $i -eq 0 ] && [ -z "$(grep $year $diary_file)" ] && { echo $md_template >> $diary_file; continue; }

	#check md files and update or create as needed
	[ ! -e $md_file ] && { echo -e $date_template > $md_file; continue; }
	[ -z "$(grep ${date[$add1]} $md_file)" ] && { echo $md_template >> $md_file; }
done
