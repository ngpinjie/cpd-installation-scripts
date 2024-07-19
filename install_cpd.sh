#!/bin/bash

# Install container runtime
sudo -i <<EOF
yum update -y
yum upgrade -y
yum install -y docker
EOF

# Setting up a client workstation

# Download Version 13.1.5 of the `cpd-cli`
wget https://github.com/IBM/cpd-cli/releases/download/v13.1.5r1/cpd-cli-linux-EE-13.1.5.tgz

# Extract the contents of the package to the directory where you want to run the `cpd-cli`.
tar xzvf cpd-cli-linux-EE-13.1.5.tgz
sudo mv cpd-cli-linux-EE-13.1.5-242 /opt/
sudo rm -rf /opt/cpd-cli-linux-EE
sudo ln -s /opt/cpd-cli-linux-EE-13.1.5-242/ /opt/cpd-cli-linux-EE

# Add the following line to your `~/.bash_profile` file:
cat << EOF >> ~/.bash_profile
export PATH=\${PATH}:/opt/cpd-cli-linux-EE
EOF

# Run this command
source ~/.bash_profile

# Run the following command to ensure that the `cpd-cli` is installed and running and that the `cpd-cli` manage plug-in has the latest version of the `olm-utils` image.
cpd-cli manage restart-container

# Creating an environment variables file
cat << EOF > ./cpd_vars.sh
# Cluster
export OCP_URL=api.XXXXXXXXXXXXXXXXXXXXX.cloud.techzone.ibm.com:6443
export OPENSHIFT_TYPE=self-managed
export IMAGE_ARCH=amd64
export OCP_USERNAME=kubeadmin
export OCP_PASSWORD=XXXX-XXXX-XXXX-XXXX
# Projects
export PROJECT_CERT_MANAGER=ibm-cert-manager
export PROJECT_LICENSE_SERVICE=ibm-licensing
export PROJECT_SCHEDULING_SERVICE=cpd-scheduler
export PROJECT_CPD_INST_OPERATORS=cpd-operators
export PROJECT_CPD_INST_OPERANDS=cpd-instance
# Storage
export STG_CLASS_BLOCK=ocs-storagecluster-ceph-rbd
export STG_CLASS_FILE=ocs-storagecluster-cephfs
# IBM Entitled Registry
export IBM_ENTITLEMENT_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# Cloud Pak for Data version
export VERSION=4.8.5
EOF

# Confirm that the script does not contain any errors.
bash ./cpd_vars.sh

# If you stored passwords in the file, prevent others from reading the file.
chmod 700 cpd_vars.sh

# Source the environment variables.
source ./cpd_vars.sh

# Updating the global image pull secret for IBM Cloud Pak for Data

# Log in to the cluster as a user with sufficient permissions to complete this task.
cpd-cli manage login-to-ocp \
  --username=${OCP_USERNAME} \
  --password=${OCP_PASSWORD} \
  --server=${OCP_URL}

# Provide your IBM entitlement API key to the global image pull secret:
cpd-cli manage add-icr-cred-to-global-pull-secret \
  --entitled_registry_key=${IBM_ENTITLEMENT_KEY}

# Get the status of the nodes.
cpd-cli manage oc get nodes

# Create the required projects:
oc login --username=${OCP_USERNAME} --password=${OCP_PASSWORD} --server=${OCP_URL}
oc new-project ${PROJECT_CERT_MANAGER}
oc new-project ${PROJECT_LICENSE_SERVICE}
oc new-project ${PROJECT_SCHEDULING_SERVICE}

# Log in to the cluster as a user with sufficient permissions to complete this task.
cpd-cli manage login-to-ocp \
  --username=${OCP_USERNAME} \
  --password=${OCP_PASSWORD} \
  --server=${OCP_URL}

# Install the Certificate manager and the License Service:
cpd-cli manage apply-cluster-components \
  --release=${VERSION} \
  --license_acceptance=true \
  --cert_manager_ns=${PROJECT_CERT_MANAGER} \
  --licensing_ns=${PROJECT_LICENSE_SERVICE}

# Install the scheduling service:
cpd-cli manage apply-scheduler \
  --release=${VERSION} \
  --license_acceptance=true \
  --scheduler_ns=${PROJECT_SCHEDULING_SERVICE}

# Log in to the cluster as a user with sufficient permissions to complete this task.
cpd-cli manage login-to-ocp \
  --username=${OCP_USERNAME} \
  --password=${OCP_PASSWORD} \
  --server=${OCP_URL}

# Apply the CRI-O settings:
cpd-cli manage apply-crio \
  --openshift-type=${OPENSHIFT_TYPE}

# Log in to the cluster as a user with sufficient permissions to complete this task.
cpd-cli manage login-to-ocp \
  --username=${OCP_USERNAME} \
  --password=${OCP_PASSWORD} \
  --server=${OCP_URL}

