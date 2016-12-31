# Node.js version
FROM node:6.9.2

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# get the npm modules that need to be installed
COPY package.json /usr/src/app/

# install npm modules
RUN npm install

# copy the source files from host to container
COPY . /usr/src/app