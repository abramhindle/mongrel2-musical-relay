URLS="http://localhost:6767 http://localhost:6767/1 http://localhost:6767/12 http://localhost:6767/12/3/4 http://localhost:6767/demos/"
for X in `seq 1 1000`
do
for URL in $URLS
do
echo $URL 
GET $URL &
echo
done
done