# Apply the required permissions to the projects.
cpd-cli manage authorize-instance-topology \
  --cpd_operator_ns=${PROJECT_CPD_INST_OPERATORS} \
  --cpd_instance_ns=${PROJECT_CPD_INST_OPERANDS}

# Log in to the cluster as a user with sufficient permissions to complete this task.
cpd-cli manage login-to-ocp \
  --username=${OCP_USERNAME} \
  --password=${OCP_PASSWORD} \
  --server=${OCP_URL}

# Install IBM Cloud Pak foundational services and create the required ConfigMap:
cpd-cli manage setup-instance-topology \
  --release=${VERSION} \
  --cpd_operator_ns=${PROJECT_CPD_INST_OPERATORS} \
  --cpd_instance_ns=${PROJECT_CPD_INST_OPERANDS} \
  --license_acceptance=true \
  --block_storage_class=${STG_CLASS_BLOCK}

# Check shared service components
cpd-cli manage get-cr-status --cpd_instance_ns=${PROJECT_CPD_INST_OPERANDS}

# Log in to the cluster as a user with sufficient permissions to complete this task.
cpd-cli manage login-to-ocp \
  --username=${OCP_USERNAME} \
  --password=${OCP_PASSWORD} \
  --server=${OCP_URL}

# Review the license terms for Cloud Pak for Data.
cpd-cli manage get-license \
  --release=${VERSION} \
  --license-type=EE

# Install the operators in the operators project for the instance.
cpd-cli manage apply-olm \
  --release=${VERSION} \
  --cpd_operator_ns=${PROJECT_CPD_INST_OPERATORS} \
  --components=cpd_platform

# Install the operands in the operands project for the instance.
cpd-cli manage apply-cr \
  --release=${VERSION} \
  --cpd_instance_ns=${PROJECT_CPD_INST_OPERANDS} \
  --components=cpd_platform \
  --block_storage_class=${STG_CLASS_BLOCK} \
  --file_storage_class=${STG_CLASS_FILE} \
  --license_acceptance=true

# Confirm that the status of the operands is Completed:
cpd-cli manage get-cr-status --cpd_instance_ns=${PROJECT_CPD_INST_OPERANDS}

# Get the URL of the web client and the automatically generated password for the admin user
cpd-cli manage get-cpd-instance-details --cpd_instance_ns=${PROJECT_CPD_INST_OPERANDS} --get_admin_initial_credentials=true

# Installing watsonx.data, watson studio, spark

# Ensure required environment variables are set
REQUIRED_VARS=(OCP_USERNAME OCP_PASSWORD OCP_URL VERSION PROJECT_CPD_INST_OPERATORS PROJECT_CPD_INST_OPERANDS STG_CLASS_BLOCK STG_CLASS_FILE)

for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    echo "Error: Environment variable ${var} is not set"
    exit 1
  fi
done

# Function to login to OCP
login_ocp() {
  echo "Logging in to OCP..."
  cpd-cli manage login-to-ocp \
    --username="${OCP_USERNAME}" \
    --password="${OCP_PASSWORD}" \
    --server="${OCP_URL}"
  
  if [ $? -ne 0 ]; then
    echo "Error logging in to OCP"
    exit 1
  fi
}

# Function to apply OLM
apply_olm() {
  local component=$1
  echo "Applying OLM for component: ${component}"
  cpd-cli manage apply-olm \
    --release="${VERSION}" \
    --cpd_operator_ns="${PROJECT_CPD_INST_OPERATORS}" \
    --components="${component}"
  
  if [ $? -ne 0 ]; then
    echo "Error applying OLM for component: ${component}"
    exit 1
  fi
}

# Function to apply CR
apply_cr() {
  local component=$1
  echo "Applying CR for component: ${component}"
  cpd-cli manage apply-cr \
    --components="${component}" \
    --release="${VERSION}" \
    --cpd_instance_ns="${PROJECT_CPD_INST_OPERANDS}" \
    --block_storage_class="${STG_CLASS_BLOCK}" \
    --file_storage_class="${STG_CLASS_FILE}" \
    --license_acceptance=true
  
  if [ $? -ne 0 ]; then
    echo "Error applying CR for component: ${component}"
    exit 1
  fi
}

# Function to verify installation
verify_installation() {
  local component=$1
  echo "Verifying installation for component: ${component}"
  cpd-cli manage get-cr-status \
    --cpd_instance_ns="${PROJECT_CPD_INST_OPERANDS}" \
    --components="${component}"
  
  if [ $? -ne 0 ]; then
    echo "Error verifying installation for component: ${component}"
    exit 1
  fi
}

# Login to OCP
login_ocp

# Installing watsonx.data
apply_olm "watsonx_data"
apply_cr "watsonx_data"

# Installing Analytics Engine Powered by Apache Spark
apply_olm "analyticsengine"
apply_cr "analyticsengine"

# Installing Watson Studio
apply_olm "ws"
apply_cr "ws"

# Verifying installations
verify_installation "watsonx_data"
verify_installation "analyticsengine"
verify_installation "ws"

echo "Installation and verification completed successfully."
