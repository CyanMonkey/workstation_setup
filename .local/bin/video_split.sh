#!/bin/bash
set -xv

awk_command='
#Accepted Data formats

#	Video_timestamp artist_name song_name
#	NEW GROUP NAME

#Lines in all CAPS deliminate a new folder when sorting the clips
#You should always begin a timestamp file with a group name

BEGIN{
	x = 1
	y = 1
	z = 1
}

#ignore empty lines and lines with a single word

/^$/ {
	new_line[NR] = ""
	start_time[y] = ""
	clip_name[y] = ""
	y++
}

/^[A-Z ]+$/ {
	if ( $0 ~ / / ) {
		gsub(/ /,"_")
		group[x] = tolower($0)
		start_time[y] = ""
		clip_name[y] = ""
		x++
		y++
	}
	else {
		group[x] = tolower($0)
		start_time[y] = ""
		clip_name[y] = ""
		x++
		y++
	}
}

#standardize timestamp format
$1 ~ /^\[?\.?[0-9]/ {

	sub(/^\[/,"")
	sub(/\]/,"")

	if ( $1 !~ /\.[0-9]$/ ) {
		s = ".0"
		$1 = $1 s
	}

	if ( $1 ~ /^[0-9]{1,2}\.[0-9]$/ ) {
		 if ( $1 ~ /^[0-9]\.[0-9]$/ ) {
			s = "00:0"
		} else {
			s = "00:"
		}
	$1 = s $1
	}

	if ( $1 ~ /^[0-9]{1,2}:[0-9]{2}\.[0-9]$/ ) {
		if ( $1 ~ /^[0-9]:[0-9]{2}\.[0-9]$/ ) {
			s = "00:0"
		} else {
			s = "00:"
		}
	$1 = s $1
	}
}

#HH:MM:SS.m
/^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9] / {
	#replace all but the first space infront of timestamp
	sub(/ /,"@")
	gsub(/ /,"_")
	sub(/@/," ")
	start_time[y] = $1
	clip_name[y] = $2
	y++
}

END{

for ( i = 1; i <= NR; ++i ) {
	end_time[i] = start_time[i + 1]
	if ( i in new_line ) {
		z++
		i++
	} else {
		# fix null group placeholder
		if ( end_time[i] == "" ){
			end_time[i] = start_time[i + 3]
		}
		if ( i == 1 )continue
		else if ( i == NR ){

		print start_time[i]" ""end_time"" "clip_name[i]" "group[z]
		exit
		}

		print start_time[i]" "end_time[i]" "clip_name[i]" "group[z]
	}
}
}
'

[[ -z $1 ]] && read -p "please supply a timestamp file: " timestamp_file || timestamp_file=$1
[[ -z $2 ]] && read -p "please supply a video/audio file: " video_input || video_input=$2


end_of_video="$(ffprobe -i $video_input 2>&1 | grep "Duration"| cut -d ' ' -f 4 | sed s/,//)"
temp=$(mktemp)
trap 'rm $temp' 0 2 3 15

gawk "$awk_command" $timestamp_file > $temp
sed -i "s/end_time/$end_of_video/" $temp

while read line
do
	folder_path="$(dirname $video_input)/clips/$group_name"
	start_time=$(echo "$line" | gawk '{printf($1)}')
	end_time=$(echo "$line" | gawk '{printf($2)}')
	clip_name=$(echo "$line" | gawk '{printf($3)}')
	group_name=$(echo "$line" | gawk '{printf($4)}')
	[ -d $folder_path ] || { mkdir -p $folder_path; }
	ffmpeg -ss $start_time -to $end_time -i $video_input  -c copy  "$folder_path/$clip_name.mp4"
done < $temp
