FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS builder

COPY . /func-app
RUN cd /func-app && \
    mkdir -p /func-app/bin && \
    dotnet publish *.csproj --output /func-app/bin/

# ### STAGE 1: Build ###
# #FROM node:10.6.0 as builder

# SHELL ["/bin/bash", "-c"]

# WORKDIR /func-app
# COPY . .
# RUN yarn install
# # install .net core, azure functions core tools & required bindings
# RUN apt-get update && \
#     curl -O https://dot.net/v1/dotnet-install.sh && \
#     source dotnet-install.sh --channel Current && \
#     rm dotnet-install.sh
#     # dotnet publish . -o bin/

# ### STAGE 2: functions runtime image ###
# FROM mcr.microsoft.com/azure-functions/node:2.0

# ENV AzureWebJobsScriptRoot=/home/site/wwwroot
# COPY --from=builder /func-app /home/site/wwwroot

FROM mcr.microsoft.com/azure-functions/node:4-node16

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true

COPY --from=builder /func-app /home/site/wwwroot

RUN cd /home/site/wwwroot && \
    npm install