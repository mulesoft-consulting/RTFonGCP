![](images/title.png)  
Update: March 19, 2020

## Introduction

This workshop will walk you through the process of installing **Anypoint Runtime Fabric (RTF)** on **Google Cloud Platform (GCP)**.

***To log issues***, click here to go to the [github](https://github.com/mulesoft-consulting/RTFonGCP/issues) repository issue submission form.

## Objectives

- [Create Infrastructure to support Anupoint Runtime Fabric (RTF)](#iaas)
- [Install Anypoint Runtime Fabric (RTF)](#installrtf)
- [Deploy Test Application](#deployapp)

## Required Artifacts

- The following lab requires a Google Cloud Platform account.

<a id="iaas"></a>
## Create Infrastructure to support Anypoint Runtime Fabric (RTF)

### **STEP 1**: Create Google VPC

- From any browser, go to the URL to access Google Cloud Console:

   <https://console.cloud.google.com/>

- Click on the upper left navigation bar. Select **VPC networks**

    ![](images/image1.png)

- Click **Create a VPC network**

- Enter the following information:

    **Name:** `rtf-vpc` or unique name

    **Subnet Name:** `rtf-subnet` or unique name

    **Region:** `select Region of choice`

    **IP address range:** `10.0.0.0/16`

    ![](images/image2.png)

- Click **Create**. Wait for network to be created.

    ![](images/image3.png)

### **STEP 2**: Create Firewall Rules

- Next we need to create **Firewall Rules** to open needed ports for installation of RTF and access to Virtual Machines (VM)

- Under the **VPC Network** menu click **Firewall Rules**. At the top of the page click **CREATE FIREWALL RULE**

- Enter the following information:

    **Name:** `rtf-allow-ssh` or unique name

    **Network:** `select network created in previous step`

    **Target Tags:** `rtf-allow-ssh`

    **Source IP ranges:** `0.0.0.0/0`

    **Protocals and Ports:** `tcp:22`

    ![](images/image4.png)![](images/image5.png)

- Click **Create**

    ![](images/image6.png)

- Repeat the previous steps to create the addition 4 Firewall rules:

- Firewall Rule **rtf-allow-install**:

    **Name:** `rtf-allow-install` or unique name

    **Network:** `select network created in previous step`

    **Target Tags:** `rtf-allow-install`

    **Source IP ranges:** `0.0.0.0/0`

    **Protocals and Ports:** `tcp:4242, 61008-61010, 61022-61024`

- Firewall Rule **rtf-allow-https**:

    **Name:** `rtf-allow-https` or unique name

    **Network:** `select network created in previous step`

    **Target Tags:** `rtf-allow-https`

    **Source IP ranges:** `0.0.0.0/0`

    **Protocals and Ports:** `tcp:443`

- Firewall Rule **rtf-allow-ops-center**:

    **Name:** `rtf-allow-ops-center` or unique name

    **Network:** `select network created in previous step`

    **Target Tags:** `rtf-allow-ops-center`

    **Source IP ranges:** `0.0.0.0/0`

    **Protocals and Ports:** `tcp:32009`

- Firewall Rule **rtf-allow-internal**:

    **Name:** `rtf-allow-internal` or unique name

    **Network:** `select network created in previous step`

    **Target Tags:** `rtf-allow-internal`

    **Source IP ranges:** `10.0.0.0/16`

    **Protocals and Ports:** `All`

- Firewall Rule **rtf-allow-egress**:

    **Name:** `rtf-allow-egress` or unique name

    **Network:** `select network created in previous step`

    **Direction of traffic:** `egress`

    **Target Tags:** `rtf-allow-egress`

    **Source IP ranges:** `0.0.0.0/0`

    **Protocals and Ports:** `upd:123 tcp:443,5044`


![](images/image7.png)

### **STEP 3**: Create Controller VM

- Click on the upper left navigation bar. Select **Compute Engine -> VM instances**

    ![](images/image8.png)

- Click **CREATE INSTANCE**

    **Name:** `rtf-controller` or unique name

    **Region:** `select same region as subnet created`

    **Machine Type:** `Custom`

    **Cores:** `2 vCPU` **Memory:** `8 GB`

    ![](images/image9.png)

- Click **Change** on **Boot disk**

- Select **Operating system** to **Red Hat Enterprise Linux**

- Select **Version** to **Ref Hat Enterprise Linux 7**

- Change **Boot disk Size** to **80**

- Click **Select**

    ![](images/image10.png)

- Expand **Management, security, disks, networking, sole tenancy**

- Select **Disks** and click **Add New Disk**

- Enter the following and click **Done**

    **Name:** `rtf-controller-etcd` or unique name
    
    **Type:** `SSD persistend disk`

    **Deletion rule:** `Delete disk`

    ![](images/image11.png)

- Add a 2nd disk. Enter the following and click **Done**

    **Name:** `rtf-controller-docker` or unique name
    
    **Type:** `SSD persistend disk`

    **Deletion rule:** `Delete disk`

    ![](images/image12.png)

- Click **Networking** and add the following **Network Tags:** `rtf-allow-ssh rtf-allow-install rtf-allow-https rtf-allow-ops-center rtf-allow-internal rtf-allow-egress`

    ![](images/image13.png)

- Click *Network Interface**

- Change **Network** to **VPC** created in previous step.

- Change **Primary internal IP** to **Reserve static internal IP**

- In pop-up enter the following:

    **Name:** `rtf-controller-ip` or unique name

    **Static IP Address:** `Let me choose`

    **Custom IP address:** `10.0.0.5`

- Click **RESERVE**

    ![](images/image14.png)

    ![](images/image15.png)

- Click **Create**

    ![](images/image16.png)

### **STEP 4**: Create Worker VMs

- Now we will create 2 worker VMs following the same steps as the controller vm will some small changes.

- Click **CREATE INSTANCE**

    **Name:** `rtf-worker` or unique name

    **Region:** `select same region as subnet created`

    **Zone:** `choose a different zone from controller vm`

    **Machine Type:** `Custom`

    **Cores:** `2 vCPU` **Memory:** `15 GB`

    **Extended Memory:** `check box`

    ![](images/17.png)

- Click **Change** on **Boot disk**

- Select **Operating system** to **Red Hat Enterprise Linux**

- Select **Version** to **Ref Hat Enterprise Linux 7**

- Change **Boot disk Size** to **80**

- Click **Select**

    ![](images/image10.png)

- Expand **Management, security, disks, networking, sole tenancy**

- Select **Disks** and click **Add New Disk**

- Enter the following and click **Done**

    **Name:** `rtf-worker1-docker` or unique name
    
    **Type:** `SSD persistend disk`

    **Deletion rule:** `Delete disk`

    ![](images/image18.png)

- Click **Networking** and add the following **Network Tags:** `rtf-allow-ssh rtf-allow-install rtf-allow-https rtf-allow-internal rtf-allow-egress`

    ![](images/image19.png)

- Click *Network Interface**

- Change **Network** to **VPC** created in previous step.

- Change **Primary internal IP** to **Reserve static internal IP**

- In pop-up enter the following:

    **Name:** `rtf-worker1-ip` or unique name

    **Static IP Address:** `Let me choose`

    **Custom IP address:** `10.0.0.8`

- Click **RESERVE**

    ![](images/image20.png)

    ![](images/image21.png)

- Click **Create**

- Repeat these stesp to create a 2nd worker vm **name** `rtf-worker2` with **reserved ip** of `10.0.0.9`

    ![](images/image22.png)

<a id="installrtf"></a>
## Install Anypoint Runtime Fabric (RTF)

In this section will will walk through installing RTF. For compolete instuctiuns please visit [MuleSoft Docs](https://docs.mulesoft.com/runtime-fabric/1.4/)

### **STEP 5**: Create a Runtime Fabric using Runtime Manager

- From any browser, go to the URL to access **Anyppoint Platform**

    <https://anypoint.mulesoft.com>

- Click on the upper left navigation bar. Select **Runtime Manager**

    ![](images/image23.png)

- Click **Runtime Fabrics**

- Click **Create Runtime Fabric**

    **Name:** `rtf_on_gcp` or unique name

- Click **Create**

    ![](images/image24.png)

- Later will we come back to this page for the **activation code**

### **STEP 6**: Download Install scripts

The following steps should be executed on all 3 VMs. Steps below will be for just controller vm.

- Go back to **Google Cloud Platform**. If not on the **VM instances** page navigate back to **VM instances** page.

- Click **SSH** and select **Open in browser window**

    ![](images/image25.png)

- From the SSH session execute the following commands:

- Install **curl**

```bash
sudo yum install zip unzip -y
```

![](images/image26.png)

- Download and Extract install sceripts

```bash
curl -L https://anypoint.mulesoft.com/runtimefabric/api/download/scripts/latest --output rtf-install-scripts.zip
mkdir -p ./rtf-install-scripts && unzip rtf-install-scripts.zip -d ./rtf-install-scripts
```

![](images/image27.png)

- repeat these steps on the other 2 VM's

### **STEP 7**: Setup and Configure Environment

The following steps should be executed on all 3 VMs. Steps below will be for just controller vm.

- Create runtime directory

```bash
sudo mkdir -p /opt/anypoint/runtimefabric
```

- Change ownership of **runtimefabric** directory to current user

```bash
sudo chown dennis_foley:dennis_foley /opt/anypoint/runtimefabric
```

- Copy install script to runtime diretory

```bash
cd
cp ./rtf-install-scripts/scripts/init.sh /opt/anypoint/runtimefabric/init.sh && chmod +x /opt/anypoint/runtimefabric/init.sh
```

![](images/image28.png)

### **STEP 8**: Setup and Generate Environment Configuration

- On the controller vm change into the install script directory for manual install

```bash
 cd rtf-install-scripts/manual/
 ```

 - Next run the generate config script. You will need the **activation code** from the previous step and will also need a valid MuleSoft license. To generate a **Base64** license follow [MuleSoft Docs](https://docs.mulesoft.com/runtime-fabric/1.4/install-manual#base64-encode-your-mule-license-key)

 ```bash
RTF_CONTROLLER_IPS='10.0.0.5' \
RTF_WORKER_IPS='10.0.0.8 10.0.0.9' \
RTF_DOCKER_DEVICE='/dev/sdb' \
RTF_ETCD_DEVICE='/dev/sdc' \
RTF_ACTIVATION_DATA='<activation code>' \
RTF_MULE_LICENSE='<Base64 MuleSoft License>' \
./generate-configs.sh
 ```

![](images/image29.png)

- From the output of the **generate-config.sh** execute the **cat** command to create the **env** file for each VM.

### **STEP 9**: Install RTF

- Run the **init.sh** script in privileged mode on the controller VM.

```bash
sudo /opt/anypoint/runtimefabric/init.sh
```

- Wait for install to complete on controller vm before moving forward

![](images/image30.png)

- Run the **init.sh** script in privileged mode on both of the worker VM.

```bash
sudo /opt/anypoint/runtimefabric/init.sh
```

![](images/image31.png)

- If you go back to **Anypoint Platform** and go to **Runtime Fabrics** you should see that your RTF environment is now **Actice**

    ![](images/image32.png)

 <a id="deployapp"></a>
## Deploy Test Application

Now that we have a running installation of Anypoint Runtime Fabric lets test that we can deploy an application to RTF.

### **STEP 10**: Accociate Environments

- If not already on the page, navigate back to your newly created **Runtime Fabric** in **Anypoint Platform**

- Click on **Accociate Environments**

- Select the environment you would like to assiciate with this instance of RTF. In this example we have selected **Sandbox**. Click **Apply Allocations**

    ![](images/image33.png)

### **STEP 10**: Create Certificate-Key pair

In this step we will create a new certificate to but used by RTF. If you do not have **openssl** installed on your laptop you will need to install before moving forward.

- Open a terminal windown and execute the following command

```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
```

- For the prompts we will use the following change as needed:

    **PEM pass phrease:** `mulesoft`

    **Country:** `US`

    **State or Province:** `CA`

    **Locality Name:** `San Francisco`

    **Organization Name:** `Mulesoft`

    **Organizational Unit Name:** `<leave blank>`

    **Common name:** `*.domain.com`

    **Email Address:** `<leave blank>`


![](images/image34.png)

### **STEP 11**: Create a Secret Group in Anypoint Secret Manager

- Back in the browser, naviagate to **Secrets Manager** and click **Create Secret Group**

- Enter a name **rtf-group** and click **Save**

    ![](images/image35.png)

- In the left sidebar, select **Keystore**

- Click **Add Keystore**

- Enter the following information:

    **Name:** `rtf-keystore`

    **Type:** `PEM`

    **Certificate File:** `<select cert.pem created in previous step>`

    **Key File:** `<select key.pem created in previous step>`

    **Key Passphrase:** `mulesoft`

    ![](images/image36.png)

- Click **Save**

### **STEP 12**: Create a TLS Contecdt in Anypoint Secret Manager

- In the left sidebase, select **TLS Contecxt**

- Click **Add TLS Context**

- Enter the following information:

    **Name:** `rtf-tls`

    **TLS Version:** `TLS 1.2`

    **Target:** `Anypoint Security`

    **Keystore:** `rtf-keystore`

    ![](images/image37.png)

- Click **Save**

- Click the back button **SECRET GROUPS**

    ![](images/image38.png)

- Click **Finish**

    ![](images/image39.png)

### **STEP 13**: Enable Inbound Traffic

- Navigate back to your **Runtime Fabric**. Select tab **Inbound Traffic**

- Toggle **Enable inbound traffic**

    ![](images/image40.png)

- Scroll down to **Resource Allocation** and select **1 vCPU**

- Set the following based on previous steps:

    **Environment:** `Sandbox`

    **Secret Group:** `rtf-group`

    **TLS Context:** `rtf-tls`

    ![](images/image41.png)

- Click **Deploy**

### **STEP 14**: Deploy Application






