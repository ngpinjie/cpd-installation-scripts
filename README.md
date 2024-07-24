# cpd-installation-scripts
This repository contains a script to automate the setup of IBM Cloud Pak for Data on an OpenShift Container Platform (OCP) cluster. The script installs necessary components, configures environment variables, and sets up required services and projects. Source: https://www.ibm.com/docs/en/cloud-paks/cp-data/4.8.x?topic=overview

# Pre-requisites
1. An OpenShift Container Platform cluster (https://techzone.ibm.com/my/reservations/create/63a3a25a3a4689001740dbb3) with the following resources (https://imgur.com/a/wQEmgbU)
2. Administrator access to the OpenShift cluster
3. IBM Entitlement Key (To fill up in install_cpd.sh Line 34)

# Components Installed
- Docker container runtime
- IBM Cloud Pak for Data command-line interface (cpd-cli)
- Certificate Manager
- License Service
- Scheduling Service
- IBM Cloud Pak foundational services
- Operators and operands for IBM Cloud Pak for Data

## Scripts

### install_cpd.sh

This script performs the following tasks:
1. Installs Docker as the container runtime.
2. Sets up the cpd-cli for IBM Cloud Pak for Data.
3. Creates and sources environment variables for the OpenShift cluster.
4. Updates the global image pull secret with IBM entitlement credentials.
5. Creates necessary projects (namespaces) in OpenShift.
6. Installs Certificate Manager and License Service.
7. Installs the Scheduling Service.
8. Applies CRI-O settings to the cluster.
9. Authorizes instance topology for Cloud Pak for Data.
10. Sets up foundational services and ConfigMaps for Cloud Pak for Data.
11. Installs Cloud Pak for Data platform operators and operands.
12. Retrieves the URL and admin credentials for the Cloud Pak for Data instance.

## Usage
1. (Optional) Run as root user
```
sudo -i
```

1. Clone the repository:
```
git clone https://github.com/ngpinjie/cpd-installation-scripts.git
cd cpd-installation-scripts
```


2. Update the environment variables (found in install_cpd.sh Line 34)
Update the following variables with your cluster details:
- OCP_URL
- OCP_USERNAME
- OCP_PASSWORD
- IBM_ENTITLEMENT_KEY
```
nano install_cpd.sh
```


3. Make the script executable and sets the file permissions to be readable, writable, and executable only by the owner.
```
chmod 700 install_cpd.sh
```


4. Run the script:
```
./install_cpd.sh
```

(Alternatively) Run script in background
```
nohup ./install_cpd.sh > install_cpd.log 2>&1 &
```


5. Verify the Installation
- Ensure that all components are installed and running correctly.
```
oc get nodes
oc get all --all-namespaces
```


6. Access IBM Cloud Pak for Data
- Retrieve the URL and admin credentials for the IBM Cloud Pak for Data instance:
```
cpd-cli manage get-cpd-instance-details --cpd_instance_ns=${PROJECT_CPD_INST_OPERANDS} --get_admin_initial_credentials=true
```

Note: Ensure to replace placeholders in the script with your actual environment variables.
