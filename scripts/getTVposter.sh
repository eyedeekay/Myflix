#! /bin/bash

cd "$(dirname "$0")" || exit
if [ "$#" -ne 1 ]; then
	echo "$0": usage: getTVposter.sh ID
	exit 1
fi

dTVImg=false
dTVFolder=../TVimg/
imgResizeTV="-resize 300x"
tinyPNGapi=""
TMDBapi=""
compressImgTV=false
. config.cfg #loads config file

myID=${1}
if ! -z "$TMDBapi"; then
	myUrl="https://api.themoviedb.org/3/tv/\"${myID}\"/images?language=en&api_key=""${TMDBapi}"
	output=$(curl -s --request GET --url "$myUrl" --data '{}' | jq -r '.posters | map(select((.width | contains(680)) and (.height | contains(1000))) | .file_path) | .[]' | head -n1)

	if "$output" = ./*".jpg"*; then
		output="https://image.tmdb.org/t/p/original"$output;
	else
		myUrl="https://api.themoviedb.org/3/tv/\"${myID}\"/images?api_key=""${TMDBapi}"
		output=$(curl -s --request GET --url "$myUrl" --data '{}' | jq -r '.posters[0] | .file_path')
		output="https://image.tmdb.org/t/p/original"$output;
	fi

	if $dTVImg; then
		if [ ! -d "$dTVFolder" ]; then #creates folder if missing
			mkdir $dTVFolder
		fi
		wget -q -N -P "$dTVFolder" "$output"; #downloads image
		output=$(basename "$output")
		if [ ! -z "$imgResizeTV" ]; then #runs imagemagick convert with the option defined in imgResizeTV
			convert "$imgResizeTV" "$dTVFolder$output" "$dTVFolder$output"
		fi
		if $compressImgTV; then
			convert -strip -interlace Plane -gaussian-blur 0.05 -quality 85% "$dTVFolder$output" "$dTVFolder$output"
		fi
		if ! -z "$tinyPNGapi"; then
			imgUrl=$(curl -s --user api:"$tinyPNGapi"  --data-binary @"$dTVFolder$output" https://api.tinify.com/shrink | jq -r '.output.url')
			curl -s --user api:"$tinyPNGapi" --output "$dTVFolder$output" "$imgUrl"
		fi
		chmod 755 -R $dTVFolder
		tempFolder=$(basename $dTVFolder)
		echo "$tempFolder""/""$output";
	else
		echo "$output"
	fi
else
	echo "null"
fi
