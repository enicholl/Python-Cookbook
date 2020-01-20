### README file for the python application project ###

# Introduction #

The aim of this project was to take a simple python application (IT Jobs Watch) and provision the application using a python chef cookbook.
The next objective was to create two pipelines for the project, one for the infrastructure (Chef cookbook) and one for the app itself.
The purpose of these two pipelines were to automate the process of deploying any updates/changes to either the chef cookbook (infrastructure pipeline) 
or developer updates to the application itself.

Once completed, this project aimed to allow for any changes in infrastructure to be automatically detected, tested (and if successful) then merged to the master branch 
of the python cookbook github repository. In turn, as the developer works on the application, they call the latest updated version of the python cookbook from the github repository 
(using the berks vendor cookbooks command) which allows them to work with the most up to date cookbook. Once the developer has finished their updates to the applicaiton, they would then 
push their code to the developer branch of the python application repository in github. This would trigger similar events, the change is detected, tested (and if successful) then merged to 
the master branch of the application repository. Then the change of the master branch is detected, and an AMI is created which can then be used in an AWS instance to run the 
updated application.

In this file I shall go into more detail of the development and provisioning of the different stages throughout this project, mentioning any challenges I faced along the way.

# Pre-requisites #
Before beginning the project I downloaded the folder containing the IT Job Watch application. In addition to the application, the project required ChefDK, Python and Packer to be downloaded
prior to beginning.


## Creating the python cookbook folder ##

# Creating the recipe #
For the application to work, it was important to install all of the python packages listed in the apps requirements.txt file (this came to 19 python packages in total).
The application was also only compatible with python3 so that was installed first. Additionally we needed to install python package pip so that we could use it as a tool to install
the multiple python packages contained in the requirements.txt file at once. Once pip was installed, we installed all of the requirements needed for the running of the application. 
Installing these requirements seemed simple at first however I had difficulties later on in the project when the virtual machine could not locate the packages despite them being reported 
as successfully installed (this issue was also highlighted by one of the integration tests used later). Lastly in the recipe file, I had to create the directory and file where the 
application would store the IT Jobs Watch data once the application was running.

# Creating the unit tests #
To ensure the recipe file was correct and without errors, I created a series of unit tests. These tests checked the recipe as part of a simulated Chef Infra Client run. The tests are 
executed simply by running the chef exec rspec command. When using this test locally it initially highlighted to me a few simple syntax errors which I were able to fix fairly quickly
without too much of a delay. (All unit tests I used can be seen in the spec/unit/recipes/default_spec.rb file in the python cookbook repository)

# Creating the integration tests #
To ensure that the cookbook would correctly provision the virtual environment, I created a set of integration tests. When these tests were run, using the kitchen verify command, the kitchen
tool would create a virtual machine, provision the machine and install the dependancies, and then run the integration tests to check the provisioning of the machine. Following that it would 
destroy the machine. Initially when creating the integration tests I had very few issues, however when it came to testing the installation of the python packages using the requirements.txt file, 
the test was failing. I am still working to resolve this issue and need to further investigate as the provisioning of the machine clearly shows the installlation of all 19 python packages, 
but when they are used to execute commands they cannot be found. *edit* I have since managed to resolve this issue as it was an error being caused by the machine not being destroyed completely. Since
Restarting the system and ensuring the machine was destroyed and re-provisioned, all tests have run correctly and all commands successful. (All integration tests I used can be seen in the 
test/integration/default/default_test.rb file in the python cookbook repository)

## Creating the IT Jobs Watch application folder ##
The app folder was downloaded into a parent folder named IT Jobs watch, which also contained the vagrantfile, packer.json file and berksfile. 

# Creating the Vagrantfile #
The vagrantfile is used to describe the type of virtual machine needed for a project and also specifies how it should be configured and provisioned.
At the start of my vagrant file I had to install the required plugins, hostsupdater and berkshelf, which were required in order for this project to run successfully. The next step
was to configure and provision the machine. The machine genreated by vagrant was an ubunutu/xenial64 machine provisioned using the latest python recipe in the python cookbook github repository
(this latest version is grabbed by the developers prior to using the environment by running the berks vendor cookbooks command). The machine is configured so that the app folder is synced into the 
machine, and that the application will run on a private network ip address witht the alias itjobswatch.local. (The full vagrant file can be seen in the Python application github repository).

