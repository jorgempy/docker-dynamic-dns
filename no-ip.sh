#!/bin/bash 

if [ -z "$USER" ]
then
	echo "No user was set. Use -u=username"
	exit 10
fi

if [ -z "$PASSWORD" ]
then
	echo "No password was set. Use -p=password"
	exit 20
fi


if [ -z "$HOSTNAME" ]
then
	echo "No host name. Use -h=host.example.com"
	exit 30
fi


if [ -n "$DETECTIP" ]
then
	IP=$(wget -qO- "http://myexternalip.com/raw")
fi


if [ -n "$DETECTIP" ] && [ -z $IP ]
then
	RESULT="Could not detect external IP."
fi


if [[ $INTERVAL != [0-9]* ]]
then
	echo "Interval is not an integer."
	exit 35
fi

USERAGENT="--user-agent=\"no-ip shell script/1.0 mail@mail.com\""
BASE64AUTH=$(echo '"$USER:$PASSWORD"' | base64)
AUTHHEADER="--header=\"Authorization: $BASE64AUTH\""


#echo "$AUTHHEADER $USERAGENT $NOIPURL"
LASTIP=""
while :
	do
		if [ -n "$DETECTIP" ]
	then
		IP=$(wget -qO- "http://myexternalip.com/raw")
	fi


	if [ -n "$DETECTIP" ] && [ -z $IP ]
	then
		RESULT="Could not detect external IP."
	else
		if [ "$LASTIP" != "$IP" ]; then
			case "$SERVICE" in
		        dynu)

					# TODO
		            SERVICEURL="dynupdate.no-ip.com/nic/update"
		            ;;

		        duckdns)
					RESULT=$(wget --no-check-certificate -qO- $USERAGENT https://www.duckdns.org/update?domains=$HOSTNAME\&token=$USER\&ip=$IP\&verbose=true)
		            ;;
		        *)
					SERVICEURL="dynupdate.no-ip.com/nic/update"
		 
			esac
		else
			RESULT="IP unchanged, not updated"
		fi
	fi

	LASTIP="$IP"
	#RESULT=$(wget --no-check-certificate -qO- $AUTHHEADER $USERAGENT $NOIPURL)
	

	
	echo $RESULT
	

	if [ $INTERVAL -eq 0 ]
	then
		break
	else
		sleep "${INTERVAL}m" 
	fi

done

exit 0
