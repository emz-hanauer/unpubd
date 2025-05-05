# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
#FROM dart:stable AS build
# FROM ubuntu:21.04 AS build
FROM dart:3.7 as build

ENV TZ=${TZ} 
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone RUN dpkg-reconfigure -f noninteractive tzdata


RUN mkdir -p /src/unpubd
# we update this line from tool/build.dart to force a new clone
# recompile after a code change in the git repo.
# RUN mkdir -p /BUILD_TOKEN/9f0aec0f20f046c08471a6c5c094b98b

# swap this line for the git clone during dev to make round trips faster.
COPY . /src/unpubd

WORKDIR /src/unpubd
RUN dart pub get
RUN dart compile exe /src/unpubd/bin/unpubd.dart -o /unpubd


# Build minimal  image from AOT-compiled `/batman`
FROM build

COPY --from=build /unpubd /unpubd
WORKDIR /

ENV MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
ENV MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}

ENV MONGO_DATABASE=${MONGO_DATABASE}
ENV MONGO_ROOT_USERNAME=${MONGO_ROOT_USERNAME}
ENV MONGO_ROOT_PASSWORD=${MONGO_ROOT_PASSWORD}
ENV MONGO_HOST=${MONGO_HOST}
ENV MONGO_PORT=${MONGO_PORT}

ENV GOOGLE_SECRET_NAME=${GOOGLE_SECRET_NAME}
ENV GOOGLE_SECRET_REFRESH_TOKEN=${GOOGLE_SECRET_REFRESH_TOKEN}
ENV GOOGLE_SERVICE_ACCOUNT_JSON_BASE64=${GOOGLE_SERVICE_ACCOUNT_JSON_BASE64}
ENV PRESHARED_ALLOWED_TOKENS=${PRESHARED_ALLOWED_TOKENS}
ENV PRESHARED_UPLOAD_EMAIL=${PRESHARED_UPLOAD_EMAIL}
ENV PRESHARED_UPLOAD_TOKENS=${PRESHARED_UPLOAD_TOKENS}

ENV UNPUBD_PORT=${UNPUBD_PORT}

EXPOSE ${UNPUBD_PORT}

ENTRYPOINT ["/unpubd","run"]
