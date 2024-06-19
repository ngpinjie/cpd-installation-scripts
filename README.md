# cpd-installation-scripts
This repository provides shell scripts to streamline the installation of IBM Cloud Pak for Data on your Red Hat OpenShift cluster.  It automates tasks like setting up the environment, logging in, and installing key components like Analytics Engine and Watson Studio.

# CPD Installation Scripts

This repository contains shell scripts to automate the installation of IBM Cloud Pak for Data on a Red Hat OpenShift cluster.

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
git clone https://github.com/your_username/cpd-installation-scripts.git
cd cpd-installation-scripts
```

2. Make the script executable:
```
chmod +x install_cpd.sh
```

3. Run the script:
```
./install_cpd.sh
```

Note: Ensure to replace placeholders in the script with your actual environment variables.
