#/bin/bash

fileValidate(){
if [ -f $1 ];then

  return 0

else

   echo "File not exists in `pwd` or entered wrong file Name. Please Check";
   return 1;

fi
}

jmxUploader(){

jmxUpload=true

while $jmxUpload;

do
	rm -rf JMX.csv
        read -p "Enter jmx file: " jmxFile

        fileValidate $jmxFile

        if [ $? != 0 ]; then

                jmxUpload=true;

        else
		jmxFetch=`cat clusters.csv`

		for i in $jmxFetch
 		
		do
		
		tenant=`echo $i | awk -F ',' '{ print $5 }'`
		
		clusterName=`echo $i | awk -F ',' '{ print $1 }'`

		zoneSelect=`echo $i | awk -F ',' '{ print $2 }'`

		gcloud container clusters get-credentials $clusterName --zone $zoneSelect --project etsyperftesting-208619

                master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`

                kubectl cp $jmxFile -n $tenant $master_pod:/$jmxFile

                echo "JMX Copy process completed on $tenant"
		
		echo "$jmxFile" > JMX.csv		

                jmxUpload=false
		
		done

        fi

done

}

csvUploader(){
rm -rf file.csv

read -p "Do you have csv file [y/n] " csvStatus

csvUpload=true

while $csvUpload;

do

	if [[ $csvStatus == 'y' || $csvStatus == 'Y' ]];then

		csvVerify=true

		while $csvVerify;

		do

		read -p "Enter csv file : " csv

		fileValidate $csv

			if [ $? != 0 ]; then

                		csvVerify=true

        		else

				csvVerify=false

			fi
                done
		echo $csv >> file.csv

		read -p "Do you have Extra CSV [Y/n]: " multiCSV

        		if [[ $multiCSV == 'y' || $multiCSV == 'Y' ]]; then

                		csvUpload=true;

        		elif [[ $multiCSV == 'n' || $multiCSV == 'N' ]]; then

				copyCSVfiles

                		csvUpload=false;

        		else

                		echo "Enter a valid response Y or N: "

                		csvUpload=true;

        		fi

	elif [[ $csvStatus == 'n' || $csvStatus == 'N' ]];then

		csvUpload=false

	else

   		echo  "Enter a valid response y or n ";

   		csvUpload=true

	fi
done

}

copyCSVfiles() {

csvCopy=`cat clusters.csv`

for i in $csvCopy

do
tenant=`echo $i | awk -F ',' '{ print $5 }'`

clusterName=`echo $i | awk -F ',' '{ print $1 }'`

zoneSelect=`echo $i | awk -F ',' '{ print $2 }'`

gcloud container clusters get-credentials $clusterName --zone $zoneSelect --project etsyperftesting-208619

slave_pod=`kubectl get po -n $tenant | grep jmeter-slave | awk '{print $1}'`

echo "Copying CSV files to the $tenant..."

for i in $slave_pod

do

kubectl exec -ti -n $tenant $i -- mkdir -p /jmeter/apache-jmeter-5.0/bin/csv/

copyCSV=`cat file.csv`

for j in $copyCSV

do

kubectl cp $j -n $tenant $i:/jmeter/apache-jmeter-5.0/bin/csv/$j

echo "$j Copied on $tenant"

done

done

done

}

uploads=true

while $uploads;

do

read -p "Do you want to upload the files [Y/n] : " copy

	if [[ $copy == "y" || $copy == "Y" ]]; then
		jmxUploader
		csvUploader
		uploads=false		
		#exit 0;
	elif [[ $copy == "n" || $copy == "N" ]]; then
		uploads=false
	else
		echo "Select Valid input"
		uploads=true

	fi

done

