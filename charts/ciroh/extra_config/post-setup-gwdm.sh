#!/bin/bash

# install gdal etc
add-apt-repository ppa:ubuntugis/ppa && apt-get update
apt-get install -y  gdal-bin
apt-get install -y  libgdal-dev
# export CPLUS_INCLUDE_PATH=/usr/include/gdal
# export C_INCLUDE_PATH=/usr/include/gdal
# install dependencies for python script
pip install --upgrade pip
pip install geoserver-rest


#define arguments to call the python script
args=(
    -gh=$TETHYS_GS_PROTOCOL://$TETHYS_GS_HOST 
    -p=$TETHYS_GS_PORT 
    -u=$TETHYS_GS_USERNAME 
    -pw=$TETHYS_GS_PASSWORD 
    -s=$GWDM_STORE_NAME 
    -w=$GWDM_WORKSPACE_NAME 
    -db=$GWDM_TABLE_NAME 
    -dbp=$TETHYS_DB_PORT 
    -dbh=$TETHYS_DB_HOST 
    -dbu=$POSTGRES_USER 
    -dbpw=$POSTGRES_PASSWORD 
    -rt=$GWDM_REGION_LAYER_NAME 
    -at=$GWDM_AQUIFER_LAYER_NAME 
    -wt=$GWDM_WELL_LAYER_NAME
    )

# the following from this file: https://tecadmin.net/write-append-multiple-lines-to-file-linux/    
# create the file
touch post_setup_gwdm.py

# add the content to the file
cat > post_setup_gwdm.py << EOL
import sys
import argparse
from geo.Geoserver import Geoserver
import logging

logging.basicConfig(
    level=logging.ERROR, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


def creat_and_init_gwdm(argv):
    parser = argparse.ArgumentParser(
        description="Create and initialize GWDM",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="Example: {0} -gh <gs_host> -p <port> -u <user> -pw <password> -s <store_name> -w <workspace> -db <db_name> -dbp <db_port> -dbh <db_host> -dbu <db_user_name> -dbpw <db_password> -rt <region_table> -at <aquifer_table> -wt <wells_table>".format(
            argv[0]
        ),
    )
    parser.add_argument("-gh", "--gs_host", help="Geoserver host")
    parser.add_argument("-p", "--port", help="Port number")
    parser.add_argument("-u", "--user", help="Geoserver username")
    parser.add_argument("-pw", "--password", help="Geoserver password")
    parser.add_argument("-s", "--store_name", help="Store name")
    parser.add_argument("-w", "--workspace", help="Workspace")
    parser.add_argument("-db", "--db_name", help="Database name")
    parser.add_argument("-dbp", "--db_port", help="Database port")
    parser.add_argument("-dbh", "--db_host", help="Database host")
    parser.add_argument("-dbu", "--db_user_name", help="Database username")
    parser.add_argument("-dbpw", "--db_password", help="Database password")
    parser.add_argument("-rt", "--region_table", help="Region table")
    parser.add_argument("-at", "--aquifer_table", help="Aquifer table")
    parser.add_argument("-wt", "--wells_table", help="Wells table")

    args = parser.parse_args(argv[1:])

    geo = Geoserver(
        f"{args.gs_host}:{args.port}/geoserver-cloud",
        username=args.user,
        password=args.password,
    )

    geo.create_workspace(workspace=args.workspace)

    geo.create_featurestore(
        store_name=args.store_name,
        workspace=args.workspace,
        db=args.db_name,
        host=args.db_host,
        port=args.db_port,
        pg_user=args.db_user_name,
        pg_password=args.db_password,
    )

    geo.publish_featurestore(
        workspace=args.workspace,
        store_name=args.store_name,
        pg_table=args.region_table,
    )
    geo.publish_featurestore(
        workspace=args.workspace,
        store_name=args.store_name,
        pg_table=args.aquifer_table,
    )
    geo.publish_featurestore(
        workspace=args.workspace,
        store_name=args.store_name,
        pg_table=args.wells_table,
    )


if __name__ == "__main__":
    try:
        creat_and_init_gwdm(sys.argv)
    except Exception as e:
        logger.error("An error occurred", exc_info=True)


EOL
# python <<EOF
# python content here as well
# EOF "${args[@]}"
# -gh $TETHYS_GS_PROTOCOL://$TETHYS_GS_HOST -p $TETHYS_GS_PORT -u $TETHYS_GS_USERNAME -pw $TETHYS_GS_PASSWORD -s $GWDM_STORE_NAME -w $GWDM_WORKSPACE_NAME -db $GWDM_TABLE_NAME -dbp $TETHYS_DB_PORT -dbh $TETHYS_DB_HOST -dbu $POSTGRES_USER -dbpw $POSTGRES_PASSWORD -rt $GWDM_REGION_LAYER_NAME -at $GWDM_AQUIFER_LAYER_NAME -wt $GWDM_WELL_LAYER_NAME


# lets wait for the geoserver-cloud to start before executing the script, and when is ready let's called it
service_url="${TETHYS_GS_PROTOCOL}://${TETHYS_GS_HOST}:${$TETHYS_GS_PORT}/geoserver-cloud/"
retry_interval=30

while true; do
    if curl --output /dev/null --silent --head --fail "$service_url"; then
        echo "Connection to $service_url is ready!"
        echo "Settign up gwdm geoserverf store"
        python post_setup_gwdm.py "${args[@]}"

        # Continue with your script logic here
        break  # Exit the loop since the connection is ready
    else
        echo "Waiting for connection to $service_url..."
        sleep "$retry_interval"
    fi
done
