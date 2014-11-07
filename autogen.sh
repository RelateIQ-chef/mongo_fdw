#! /bin/bash

#-------------------------------------------------------------------------
#
# autogen.sh
#             Foreign-data wrapper for remote MongoDB servers
#
# Portions Copyright (c) 2012-2014, PostgreSQL Global Development Group
#
# Portions Copyright (c) 2004-2014, EnterpriseDB Corporation.
#
# IDENTIFICATION
#             autogen.sh
#
#-------------------------------------------------------------------------

if [ "$#" -ne 1 ]; then
    echo "Usage: autogen.sh --[with-legacy | with-master]"
    exit
fi

###
# Pull the latest version of Monggo C Driver's master branch
#
function checkout_mongo_driver
{
	rm -rf mongo-c-driver
	git clone https://github.com/mongodb/mongo-c-driver mongo-c-driver
	git checkout master
}

###
# Pull the legacy branch from the Mongo C Driver's
#
function checkout_legacy_branch
{
	cd mongo-c-driver
	git checkout legacy
	cd ..
}

###
# Configure and install the Mongo C Driver and libbson
#
function install_mongoc_driver
{
	cd mongo-c-driver
	./autogen.sh 
	configure --with-libbson=system
	make install
	cd ..
}

if [ "--with-legacy" = $1 ]; then
	checkout_mongo_driver
	checkout_legacy_branch
	cp Makefile.legacy Makefile
	echo "Done"
elif [ "--with-master" == $1 ]; then
	checkout_mongo_driver
	install_mongoc_driver
	export PKG_CONFIG_PATH=mongo-c-driver/src/:mongo-c-driver/src/libbson/src
	cp Makefile.meta Makefile
	echo "Done"
else
	echo "Usage: autogen.sh --[with-legacy | with-master]"
fi

