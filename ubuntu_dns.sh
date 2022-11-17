#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function salida(){
	clear
	echo -en "\n\n${yellowColour}[${endColour}${redColour}*${endColour}${yellowColour}]${endColour} No eres root!\n\n"
	exit 0
}

#aa
###########################################################################################################################
#################################### FLUJO DEL PROGRAMA @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
###########################################################################################################################


function saludo(){
	echo -en "\nCreación de un DNS\n\n"
	sleep 4
	echo -e "\n\nEmpezando configuración\n\n"
	#Cración del fichero named.conf.options
	org
}

#Flujo de salida del programa ctrl + c

trap ctrl_c INT

function ctrl_c (){
	tput civis
	clear
	echo -e "\n\n${yellowColour}[${endColour}${redColour}!${endColour}${yellowColour}]${endColour} Saliendo...\n\n"
	tput cnorm
	exit 1
}


###########################################################################################################################
################## ORGANIZACION  DEL PROGRAMA #############################################################################
###########################################################################################################################

# Con un mv se sobreescribe el Archivo preexistente

function dir_ip(){
	ip_d_red=$(ip a | grep 2 | grep -oP '\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}' | awk 'NR==2')
	ip_d_s=$(echo $ip_d_red | cut -d '.' -f 1,2,3)
	ip_cero=$(echo $ip_d_s".0")
	cidr=$(ip a | grep 2 | grep -oP '\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}/\d{1,2}' | awk 'NR==2')
	ip_new_use=$(echo $ip_d_s.34)
}







function packages(){
	echo -en "Comprobando Herramientas Utiles:\n"
	echo -en "bind9........................"
	test -f /etc/systemd/system/bind9.service 
	if [[ $(echo $?) == '0' ]];then
		echo -e "(V)"
	else
		echo -e "(X)"
		sudo apt-get install bind9 > /dev/null 2>&1
	fi
	echo -en "bind9-utils.................."
	test -f /etc/systemd/system/bind9.service 
	if [[ $(echo $?) == '0' ]];then
		echo -e "(V)"
	else
		echo -e "(X)"
		sudo apt-get install bind9 > /dev/null 2>&1
	fi
}

function org(){ 
	dir_ip
	clear
	echo -e "Asignación de NOMBRE a IP"
	echo -en "Default:\n"
	echo -en "\tIP\t\t\t====>\t\t$ip_new_use\n"
	echo -en "\tNombre\t\t\t====>\t\tsite\n"
	echo -en "\tDireccion de Red\t====>\t\t$ip_cero\n"
	ip="$ip_new_use"
	echo -en "Ip:\n==> " && read ip
	name="site"
	echo -en "Nombre:\n==> " && read name
	clear
	echo -e "[*] Direcciones de Red:"
	for i in $(ip a | grep -oP "(^\d)(.+)([a-z]\d{1,3})" | cut -d ":" -f 2);do
		echo -e "==> $i"
	done


	interfaz=$(ip a | grep -oP "(^\d)(.+)([a-z]\d{1,3})" | cut -d ":" -f 2 | awk 'NR==1')

	echo -en "Escoge una interfaz:\n==> " && read interfaz


	d_red_cidr=$(ip a | grep $interfaz | grep -oP "\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}\/\d{1,3}")
	ip_a=$(ip_Replace=$(echo $d_red_cidr | cut -d "." -f 4); echo $ip_Replace | cut -d "/" -f 1)
	d_red_cidr_cero=$(echo  "${d_red_cidr//$ip_a/"0"}")
	d_red=$(d=$(echo $d_red_cidr_cero | cut -d "/" -f 1); echo $d | cut -d "." -f 1,2,3)
	echo $d_red_cidr_cero
	echo $d_red
	echo -en "Direccion de Red en la que trabaja:\t($d_red_cidr_cero)\n==> " && read d_red
	
#Grepear por la ip
	packages
	ip_se=$(echo "$ip_cero" | grep -oP "\d{1,3}.\d{1,3}.\d")
	f_ip=$(echo $ip_se | awk -F '.' '{print $3}')
	s_ip=$(echo $ip_se | awk -F '.' '{print $2}')
	t_ip=$(echo $ip_se | awk -F '.' '{print $1}')
	interfaces
	named 1
	zonas
	serial=$(date +"%Y%m%d")
	db_name=$(echo "db."$name".com")
	site_name=$(echo "db."$name".com")
	db_reverse_ip=$(echo "db."$ip_se)
	echo $db_name
	echo $site_name
	echo $db_reverse_ip
	#######################################################################
		# Creando los fichero de zonas #
	#######################################################################

	zonas_settings
	zonas_settings_reversa
}

