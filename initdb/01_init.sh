#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

create_databases(){
	echo
	echo "======= CREATING DATABASES ======="
	for database in $(jq '.databases | .[]' $CONFIG_PATH); do
		echo "CREATE DATABASE $database";
		psql -d template1 -U postgres -c "CREATE DATABASE $database"; 
	done
}

create_users(){
	echo
	echo "======= CREATING USERS ======="
	for login in $(jq -c '.logins[]' $CONFIG_PATH); do 
		username=$(jq -c '.username' <<< $login);
		password=$(jq -c '.password' <<< $login);
		echo "CREATE USER $username WITH ENCRYPTED PASSWORD *********"; 
		psql -d template1 -U postgres -c "CREATE USER $username WITH ENCRYPTED PASSWORD '$password'";
	done
}

create_permissions(){
	echo
	echo "======= CREATING PERMISSIONS ======="
	sql=$(jq -r '.rights[] | "GRANT \(.grant) ON DATABASE \"\(.database)\" TO \"\(.username)\";"' $CONFIG_PATH)

	while IFS=';' read -ra ADDR; do 
		for i in "${ADDR[@]}"; do 
			echo $i;
			psql -d template1 -U postgres -c "$i"; 
		done 
	done <<< "$sql"
}

create_databases
create_users
create_permissions