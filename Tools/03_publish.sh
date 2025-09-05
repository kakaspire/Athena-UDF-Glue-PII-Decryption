#!/bin/bash
# =============================================================================
# AWS SAM 应用发布脚本 - 中国区域版本
# =============================================================================
# 功能：将 Athena UDF Glue PII 解密应用发布到 AWS 区域的 Serverless Application Repository
# 用途：自动化构建、打包和发布 Lambda 函数，用于 Athena 中解密 Glue 加密的 PII 数据
# 目标区域：AWS 中国（宁夏）区域 (cn-northwest-1)
# =============================================================================

# 使用中国区域（宁夏）
REGION="cn-northwest-1"
# S3 存储桶名称，用于存储 SAM 包
S3_BUCKET="aws-sam-cli-managed-default-samclisourcebucket-1r3oxzvlxy6wy" 
# AWS 配置文件，用于认证
PROFILE=""

# 输出配置信息
echo "S3_BUCKET is " $S3_BUCKET
echo "home is" $HOME
echo "profile is " $PROFILE
# 切换到项目目录
cd  ./athena-udf-glue-pii-decryption

# 构建项目
# 清理并重新编译安装 Maven 项目
mvn clean install

# 打包 SAM 应用
# 将模板文件和依赖项打包上传到 S3
sam package --template-file athena-udf-glue-pii.yaml --output-template-file packaged.yaml --s3-bucket $S3_BUCKET --region $REGION --profile $PROFILE

# 发布 SAM 应用到 AWS Serverless Application Repository
sam publish --template packaged.yaml --region $REGION --profile $PROFILE