function interfaces(){
	echo -e "options {" >> named.conf.options
	echo -e '\tdirectory "/var/chache/bind"; ' >> named.conf.options
	echo -e "\tallow-query { localhost; $d_red_cidr_cero; }; " >> named.conf.options
	echo -e "\tforwarders {" >> named.conf.options
	echo -e "\t\t1.1.1.1;" >> named.conf.options
	echo -e "\t\t8.8.8.8;" >> named.conf.options
	echo -e "\t};" >> named.conf.options
	echo -e "\n" >> named.conf.options
	echo -e "\tdnssec-validation no;" >> named.conf.options
	echo -e "\tlisten-on { any; }; " >> named.conf.options
	echo -e "\tlisten-on-v6 { any; }; " >> named.conf.options
	echo -e "};" >> named.conf.options
}
function named(){ 
	echo -e "RESOLVCONF=no" >> named
	echo -e "\n" >> named
	echo -e "OPTIONS='-u bind -4'" >> named
}

function internet(){
	clear
	echo -e '\n\nComprobando Conexión wifi\n\n'
	ping -c 1 google.com > /dev/null 2>&1
	if [[ $(echo $?) == '0' ]];then
		echo -e "\nTienes conexion"
	else
		echo -e "\nNo tienes conexion"
	fi
}

function validar(){
	res=$1
	if [[ $res == '1' ]];then
		echo "Validando configuración "
		sudo named-checkconf
		if [[ $(echo $?) != '0' ]]; then
			echo -e "Ah petado"
		else
			echo -e "Toda la configuración esta bien hecha"
			bind9_res_sta
		fi
	else
		sudo named-scheckzone $name.com /etc/bind/zonas/db.$name.com
		sudo named-checkzone db.$f_ip.$s_ip.$t_ip.in-addr.arpa /etc/bind/zonas/db.$ip_se
		bind9_res_sta
		internet
	fi
}
function bind9_res_sta(){
	sudo systemctl restart bind9
	sudo systemctl status bind9
}

#Creación de las zonas
#Archivo named.conf.local
function zonas(){
	echo -e 'zone "$name.com" IN {' >> named.conf.local
	echo -e "\ttype master;" >> named.conf.local
	echo -e '\tfile "/etc/bind/zonas/db.$name.com"; ' >> named.conf.local
	echo -e "};" >> named.conf.local
	echo -e 'zone "$f_ip.$s_ip.$t_ip.in-addr.arpa" {' >> named.conf.local
	echo -e "\ttype master; " >> named.conf.local
	echo -e '\tfile "/etc/bind/zonas/db.$t_ip.$s_ip.$f_ip"; ' >> named.conf.local
	echo -e "}; " >> named.conf.local
}

#Configuracion de la zona y la reversa 'IP'

function zonas_settings(){
#	cd /etc/bind > /dev/null 2>&1
#	mkdir zonas > /dev/null 2>&1
	cd !$ > /dev/null 2>&1
	echo -e "\$TTL\t1D" >> $site_name
	echo -e "@\tIN\tSOA\tpage.$name.com. admin.$name.com. (" >> $site_name
	echo -e "\t$serial\t; Serial" >> $site_name
	echo -e "\t12h\t\t; Refresh " >> $site_name
	echo -e "\t15m\t\t; Retry" >> $site_name
	echo -e "\t3w\t\t; Expire" >> $site_name
	echo -e "\t2h  )\t\t; Negative Cache TTL" >> $site_name
	echo -e "\n" >> $site_name
	echo -e "\tIN\tNS\tpage.$name.com." >> $site_name
#Direcciones Ips a las que apuntara el DNS
#aa
	echo -e "page\tIN\tA\t$ip" >> $site_name
	echo -e "www\tIN\tA\t$ip"  >> $site_name

}

function zonas_settings_reversa(){
	
#	cd /etc/bind > /dev/null 2>&1
#	cd zonas > /dev/null 2>&1
	echo -e "\$TTL\t1D  ; " >> db.$ip_se
	echo -e "@\tIN\tSOA\tpage.$name.com.  admin.$name.com. (" >> db.$ip_se
	echo -e "\t\t$serial\t; Serial" >> db.$ip_se
	echo -e "\t\t12h\t\t; Refresh " >> db.$ip_se
	echo -e "\t\t15m\t\t; Retry " >> db.$ip_se
	echo -e "\t\t3w\t\t; Expire " >> db.$ip_se
	echo -e "\t\t2h\t)\t; Negative Cache TTL" >> db.$ip_se
	echo -e "\n" >> db.$ip_se
	echo -e "@\tIN\tNS\tpage.$name.com. " >> db.$ip_se
	echo -e "$(echo $ip | cut -d "." -f 4)\tIN\tPTR\tpage.$name.com. " >> db.$ip_se
}



if [[ $(id -u) != '0' ]];then
	salida
else
	saludo
fi
