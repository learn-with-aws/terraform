jenkins_status=$(rpm -qa | grep jenkins | wc -l)
echo ${jenkins_status}
if (( ${jenkins_status} > 0 ))
then
        echo "Jenkins already Installed"
else
        echo "Jenkins Not Installed. Doing it Now"
        sudo chmod +x /tmp/jenkins_install.sh
        sudo sh /tmp/jenkins_install.sh
fi