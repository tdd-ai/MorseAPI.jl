FROM julia:1.6-buster

RUN apt-get update && apt-get install -y gcc

ENV JULIA_PROJECT @.
ENV VERSION 1

# copy working dir
WORKDIR /home
ADD . /home

# define args
ARG api_port=8080
ARG auth_token=sometoken
ARG lib_path=MorseAPI.so

# export env vars
ENV API_PORT=$api_port
ENV AUTH_TOKEN=$auth_token
ENV LIB_PATH=$lib_path

# compile and run
RUN julia deploy/packagecompile.jl

ENTRYPOINT julia --sysimage "$LIB_PATH" -e "MorseAPI.run()"
EXPOSE $api_port