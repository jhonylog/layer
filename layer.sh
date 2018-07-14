#!/bin/bash
clear
echo ".:: Tambah dan Hapus Domain Layer v.2.0 ::."
echo "=============== For your Info ==============="
echo "# Ini khusus yg manage VPS nya pakai EasyEngine, diluar itu silahkan dioprek"
echo "================ TASK LIST ================"
echo "1. Tambah domain layer"
echo "2. Lihat daftar domain layer"
echo "3. Hapus domain layer"
echo ""
echo -n "Silahkan pilih Tasknya [1-3] : "
read task
case $task in
	1 )
		clear
		echo ".:: Tambah domain layer ::."
		echo "=============== For your Info ==============="
		echo "# isi domain tanpa http://"
		echo "# kalo domain layernya banyak, pisahkan dengan koma dan spasi (hi.tk, ho.tk, he.tk)"
		echo "# Hati-hati dalam pengisian, selalu pastikan sebelum pencet enter"
		echo "# Karena, tidak diterapkan filter/konfirmasi .. ^_^"
		echo "-------------------------------------------------------"
		echo -n "Domain master [domain WP yg mau dilayer]? "
		read target
		echo -n "Domain yang mau dipointing [isi 1 atau lebih]? "
		read domain
		IFS=', ' read -r -a array <<< "$domain"
		for layer in "${array[@]}"
		do
		    echo -e "server {\n\n\tserver_name $layer\twww.$layer;\n\n\taccess_log /var/log/nginx/$layer.access.log rt_cache;\n\terror_log /var/log/nginx/$layer.error.log;\n\n\troot /var/www/$target/htdocs;\n\n\n\tindex index.php index.html index.htm;\n\n\tinclude common/php.conf;\n\tinclude common/wpcommon.conf;\n\tinclude common/locations.conf;\n\tinclude /var/www/$target/conf/nginx/*.conf;\n}" > /etc/nginx/sites-enabled/$layer
			echo -e "server {\n\n\tserver_name $layer\twww.$layer;\n\n\taccess_log /var/log/nginx/$layer.access.log rt_cache;\n\terror_log /var/log/nginx/$layer.error.log;\n\n\troot /var/www/$target/htdocs;\n\n\n\tindex index.php index.html index.htm;\n\n\tinclude common/php.conf;\n\tinclude common/wpcommon.conf;\n\tinclude common/locations.conf;\n\tinclude /var/www/$target/conf/nginx/*.conf;\n}" > /etc/nginx/sites-available/$layer
			echo "$layer => $target" >> /etc/nginx/layerdomain
			echo "domain $layer has been pointed to $target root folder"
		done
		sudo service nginx restart
		echo "WARNING!! Opsi ini hanya dilakukan sekali saja."
		echo -n "Inject script layer ke /var/www/$target/wp-config.php [y or n] ? "
		read inject
		case $inject in
			[yY] )
				sed -i "35i /*Handle multi domain*/ define('WP_SITEURL', 'http://' . \$_SERVER['HTTP_HOST']); define('WP_HOME', 'http://' . \$_SERVER['HTTP_HOST']);" /var/www/$target/wp-config.php
				injectLog="Script telah terinject di /var/www/$target/wp-config.php line 35"
				;;
			[nN] )
				injectLog="Dilewati"
				;;
			*) injectLog="Dilewati"
				;;
		esac
		echo "=========== INFO ============"
		echo "Task complete, silahkan cek folder dibawah untuk memastikan"
		echo -e "\t/etc/nginx/sites-enabled/"
		echo -e "\t/etc/nginx/sites-available/"
		echo "Inject script : $injectLog"
		echo "File log layer : /etc/nginx/layerdomain"
		;;

	2 )
		clear
		echo ".:: LIST domain layer ::."
		echo "=========================="
		echo "Layer   =>   Master"
		echo "---------------------------"
		cat /etc/nginx/layerdomain
		echo "---------------------------"
		echo "File log layer : /etc/nginx/layerdomain"
		;;
	
	3 )
		clear
		echo ".:: Hapus domain layer ::."
		echo "=============== For your Info ==============="
		echo "# isi domain tanpa http://"
		echo "# kalo domain layernya banyak, pisahkan dengan koma dan spasi (hi.tk, ho.tk, he.tk)"
		echo "# Hati-hati dalam pengisian, selalu pastikan sebelum pencet enter"
		echo "# Karena, tidak diterapkan filter/konfirmasi .. ^_^"
		echo "==== LIST domain Layer ===="
		echo "Layer   =>   Master"
		echo "---------------------------"
		cat /etc/nginx/layerdomain
		echo "-------------------------------------------------------"
		echo -n "Domain layer yang akan dihapus [isi 1 atau lebih]? "
		read domain
		IFS=', ' read -r -a array <<< "$domain"
		for layer in "${array[@]}"
		do
		    rm -rf /etc/nginx/sites-enabled/$layer
			rm -rf /etc/nginx/sites-available/$layer
			sed -i "/$layer/d" /etc/nginx/layerdomain
		done
		sudo service nginx restart
		echo "Task complete, silahkan cek folder dibawah untuk memastikan"
		echo -e "\t/etc/nginx/sites-enabled/"
		echo -e "\t/etc/nginx/sites-available/"
		;;
	*) echo "Mohon maaf, Task yang anda pilih tidak ada."
		;;
esac