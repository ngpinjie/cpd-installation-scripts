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
1. Installs container runtime.
2. Sets up a client workstation.
3. Configures environment variables.
4. Logs into OpenShift cluster.
5. Applies necessary OLM and CR configurations.
6. Installs various components like Analytics Engine, Watson Studio, DataStage, and more.

## Usage
1. Clone the repository:
```
git clone https://github.com/ngpinjie/cpd-installation-scripts.git
cd cpd-installation-scripts
```

2. Update the environment variables (found in install_cpd.sh Line 34)
```
nano install_cpd.sh
```
Update the following variables with your cluster details:
- OCP_URL
- OCP_USERNAME
- OCP_PASSWORD
- IBM_ENTITLEMENT_KEY

3. Make the script executable and sets the file permissions to be readable, writable, and executable only by the owner.
```
chmod 700 install_cpd.sh
```

4. Run the script:
```
./install_cpd.sh
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