# Creating the Packer file #
The packer file is used to generate an AMI which contains the application. The packer.json file is a template which is used to create that image and it contains variables, builders and provisioners.
The variables show where to access the AWS access key and secret key (these are stored in the computers environment variables instead of being manually inputted to avoid the keys being exposed.
When run, packer is able to locate the keys from your environment variables and use them to connect to AWS. The builders are responsible for creation of the machine and turning it into an image.
In my packer file, the type of the builder is amazon-ebs as this the type used to generate an AWS EC2 instance. Other variables in the builders section include the subnet ID for the instance, the name of 
the ssh keypair it shall search for in your environment variables and the path to this key (ssh private keyfile). Additionally, I specified the region of AWS I wished to generate the AMI inside and also the 
instance type used in AWS, t2 micro.

The provisioners section of the packer file shows the flavour of chef used (chef-solo), the path to the chef cookbook to be used and the name of the cookbook is stated in the run_list. 
The second provision is to generate the /home/ubuntu/app folder inside the image, and lastly the file provision pushes the application into the newly generated /home/ubuntu/app folder 
where it can then be run.

# Creating the Berksfile #
The berksfile is used to connect to the python cookbook github repository. This is necessary as the developers will need to grab the latest version of the python cookbook (using berks vendor cookbooks) 
to ensure they are working with the most up to date version of the cookbook.


## Creating the infrastructure pipeline ##
The first step in creating the infrastructure pipeline for the python cookbook was to create a new github repository. This repository had a developer and master branch. When any changes were made to the 
cookbook, the devops engineer would push their changes to the dev branch of the github repo. I created a jenkins job which would be watching the developer branch of the repository (using a webhook) and it
would be triggered by any changes or additions. The purpose of this jenkins job (jenkins job 1) was to grab the new contents of the developer branch and run the unit and integration tests to ensure the
updates to ensure the updates were successful. If all the tests pass, jenkins 2 is triggered. Jenkins 2 is watching jenkins 1 and as soon as the tests pass, it merges the new code to the master branch of 
python cookbook github repository. This is how the python cookbook is automatically updated in the master branch when the devops engineers make new changes. The cookbook in the master branch is then 
grabbed by developers using the berks vendor cookbooks command before they start working on the application. 

Issues I faced when creating the infrastructure pipeline were due to an error within jenkins which would not allow chef commands to run. This meant that I could not run jenkins job 1 successfully, therefore
meaning jenkins job 2 was never activated. The issue is still being resolved however I am confident that once the chef commands are able to be used, the pipeline from push to github all the way to merging to
master should be successful.

Please see a full diagram of my infrastructure pipeline in the python cookbook github repository (infrastructure pipeline diagram.png)


## Creating the application pipeline ##
For the application pipeline, I first created the python application repository in github. This reo also contained a dev and master branch. The master branch contains the current up to date application which is 
cloned by developers wishing to make any updates to the code. Before working on the applciation in the virtual machine, the developers use the berks vendor cookbooks command to retrieve the current updated python
cookbook from the python cookbook repo (see previous pipeline). Once the developer has this they can work on the application in the machine. Once new changes have been made, the developer pushes their updated code
to the developer branch of the github repo. This triggers the first jenkins job, which is watching the dev branch of the repo via a webhook. This jenkins job (jenkins 1) is running on a python slave node. 
The slave node was created using an AMI I had previously generated using packer. Jenkins 1 detects the change in the dev branch and begins to run pytests on the new application code. Similarly to the infrastructure 
pipeline, jenkins 2 will only begin running if the tests conducted in jenkins 1 are passed successfully. Jenkins 2 merges the successful code back to the master branch of the python application repository. 
Meanwhile, a third jenkins job is watching the master branch of the github repository. When the successful application code is merged to master branch, jenkins 3 uses the packer.json file to generate an AMI containing
the up to date application. This AMI is then used to generate an instance in AWS where the application can be run.

Issues I faced when making the application pipeline were caused by earlier issues i had with the provisioning of the python packages. As the requirements were not being recognised as installed, the pytest in jenkins 1
was failing and not triggering jenkins 2. Additionally, I had some issues generating the AMI using packer at first as it was unable to locate the AWS Access Key and AWS Secret Key.  

Please see a full diagram of my application pipeline in the python application github repository (application pipeline diagram.png)




