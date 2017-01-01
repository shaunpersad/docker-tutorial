# docker-tutorial
A simple intro to Docker with Node.js


## How to use this tutorial

Clone this project, then follow along. At the end of it, two new files will be created by you: `package.json` and `index.js`.

You may then use your version of this project for Part 2.
```bash
git clone https://github.com/shaunpersad/docker-tutorial
```

## The Who/What/Why of Docker

(Warning: I am not a Docker expert)

Docker is a container service. For our intents and purposes, a container is similar to a virtual machine, but not quite the same.

You may be used to working with Vagrant to build, provision, and use VMs for individual projects. Docker can replace Vagrant in those duties.

If none of this is familiar to you, the gist is that containers and/or VMs are isolated environments that can run applications inside of them.

For example, you can build yourself a Node.js environment with Postgres and Elasticsearch without ever having to install any of those technologies directly on your local machine.  They, and your application, will run inside the isolated environment.

This is a very powerful concept, as these environments are repeatable and shareable, meaning that your entire team, your staging server, and your production server, can all use the same environments:
the same OS, the same versions of languages and tech stacks, etc.

For Docker specifically, the concepts of *images* and *containers* are used. Images are the blueprints for creating containers. Containers are running instances of an image.

For example, if I download the Node image, I can run a container based off of that image.  As an OOP analogy, images are the classes, and containers are the individual instances of a particular class.

You can learn more about Docker here: https://docs.docker.com/engine/getstarted/


## Some more Docker concepts

Before we start using Docker, there are some more concepts that we should familiarize ourselves with, particularly
the relationships between *Docker*, *Dockerfiles*, *Docker Compose*, and how they in turn relate to the concepts of *images* and *containers*.

### Docker and Dockerfiles

When you create a new project that you want to use Docker for, the first thing you'll want to do is create a `Dockerfile` file.

In it, you will specify the details of the environment you wish to create.

**A Dockerfile is the spec used to create an image.**

Normally in your Dockerfile, you would specify a base image (like Ubuntu, Node, etc.) to extend from, and then add in your application-specific requirements.

Once your Dockerfile is complete, you can then use it to build an image, and then use that image to run a container instance of that image.

Basically, Dockerfiles are used to create images, which in turn create containers.

Dockerfile => Shareable image based on Dockerfile => run instances of the image as containers.

Read more about Dockerfiles and the image creation process here: https://docs.docker.com/engine/getstarted/step_four/

### Docker and Docker Compose

Generally, when you want to spin up a container from an image, you will use Docker. However, there is also another program called Docker Compose that can also do that and more.

**Docker Compose allows you to spin up containers from many different images that can all talk to each other and act as a single application stack/ecosystem.**

For example, you can have an application server based on a Node image, a database server based on a MySQL image, and a redis server based on a Redis image.

Instead of spinning these up individually using Docker, you can use Docker Compose to spin them all up at once, with the added benefit of allowing each running container to connect to the other automatically.

Docker Compose accomplishes this orchestration via the use of a `docker-compose.yml` file.

In this file, you specify the images you wish to use, and some config for each image, including which images depend on and can talk to which other images.

You can then run this setup via Docker Compose.

As such, you generally want to use Docker Compose when considering a microservices architecture, and Docker when considering a monolithic architecture.


## Creating a Docker project from scratch:

### Step 1 - Prereqs.

Download [Docker](https://docs.docker.com/docker-for-mac/) and create a new project directory and repository.

Please note the system requirements: https://docs.docker.com/docker-for-mac/#/what-to-know-before-you-install

Basically, if you're on Mac (which I'm assuming), you should have OS X El Capitan 10.11 or higher, or you may get weird bugs.

### Step 2 - Dockerfile

Add a Dockerfile, like the one in this project, which does the following:
- Builds from the official existing Node.js image
    - This image has its own OS, which differs depending on which version you select to build from.
    - More info here: https://hub.docker.com/_/node/
- Creates an app directory
- Copies package.json and runs `npm install` from it
- Copies your app source files to the container


### Step 3 - .dockerignore

Much like .gitignore, .dockerignore ignores files when copying from your host to the container.
In this case, we don't want to copy any of the logs generated by node, or the node_modules from the host.


### Step 4 - Generate a `package.json` file

Notice that the Dockerfile specifies to copy `package.json` into the container. However, we don't yet have one, so attempting to build this image will fail.

To get a `package.json` file, you must run `npm init`, but, since the whole point of containers is to *not* install environments on your host machine, 
how will we run `npm init` without having Node or NPM locally?

