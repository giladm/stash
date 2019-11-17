# Loop over api_access and search for pattern
#
# change out for output file
# change grep pattern
# change for loop for year/month/day to search
#
out='/users/home/giladm/out/err404.txt';
cd /d2d_backups/prod-server-logs/rapp63.fra02is/app/logs/engage/;
for f in api_access2018-12-*; do
    echo $f>>$out;
    echo consent>>$out;
    zgrep -E '194364/consent.*404' $f |wc >>$out;
    echo contactbychannel>>$out;
    zgrep -E '194364/contactbychannel.*404' $f |wc >>$out ;
done
cd -
