##Freepbx for docker running on Alpine 3.2

#####Command to use with this image :

*docker run -d --name bind9 -p 53:53 -p 53:53/udp -v /absolute/paht/named.conf:/etc/bind/named.conf -v /absolute/path/exemple.com.db:/etc/bind/exemple.com.db resystit/bind9:latest*
