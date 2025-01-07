# Coding Challenge: AI Immigration Chatbot with Golang and Temporal


## Running on Dev Environment

In order to run the code in the development you need to have following items installed on your OS. 
* make 
* docker engine

Assuming you already have docker installed, in order to install make you can:
* On Macos run -> brew install make
* On Windows -> https://gnuwin32.sourceforge.net/packages/make.htm

After installing make, in order to run the dev environment you just need to run the following command. It will create the containers and temporal.

`make dev_up`

To clean the development environment you need to run. It will remove all the containers.

`make dev_down`


## Code Structure
* Schemas: this folder includes all the schemas in order to avoid circular-dependency
* Temporal: All the codes related to temporal are in this folder. This includes, logger, activities, workflow and the worker. Workers eventually will be deployed through using docker images.
* Services: The chatbot engine code 
* Webserver: Here is the webserver that get the request to start the workflow
* In the main directory, there is Makefile which can later be used for CI/CD. Also, split the docker-compose to worker and temporal to make it easier to add workers later. Dockerfile is also added here.
* Index.html is the simple interactive front end which has been created with the help of chatgpt.

## Running
In order to run, after starting the project with "make dev_up". Then open  the index.html. 
You can also checkout the temporal frontend at: http://localhost:8080/ to see the workflow. 

## Unit Test
Right now only the chatbot engine (the new code logic) has unit test assuming the external lib already have their own unit tests. Run `make test` to run the unit test. Also when you do `make dev_up` the unit test already run. In development env you probably do not want to do run unit test for all the code base as it takes a long time to run. I just added that here for demo. For CI/CD it is a must.


## Improvement
* The dev env setup can be improved to create the binary on local and then copy them to the docker image. This makes the re-running docker much faster
* CI/CD can be added for gitlab/github
* Helm chart can be added for easier CI/CD to K8
* Chatgpt or other AI library can be incorporated to the solution. The drawback is that they cost money and also might not give what we are intended for. Also, we need to be cautious using chatgpt for chat bot  as the data can be leaked to public.
* DB can be added to store the data we get from temporal
* Env variable can be added and remove the hard-coded text from the code


