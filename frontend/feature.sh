#!/bin/bash

# Verify input
if [ $# -eq 0 ]; then
    echo "Usage: $0 <feature-name>"
    exit 1
fi

# Get the feature name
FEATURE_NAME=$1
FEATURE_NAME_LOWER=$(echo $FEATURE_NAME | tr '[:upper:]' '[:lower:]')

# Define the base path for the feature
BASE_PATH="src/features/$FEATURE_NAME_LOWER"

# Create feature directories
mkdir -p $BASE_PATH/data/datasources
mkdir -p $BASE_PATH/data/repositories
mkdir -p $BASE_PATH/data/mappers
mkdir -p $BASE_PATH/data/dtos
mkdir -p $BASE_PATH/domain/repositories
mkdir -p $BASE_PATH/domain/entities
mkdir -p $BASE_PATH/domain/hooks
mkdir -p $BASE_PATH/presentation/pages
mkdir -p $BASE_PATH/presentation/components

echo "Directory structure created successfully for feature: $FEATURE_NAME_LOWER"