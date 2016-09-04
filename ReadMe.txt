First Run ./MasterScript.sh
        Engine.pl will be called by ./MasterScript.sh.. 
You need to point ./MasterScript.sh to the location of .ucs file(s). In my case, i have a folder called F5LoadBalancers which contain folders of all LB's and within them their .ucs file. The script will unzip them, find bigip.conf, parse them and output VIP and Members. 
