#!/bin/bash
# =============================================================================
# Maven 项目初始化脚本
# =============================================================================
# 功能：创建 Athena UDF PII 解密项目的 Maven 项目结构
# 用途：自动化生成标准的 Java Maven 项目，用于开发 Athena 用户定义函数
# 输出：生成完整的 Maven 项目目录结构和初始代码框架
# =============================================================================

# 使用 Maven 创建项目
# 使用标准的 Maven archetype 生成项目结构
mvn -B archetype:generate \
-DarchetypeGroupId=org.apache.maven.archetypes \
-DgroupId=com.mycompany.tools.athena \
-DartifactId=athena-udf-glue-pii-decryption

# 进入项目目录
cd athena-udf-glue-pii-decryption

# 构建项目
# 清理之前的构建并重新编译安装
mvn clean install
