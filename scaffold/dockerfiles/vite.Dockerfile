FROM node:18

WORKDIR /app

COPY package*.json ./

RUN npm install

CMD [ "npm", "run", "dev" ]