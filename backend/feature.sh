#!/bin/bash

# Verify input
if [ $# -eq 0 ]; then
    echo "Usage: $0 <feature-name>"
    exit 1
fi

# Get the feature name
FEATURE_NAME=$1
FEATURE_NAME_LOWER=$(echo $FEATURE_NAME | tr '[:upper:]' '[:lower:]')
FEATURE_NAME_PASCAL=$(echo $FEATURE_NAME | perl -pe 's/\b([a-z])/\u$1/g')

# Define the base path for the feature
BASE_PATH="src/features/$FEATURE_NAME_LOWER"

# Create feature directories
mkdir -p "$BASE_PATH/domains"
mkdir -p "$BASE_PATH/domains/dtos"
mkdir -p "$BASE_PATH/domains/schemas"
mkdir -p "$BASE_PATH/domains/entities"
mkdir -p "$BASE_PATH/interfaces/services"
mkdir -p "$BASE_PATH/interfaces/repositories"
mkdir -p "$BASE_PATH/modules/controllers"
mkdir -p "$BASE_PATH/modules/implementation/services"
mkdir -p "$BASE_PATH/modules/implementation/repositories"
mkdir -p "$BASE_PATH/modules/implementation/mappers"
mkdir -p "$BASE_PATH/utils"

# Create feature module file
touch "$BASE_PATH/$FEATURE_NAME_LOWER.module.ts"

# Generate module content
echo "import { Module } from '@nestjs/common';

@Module({
  imports: [],
  exports: [],
})

export class ${FEATURE_NAME_PASCAL}Module {}" > "$BASE_PATH/$FEATURE_NAME_LOWER.module.ts"

echo "Directory structure created successfully for feature: $FEATURE_NAME_LOWER"