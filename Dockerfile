# Using official Node.js image as base image
FROM node:14

# Setting the working directory inside the container
WORKDIR /app

# Copying package.json and package-lock.json
COPY package*.json ./

# Installing the dependencies
RUN npm install

# Copying the rest of the application code
COPY . .

# Exposing the port the app will run on
EXPOSE 3000

# Defining the command to run the app
CMD ["npm", "start"]
