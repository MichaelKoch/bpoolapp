#!/bin/bash

# Azure Container App deployment script for bpoolapp

# Configuration
RESOURCE_GROUP="bpoolapp-rg"
LOCATION="westeurope"
CONTAINER_APP_NAME="bpoolapp"
CONTAINER_APP_ENV="bpoolapp-env"
IMAGE="ghcr.io/michaelkoch/bpoolapp:latest"
PORT=80

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Creating Azure Container App for bpoolapp...${NC}\n"

# Step 1: Create resource group
echo -e "${BLUE}Step 1: Creating resource group...${NC}"
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION
echo -e "${GREEN}✓ Resource group created${NC}\n"

# Step 2: Create container app environment
echo -e "${BLUE}Step 2: Creating container app environment...${NC}"
az containerapp env create \
  --name $CONTAINER_APP_ENV \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION
echo -e "${GREEN}✓ Container app environment created${NC}\n"

# Step 3: Create container app
echo -e "${BLUE}Step 3: Creating container app...${NC}"
az containerapp create \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINER_APP_ENV \
  --image $IMAGE \
  --target-port $PORT \
  --ingress external \
  --query properties.configuration.ingress.fqdn
echo -e "${GREEN}✓ Container app created${NC}\n"

# Step 4: Get the FQDN
echo -e "${BLUE}Step 4: Retrieving container app URL...${NC}"
FQDN=$(az containerapp show \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --query properties.configuration.ingress.fqdn \
  --output tsv)

echo -e "${GREEN}✓ Deployment complete!${NC}"
echo -e "\n${BLUE}Container App URL:${NC} https://$FQDN"
echo -e "${BLUE}Asset Links URL:${NC} https://$FQDN/.well-known/assetlinks.json\n"
