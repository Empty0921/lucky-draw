FROM node:10

WORKDIR /app

#RUN npm install -g yarn

COPY package.json yarn.lock ./app/
COPY . /app
RUN yarn install

#RUN npm install

#CMD [ "yarn", "dev" ]
