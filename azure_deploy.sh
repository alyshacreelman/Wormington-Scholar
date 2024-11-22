#!/bin/bash

az containerapp env create --name wormington-scholar-environment --resource-group wormington-scholar-resource --location eastus

az containerapp create \
--name wormington-scholar-app \
--resource-group wormington-scholar-resource \
--environment wormington-scholar-environment \
--image alyshacreelman/wormington-scholar-cs4 \
--ingress external \
--target-port 7860 \
--env-vars TOKEN=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

az containerapp show \
--name wormington-scholar-app \
--resource-group wormington-scholar-resource \
--query properties.configuration.ingress.fqdn
