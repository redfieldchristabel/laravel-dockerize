FROM node:22

WORKDIR /app

COPY package*.json ./

RUN npm install

CMD [ "npm", "run", "dev", "--", "--host", "0.0.0.0" ]