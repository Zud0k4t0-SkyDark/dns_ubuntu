;
; Configurando mi servidor propio
;
;	Servidor Casero DE DNS
;
;	server.com
$TTL	604800
@	IN	SOA	server.com. admin.server.com. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	server.com.

;cliente	IN	A	192.168.1.106
servidor	IN	A	192.168.1.108
;cliente2	IN	A	192.168.1.108
;dominio.amazon.	IN	A	192.168.1.106

;Servidor del Arch
server.com.	IN	A	192.168.1.108
ns1	IN	CNAME	server.com.

ucl	IN	A	192.168.1.106
u_cl	IN	CNAME	ucl


;ns1	IN	CNAME	dominio.amazon.
;www	IN	CNAME	servidor
;cl	IN	CNAME	cliente
;dominio.amazon	IN	CNAME	cliente2
