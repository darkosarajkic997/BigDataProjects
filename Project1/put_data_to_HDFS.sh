#$1 path of file to be uploaded to HDFS *REQUIRED*

if [ $# -ne 1 ]
        then
                echo [ERROR]: One argument required - path to file which contains dataset that is going to be uploaded to HDFS!
                exit 1
fi

echo [INFO]: File "$1" will be copied to temporary /dataset directory on namenode container


 
docker exec -it namenode sh -c "test -d /dataset"

if [ $(docker exec -it namenode echo $?) -ne 0 ]
	then
		echo [INFO]: Creating non persistent /dataset directory
		docker exec -it namenode  mkdir /dataset
fi


docker cp "$1" namenode:/dataset/
echo [INFO]: File is successfully copied to namenode container /dataset directory

docker exec -it namenode hdfs dfs -test -e  /data/"$(basename $1)"
if [ $? -ne 0 ]
	then
		echo [INFO]: Uploading data to HDFS
		docker exec -it namenode hdfs dfs -D dfs.replication=2 -put /dataset/"$(basename $1)" /data
		echo [INFO]: Data uploaded to HDFS
	else
		echo [INFO]: File with same name already exist on HDFS
fi