The answer is to run the official Node.js image as a container in order to create a `package.json` file, by linking your host directory to a directory in the container.
In doing so, when you create the `package.json` file in the container, it will automatically show up in your host directory as well.

Alternatively, you can manually create one, but you won't get the benefits of it being generated for you.

#### 4A: - Create a terminal

To generate the `package.json` file, we need to create an interactive terminal into a container that has node: 
```bash
docker run -it --rm -v $(pwd):/usr/src/app -w /usr/src/app node:6.9.2 /bin/bash
```
That's quite the mouthful, so here's the breakdown of how we get to that:
- `docker run node:6.9.2` - run a container from the official node image
- `docker run node:6.9.2 /bin/bash` - run a terminal in the node container
- `docker run -it --rm node:6.9.2 /bin/bash` - "-it" makes an interactive terminal, "--rm" means the container will clean itself up after we're done with it
- finally, we add `-v $(pwd):/usr/src/app -w /usr/src/app` in there, which creates a volume from our host machine from `$(pwd)` (the current directory) to `/usr/src/app` in the container, and then changes the working directory to `/usr/src/app`

From the above, we've learned that you can use `docker run` to run images, and they can be used to do temporary things.
To learn more about `docker run`, read here: https://docs.docker.com/engine/reference/run/
To learn more about how to link directories from your host to docker containers, read here: https://docs.docker.com/engine/tutorials/dockervolumes/

#### 4B - Use the terminal to create the package.json

Now that we have a running terminal, we can run `npm init`. Once done with the setup, type `exit` to exit the container.

As an alternative to creating the bash terminal and using it to run `npm init`, we could run the following:
```bash
docker run --rm -v $(pwd):/usr/src/app -w /usr/src/app node:6.9.2 npm init --yes
```
The above one-liner automatically runs `npm init` in the container, and also supplies the `--yes` flag to skip the setup process.

For your convenience, I have saved both commands in the `scripts` directory:
- `terminal.sh` can be used when you wish to create a node terminal.
    - This will also be useful when adding new packages with `npm install {package} -- save`
- `bootstrap.sh` can be used to automatically generate a `package.json` file when you start a new project.


### Step 5 - Your source code

To build an app, we need code! Let's make it simple by creating an `index.js` file that contains the following:
```js
console.log('Hello world!');
```

### Step 6 - Build your image

Now that we have everything the Dockerfile requires, we can build our image!

We can use either Docker or Docker Compose to do this.  Both ways will be described.

#### 6A - The regular Docker way

Run the following command:
```bash
docker build -t shaunpersad/docker-tutorial .
```
**Don't forget that last dot!**
- the "-t" flag tags the image with "shaunpersad/docker-tutorial" name.
- the "." specifies the directory of the Dockerfile to use.
- Don't mind the red outputs when NPM runs...it does that.

#### 6B - The Docker Compose way

Notice that we have a `docker-compose.yml` file, which has a `build` property that points to the directory of the Dockerfile, and the `image` property that names it.
This file will allow us to run the following:
```bash
docker-compose build
```

### Step 7 - Run your image as a container instance

Now that our image has been built, we can run an instance of it as a container. If successful, it will run `index.js`,
which will print "Hello World!" in the console.

#### 7A - the regular Docker way

Run the following command:
```bash
docker run shaunpersad/docker-tutorial node index.js
```
Notice the `node index.js` that you'd normally run if you were in a node environment.

Alternatively, we could have stuck this command to run automatically, if we specified a `CMD` at the end of our Dockerfile:
```bash
CMD [ "node", "index.js" ]
```
Also notice that the app exited immediately. This is the typical behavior of a node app that is not expecting any I/O.
If we were building an express app or some other app that listened to a port, the container would have stayed up.

#### 7B - the Docker Compose way

Run the following command:
```bash
docker-compose up
```


## Congratulations!

You've just successfully run your first app in Docker.  Try modifying the contents of `index.js`, rebuilding the image, and rerunning the container.

If that sounds like a chore, that's because it is, especially as your app grows in size and the `COPY` stage gets longer.

As it stands right now, each time you add or modify your source files, you'll need to rebuild the image and rerun the container.

In Part 2, we will explore how to get around this so that your app updates automatically when you modify the source code.

We will also get more in-depth with Docker Compose and how to use it to build more complex environments.

Head to [Part 2](https://github.com/shaunpersad/docker-tutorial-pt2) now!

