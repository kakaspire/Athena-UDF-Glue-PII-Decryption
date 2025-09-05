#!/bin/bash
# =============================================================================
# PII 敏感数据上传脚本
# =============================================================================
# 功能：为 Glue DataBrew PII 数据处理项目创建 S3 存储环境并上传测试数据
# 用途：自动化创建 S3 存储桶、目录结构，并上传 PII 敏感数据样例文件
# 目标：为 Athena UDF Glue PII 解密功能提供测试数据环境
# 输出：完整的 S3 数据存储结构，包含敏感数据输入、处理输出等目录
# =============================================================================

# 配置参数 - 请根据实际情况修改以下参数
REGION="cn-northwest-1"              # AWS区域
S3_BUCKET="s3://databrew-pii-data-zhanla"  # S3存储桶名称
PROFILE=""                           # AWS配置文件名称（可选）

# 注意: 以下命令格式有误，已注释
# aws s3 mb databrew-pii-data-zhanla --profile profile 842632050632/cn-2-admin

echo "开始创建S3存储桶和上传数据..."

# 步骤1: 创建S3存储桶
echo "正在创建S3存储桶: databrew-pii-data-zhanla"
aws s3 mb  $S3_BUCKET --region $REGION --profile $PROFILE

# 步骤2: 创建必要的文件夹结构（S3前缀）
echo "正在创建文件夹结构..."
# 敏感数据输入目录
aws s3api put-object --bucket databrew-pii-data-zhanla --key sensitive_data_input/ --region $REGION --profile $PROFILE
# 数据分析作业输出目录
aws s3api put-object --bucket databrew-pii-data-zhanla --key profile_job_out/ --region $REGION --profile $PROFILE
# 加密数据输出目录
aws s3api put-object --bucket databrew-pii-data-zhanla --key encrypted_data_output/ --region $REGION --profile $PROFILE

# 步骤3: 上传样例数据文件
echo "正在上传样例数据文件..."
aws s3 cp ./sample-data.csv s3://databrew-pii-data-zhanla/sensitive_data_input/sample-data.csv --region $REGION --profile $PROFILE

echo "数据上传完成！"