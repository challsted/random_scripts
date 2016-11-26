#!/usr/bin/bash
#
# YouTube Alarm
#
# Dependencies: dateutils (www.fresse.org/dateutils)
#
# You must pass 2 values to the script, 1 of which must be a YouTube link, the other is an optional + and
#     an additional amount of time (s)econds, (m)inutes, (d)ays, (w)eeks, (mo)nths, (y)ears
#
# Usage example:
#    ./ytalarm.sh https://www.youtube.com/watch?v=ZZ5LpwO-An4 +30m
#    ./ytalarm.sh +1d https://www.youtube.com/watch?v=ZZ5LpwO-An4
#    ./ytalarm.sh https://www.youtube.com/watch?v=ZZ5LpwO-An4 +2h

# Make sure that "DateAdd" is available on the system (Because we need it) exit it not
if ! type dateadd > /dev/null; then
    echo "Please install \"dateutils\", probably though your package manager"
    exit 2
fi

# Check to make sure that the use passed in 2 values, complain if not
# TODO Fix this to be where it prints an example of how to use it if either of the inputs are bad
userInput(){
    if [[ "$#" -eq 0 ]]; then
        echo -e "\t You didnt pass me anything?"
    elif [[ "$#" -eq 1 ]]; then
        echo -e "\t half good, i got 1"
        echo "\$1: $1"
    elif [[ "$#" -eq 2 ]]; then
        checkInputs "$1" "$2"
    elif [[ "$#" -gt 2 ]]; then
        echo -e "\t no good! you passed me too many things!"
        exit 3
    else
        echo -e "\t SOMETHING TERRIBLE HAPPENED! Might want to tell the developer about this..."
        exit 9
    fi
}

checkInputs(){
    # Check which input has the YouTube address (will add other sites later)
    # TODO Add other sites then YouTube
    youtubeAddressOne=$(echo "$1" | grep -ic "youtube.com" 2> /dev/null)
    youtubeAddressTwo=$(echo "$2" | grep -ic "youtube.com" 2> /dev/null)


    # Figure out which input has the YouTube Address, then ASSUME that the other is a time
    if [[ "$youtubeAddressOne" -eq 1 ]]; then
        inputA=$1
        inputB=$2
        validateDates "$inputB"
    elif [[ "$youtubeAddressTwo" -eq 1 ]]; then
        inputA=$2
        inputB=$1
        validateDates "$inputB"
    elif [[ "$youtubeAddressOne" -eq 1 ]] && [[ "$youtubeAddressTwo" -eq 1 ]]; then
        echo "Please only pass 1 web address"
    elif [[ "$youtubeAddressOne" -eq 0 ]] && [[ "$youtubeAddressTwo" -eq 0 ]]; then
        echo "NO WEB ADDRESS PASSED! UNACCEPTABLE!"
        exit 3
    else
        echo "SOMETHING TERRIBLE HAPPENED! Might want to tell the developer about this..."
        exit 9
    fi
}

validateDates(){
    # Allow user to pass the + or not, but DONT allow them to pass negative
    # TODO Need to allow for months
    dateUtilPlusTime=$(echo "$inputB" | grep -icE "\+[[:digit:]]{1,}[smh]{1}")
    dateUtilNoPlusTime=$(echo "$inputB" | grep -icE "[[:digit:]]{1,}[smh]{1}")
    dateUtilPlusDate=$(echo "$inputB" | grep -icE "\+[[:digit:]]{1,}[dwy]{1}")
    dateUtilNoPlusDate=$(echo "$inputB" | grep -icE "[[:digit:]]{1,}[dwy]{1}")
    dateUtilNegitive=$(echo "$inputB" | grep -c "\-")

    nowTime=$(date +"%H:%M:%S")
    nowDate=$(date +"%Y-%m-%d")

    if [[ $dateUtilNegitive -eq 1 ]]; then
        echo "You passed a negative value!"
        echo "An alarm cant alarm you in the past!"
        exit 3
    elif [[ $dateUtilPlusTime  -eq 1 ]]; then
        alarm=$(dateadd "$nowTime" "$inputB")
        dateadd "$nowTime" "$inputB"
    elif [[ $dateUtilNoPlusTime -eq 1 ]]; then
        alarm=$(dateadd "$nowTime" +"$inputB")
    elif [[ $dateUtilPlusDate  -eq 1 ]]; then
        alarm=$(dateadd "$nowDate" "$inputB")
        dateadd "$nowDate" "$inputB"
    elif [[ $dateUtilNoPlusDate -eq 1 ]]; then
        alarm=$(dateadd "$nowDate" +"$inputB")
    else
        echo "You didn't pass a time value!"
        exit 3
    fi
}

userInput "$@"
