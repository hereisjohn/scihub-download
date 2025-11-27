# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#!/usr/bin/bash
# ^^^^^^^^^^^  pragma from which bash
#
#
# Files:
# sci-hub-sites.txt    list of scihub sites that are likely to work.Update manually, or from reddit
# doi-list.txt         list of DOIs to fetch
# sci-hubs-success.txt list of hubs successfully reached
# sci-hubs-fail.txt    list of hubs not reached
# dois_not_fetched.txt list of DOI docs not fetched.
# dois_fetched.txt     list of DOI docs fetched.
#
#initialize files
touch sci-hub-sites.txt
touch doi-list.txt
touch sci-hubs-success.txt
touch sci-hubs-fail.txt
touch dois_not_fetched.txt
touch dois_fetched.txt
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
##
#
urlencode() {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

#scihubok='https://sci-hub.se/'
readarray -t scihubs < ./sci-hub-sites.txt
readarray -t list < ./doi-list.txt

#see if scihub sites are up or down
echo "Testing scihubs...."
for scihub in "${scihubs[@]}"
do
 echo " test hub $scihub..."
 #curl -s --head --request GET $scihub
 curl --head --request GET $scihub
    if [ $? -eq 0 ]; then
     echo " curl returns success to $scihub"
     #echo " Website is up $scihub"
     # Use this one
     scihubok=$scihub
     echo $scihub >> sci-hubs-success.txt
    else
     echo " curl fails to connect to $scihub"
     echo $scihub >> sci-hubs-fail.txt
    fi
    #Set target to latest good scihub
done
#at some point, youll want to deduplicate the list or update it

scihubok='https://sci-hub.se/'
echo "Beginning downloads from $scihubok"
for doi in "${list[@]}"
do
    echo " ============================================="
    echo " Download for doi: $(urlencode $doi)"
    echo " doi is $doi"
    # Parse Scihub and Get url of the PDF filename  into a variable
    # A bash script can be used to download scientific papers from Sci-Hub using curl by automating the
    # process of sending DOI requests and following redirects to obtain PDF links. The script typically reads a
    # list of DOIs from a file, URL-encodes each DOI, and sends a POST request to Sci-Hub's server with appropriate
    # headers to mimic a browser request.
    #
    link=$(curl -s -L "$scihubok" --compressed \
        -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:75.0) Gecko/20100101 Firefox/75.0' \
        -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
        -H 'Content-Type: application/x-www-form-urlencoded' \
        -H "Origin: $scihubok" \
        -H 'DNT: 1' \
        -H 'Connection: keep-alive' \
        -H "Referer: $scihubok" \
        -H 'Cookie: __ddg1=SFEVzNPdQpdmIWBwzsBq; session=45c4aaad919298b2eb754b6dd84ceb2d; refresh=1588795770.5886; __ddg2=6iYsE2844PoxLmj7' \
        -H 'Upgrade-Insecure-Requests: 1' \
        -H 'Pragma: no-cache' \
        -H 'Cache-Control: no-cache' \
        -H 'TE: Trailers' \
        --data "sci-hub-plugin-check=&request=$(urlencode $doi)". | grep -oP  "(?<=//).+(?=#)")

    echo " Found link: $link"
    if [ -z "$link" ]; then
     echo " PDF link Variable is empty or null. Writing to non fetched file dois_not_fetched."
     #save to another file of pdfs not fetched
     echo "$doi" >> ./dois_not_fetched
    else
     echo " PDF location variable is not empty. Attempting to fetch PDF $link"
     curl  $link --output $(urlencode $doi).pdf
     #check success
     status="$?"
     echo $status
     if [ $status -eq 0 ]; then
        echo "$doi" >>./dois_fetched.txt
        echo " PDF download success!!  <<<<<<<<<<<<<<<<"
        echo "    curl status is $status"
        ls -ltr $(urlencode $doi).pdf
     else
        echo " PDF download FAIL."
     fi
    fi
done # done with list of doi PDFs to fetch

# dois_not_fetched     is a list of DOI docs not fetched.
# sci-hubs-success.txt list of hubs successfully reached
sort -u dois_fetched.txt -o dois_fetched.txt
sort -u dois_not_fetched.txt -o dois_not_fetched.txt
sort -u sci-hubs-success.txt -o sci-hubs-success.txt
sort -u sci-hub-sites.txt -o sci-hub-sites.txt
echo "+-------------------------------------------------------------------------------------------+"
echo "| S U M M A R Y :                                                                           |"
echo "|                                                                                           |"
echo "| Successful scihub sites polled $(wc -l sci-hubs-success.txt) out of $(wc -l scihub-sites.txt) "
#echo "| Successful scihub sites polled $(sort -u sci-hubs-success.txt|wc -l) out of $(sort -u sci-hub-sites.txt|wc -l) "
#echo "| UnSuccessful scihub sites polled $(wc -l sci-hubs-fail.txt) "
echo "| DOIs     fetched: $(wc -l dois_fetched.txt)"
echo "| DOIs not fetched: $(wc -l dois_not_fetched.txt)"
echo "|                                                                                           |"
echo "| list of PDFs downloaded: "
echo "|                                                                                           |"
cat dois_fetched.txt
echo "+-------------------------------------------------------------------------------------------+"

#
exit
