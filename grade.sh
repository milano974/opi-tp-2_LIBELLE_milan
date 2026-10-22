#!/bin/bash
#
# AUTHOR: Mathieu MONEYRON - 2026
# LICENCE: GPL-2.0

[ $# -eq 0 ] && echo Please provide a directory with grade files && exit 1
dir=$1

# Print csv header
echo "Student,Grade"

# Initialize grades list used to compute mean value
grades=""

for f in $dir/*; do
	points=0
	total=0

	# Get the grade for each question, which is a list like "1/1 1/2"
	questions=$(grep -e "^E[0-9]*\.[0-9]*:" < "$f" | awk '{print $2}')
	# Extract student name from file name
	student=$(basename "$f" | cut -d '.' -f 1)

	for q in $questions; do
		# Split the string "1/2" to get the actual points the student
		# got, and the total points of the current question
		points_q=$(echo "$q" | cut -d '/' -f 1)
		total_q=$(echo "$q" | cut -d '/' -f 2)

		# Increase the values
		points=$(echo "$points + $points_q" | bc -l)
		total=$(echo "$total + $total_q" | bc -l)
	done

	# Compute the grade /20, keep only 2 decimal digits
	grade=$(echo "scale=2; $points / $total * 20" | bc -l)
	# Diaplay the grade formatted as csv
	echo "$student,$grade"

	# Append to grades list
	grades="$grades $grade"
done

# Insert empty line
echo

# Get grade mean value
num=$(ls $dir/* | wc -l)
sum=$(echo $grades | sed "s/ /+/")
mean=$(echo "scale=2; ($sum) / $num" | bc -l)

echo "Number of students,$num"
echo "Mean,$mean"
