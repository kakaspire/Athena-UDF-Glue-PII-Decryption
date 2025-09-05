# Athena UDF Glue PII Decryption

Amazon Athena User Defined Function (UDF) for decrypting PII data encrypted by AWS Glue DataBrew.

## Overview

This project provides a Lambda-based UDF that enables Amazon Athena to decrypt sensitive PII data that was encrypted using AWS Glue DataBrew. The UDF uses AWS KMS keys and the AWS Encryption SDK for secure decryption operations.

## Features

- Decrypt Base64-encoded encrypted data in Athena SQL queries
- Support for AWS KMS key-based decryption
- Caching mechanism for KMS key providers to improve performance
- Compatible with AWS China regions

## Prerequisites

- Java 11 or higher
- Maven 3.6+
- AWS CLI configured with appropriate permissions
- AWS SAM CLI for deployment

## Quick Start

1. **Build the project**
   ```bash
   ./Tools/02_MavenProject.sh
   ```

2. **Deploy to AWS**
   ```bash
   ./Tools/03_publish.sh
   ```

3. **Use in Athena**
   ```sql
   SELECT decrypt(encrypted_field, 'arn:aws:kms:region:account:key/key-id') 
   FROM your_table;
   ```

## Project Structure

```
├── src/main/java/com/mycompany/tools/athena/
│   └── AthenaPIIUDF.java          # Main UDF implementation
├── Tools/
│   ├── 01_uploaddata.sh           # Data upload script
│   ├── 02_MavenProject.sh         # Maven project setup
│   └── 03_publish.sh              # AWS deployment script
├── athena-udf-gluepii.yaml        # SAM template
└── pom.xml                        # Maven configuration
```

## Usage

The UDF provides a `decrypt` function that takes two parameters:

- `ciphertext`: Base64-encoded encrypted data
- `keyArn`: AWS KMS key ARN for decryption

Example:
```sql
SELECT 
    name,
    decrypt(encrypted_ssn, 'arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012') as ssn
FROM customer_data;
```