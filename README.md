Do which bash to find bash in your environment and fix line 1: 
#!/usr/bin/bash

Create these files using touch filename. Or run the script, and it will have errors but will create them.

     scihub-download.sh  this file, based on https://janikvonrotz.ch/2020/05/07/bulk-download-papers-from-scihub-for-text-mining/
     sci-hub-sites.txt    list of scihub sites that are likely to work.Update manually, or from reddit
     doi-list.txt         list of DOIs to fetch
     sci-hubs-success.txt list of hubs successfully reached
     sci-hubs-fail.txt    list of hubs not reached
     dois_not_fetched.txt list of DOI docs not fetched.
     dois_fetched.txt     list of DOI docs fetched.

example input files:

    touch sci-hub-sites.txt
    touch doi-list.txt
    touch sci-hubs-success.txt
    touch sci-hubs-fail.txt
    touch dois_not_fetched.txt
    touch dois_fetched.txt

This shell script will take a list of DOIs in a file, and download them from sci-hub
Since sci-hub goes down and reappears with new URLs constantly, you have to maintain a list of good
scihub sites. The script will go through that file to find a good one.

To do the download, the script will 

    1 read a list of scihub urls and find a good one
    2 read a list of DOIs of documents and try to get them by DOI from scihub
     by getting a remote PDF filename then use curl to fetch the file down.
    3 Keeps a list of those DOI that it fails to locate or download, so you can try again later
     or use some other methods

 Output files:
 
     dois_not_fetched     is a list of DOI docs not fetched.
     sci-hubs-success.txt list of hubs successfully reached
     possible scihub sites in sci-hub-sites.txt, so you will have to maintain that one over time

 If those sites have all become defunct, you might try here for more scihub sites or try telegram
 reddit or your other sources. 

 You'll have to install things like curl:
 sudo apt install curl
 sudo apt install wget
 sudo apt install python3-full
 
