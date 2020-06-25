#!/bin/bash -e

# Creates the lambda_function_payload.zip file from the src folder.

cd ./src
zip -r ../lambda_function_payload.zip .
