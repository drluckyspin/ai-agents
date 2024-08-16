# Use an official Node.js image as the base
FROM node:22

# Set the working directory to /app
WORKDIR /app

# Copy the package*.json files to the working directory
COPY package*.json ./

# Install the dependencies
RUN npm install

# Copy the application code
COPY . .

# Expose the port the app will run on
EXPOSE 3000

# Run the command to start the app when the container launches
CMD ["npm", "run", "dev"]