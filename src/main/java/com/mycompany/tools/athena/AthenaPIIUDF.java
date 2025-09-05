package com.mycompany.tools.athena;

import java.util.*;
import java.util.Base64.*;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import org.apache.commons.lang3.StringUtils;
import com.amazonaws.athena.connector.lambda.handlers.UserDefinedFunctionHandler;
import com.amazonaws.encryptionsdk.AwsCrypto;
import com.amazonaws.encryptionsdk.CommitmentPolicy;
import com.amazonaws.encryptionsdk.CryptoResult;
import com.amazonaws.encryptionsdk.kmssdkv2.KmsMasterKey;
import com.amazonaws.encryptionsdk.kmssdkv2.KmsMasterKeyProvider;

/**
 * Athena PII 数据解密用户定义函数 (UDF)
 * 
 * 功能：在 Amazon Athena 中解密由 AWS Glue DataBrew 加密的 PII 敏感数据字段
 * 用途：通过 Lambda 函数实现 Athena UDF，支持在 SQL 查询中直接解密加密字段
 * 加密方式：使用 AWS KMS 密钥和 AWS Encryption SDK 进行数据加密/解密
 */
public class AthenaPIIUDF extends UserDefinedFunctionHandler
{
    /** UDF 源类型标识 */
    private static final String SOURCE_TYPE = "MyCompany";
    
    /** Base64 解码器，用于解码加密数据 */
    private static Decoder base64Decoder = Base64.getDecoder();
    
    /** KMS 主密钥提供者 */
    private static KmsMasterKeyProvider keyProvider = null;
    
    /** 静态缓存映射，存储不同 KMS 密钥 ARN 对应的密钥提供者，避免重复创建 */
    private static Map<String, KmsMasterKeyProvider> staticMap = new HashMap<String, KmsMasterKeyProvider>();

    /** AWS 加密 SDK 客户端，配置为禁止加密但允许解密 */
    private static final AwsCrypto crypto = AwsCrypto.builder()
            .withCommitmentPolicy(CommitmentPolicy.ForbidEncryptAllowDecrypt)
            .build();

    /**
     * 构造函数
     * 初始化 Athena UDF 处理器
     */
    public AthenaPIIUDF() {
        super(SOURCE_TYPE);
    }

    /**
     * 解密函数 - Athena UDF 主要功能
     * 
     * @param ciphertext 加密的密文（Base64 编码）
     * @param keyArn KMS 密钥 ARN，用于解密
     * @return 解密后的明文字符串
     * @throws IllegalStateException 当使用错误的密钥时抛出异常
     */
    public static String decrypt(String ciphertext, String keyArn) {

        // 检查输入密文是否为空
        if (StringUtils.isBlank(ciphertext)) {
            return ciphertext;
        }

        // 移除字符串两端的引号（如果存在）
        if(ciphertext.startsWith("\"")){
            ciphertext = ciphertext.substring(1,ciphertext.length() - 1);
        }

        // 从缓存中获取或创建 KMS 密钥提供者
        if(staticMap.containsKey(keyArn)){
            keyProvider = staticMap.get(keyArn);
        }else{
            // 创建新的 KMS 密钥提供者并缓存
            keyProvider = KmsMasterKeyProvider.builder().buildStrict(keyArn);
            staticMap.put(keyArn, keyProvider);
        }

        // Base64 解码密文
        byte[] byteContent = base64Decoder.decode(ciphertext);

        // 使用 AWS Encryption SDK 解密数据
        final CryptoResult<byte[], KmsMasterKey> decryptResult = crypto.decryptData(keyProvider, byteContent);

        // 验证解密使用的密钥是否正确
        if (!decryptResult.getMasterKeyIds().get(0).equals(keyArn)) {
            throw new IllegalStateException("Wrong key id!");
        }

        // 将解密结果转换为 UTF-8 字符串返回
        return new String(decryptResult.getResult(), StandardCharsets.UTF_8);
    }
}
