create database pii_sample_db

--Create table databrew_pii_sensitive_data from S3 file with csv format
CREATE EXTERNAL TABLE `databrew_pii_sensitive_data`(
  `SSN` string, 
  `gender` string, 
  `birthdate` string, 
  `maidenname` string, 
  `lastname` string, 
  `firstname` string, 
  `address` string, 
  `city` string, 
  `state` string, 
  `zip` string, 
  `phone` string, 
  `email` string, 
  `cc_type` string, 
  `CCN` string, 
  `cc_cvc` string, 
  `cc_expiredate` string
  )
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
LOCATION
  's3://databrew-pii-data-zhanla/sensitive_data_input/'
TBLPROPERTIES ("skip.header.line.count"="1");  

--Create table databrew_pii_encrypted_data from S3 file with Parquet format
CREATE EXTERNAL TABLE `databrew_pii_encrypted_data` (
  `SSN` string, 
  `gender` string, 
  `birthdate` string, 
  `maidenname` string, 
  `lastname` string, 
  `firstname` string, 
  `address` string, 
  `city` string, 
  `state` string, 
  `zip` int, 
  `phone` string, 
  `email` string, 
  `cc_type` string, 
  `CCN` string, 
  `cc_cvc` int, 
  `cc_expiredate` string
  )
STORED AS PARQUET
LOCATION 's3://databrew-pii-data-zhanla/encrypted_data_output/'

-- decrypt data.
USING EXTERNAL FUNCTION decrypt(t1 varchar, t2 varchar)
RETURNS varchar 
LAMBDA 'athena-udf-gluepii'
SELECT 
       decrypt(ssn, 'arn:aws-cn:kms:<region>:<account-id>:key/<key-id')  ssnplaintext,*
FROM databrew_pii_encrypted_data

arn:aws-cn:kms:<region>:<account-id>:key/<key-id