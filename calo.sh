start=`date +%s`
calo /dev/ttyUSB1 $1
stop=`date +%s`
echo "upload time: $((stop-start)) sec."

