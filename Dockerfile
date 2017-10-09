##############################################
## Docker file to build Angular application ##
##  and package/run within ngnix container  ##
##############################################

## Use nginx alpine base image
FROM nginx:1.13.5-alpine

## Copy app specific nginx config
COPY nginx/default.conf /etc/nginx/conf.d/

## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

## Install nodejs package from alpine repo
RUN apk add --no-cache nodejs

## Copy application package.json file
COPY package.json package-lock.json ./

## npm performance nits
RUN npm set progress=false &&\
    npm config set depth 0 &&\
    npm cache clean --force

## Storing node modules on a separate layer will prevent unnecessary npm installs for each build
RUN npm i &&\
    mkdir ng-app &&\
    cp -rf node_modules ng-app

## Set ng-app as working directory
WORKDIR ng-app

## Copy all source code from your host machine into container
COPY . .

## Build the angular app in production mode and store the artifacts in dist folder
RUN $(npm bin)/ng build --prod --build-optimizer

## Copy over the artifacts in dist folder to default nginx public folder
RUN cp -rf dist/* /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]

# Expose ports.
EXPOSE 80 443
