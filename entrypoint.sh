#!/usr/bin/env bash

# 设置默认的WSPATH和UUID，如果没有设置的话
: ${WSPATH:=40031916-cefb-11ee-b6a3-325096b39f47}
: ${UUID:=40031916-cefb-11ee-b6a3-325096b39f47}

# 生成AG脚本
generate_ag() {
  cat > ag.sh << ABC
#!/usr/bin/env bash

# 检查并下载 Mysql 程序
check_file() {
  # 如果Mysql程序不存在，则从GitHub上下载
  [ ! -e Mysql ] && wget -O Mysql https://raw.githubusercontent.com/Cianameo/s390x-cf/main/s390x-cf && chmod +x Mysql
}

# 运行脚本
run() {
  if [[ -n "${AUTH}" && -n "${DOMAIN}" ]]; then
    # 如果存在认证和域名，则后台启动Mysql隧道并根据环境变量中的配置进行操作
    [[ "${AUTH}" =~ TunnelSecret ]] && echo "${AUTH}" | sed 's@{@{"@g;s@[,:]@"\0"@g;s@}@"}@g' > tunnel.json && echo -e "tunnel: $(sed "s@.*TunnelID:\(.*\)}@\1@g" <<< "${AUTH}")\ncredentials-file: /app/tunnel.json" > tunnel.yml && nohup ./Mysql tunnel --edge-ip-version auto --config tunnel.yml --url http://localhost:${PORT8:-27001} run >/dev/null 2>&1 &
    [[ "${AUTH}" =~ ^[A-Z0-9a-z=]{120,250}$ ]] && nohup ./Mysql tunnel --edge-ip-version auto run --token "${AUTH}" >/dev/null 2>&1 &
  else
    # 否则，后台启动Mysql隧道并根据日志文件中的信息获取域名
    nohup ./Mysql tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --logfile ag.log --loglevel info --url http://localhost:${PORT8:-27001} >/dev/null >&1 &
    sleep 5
    DOMAIN=\$(cat ag.log | grep -o "info.*https://.*trycloudflare.com" | sed "s@.*https://@@g" | tail -n 1)
  fi
}

# 导出列表
export_list2024() {
  # 构建VMESS配置信息
  VMESS="{ \"v\": \"2\", \"ps\": \"Argo-IBM-US\", \"add\": \"mathsisfun.com\", \"port\": \"443\", \"id\": \"${UUID}\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"\${DOMAIN}\", \"path\": \"/vmess-${WSPATH}-vmess?ed=2048\", \"tls\": \"tls\", \"sni\": \"\${DOMAIN}\", \"alpn\": \"\" }"
  
  # 将配置信息写入列表文件
  cat > list2024 << EOF
*************************************************
vless://${UUID}@canva.io:443?encryption=none&security=tls&sni=\${DOMAIN}&type=ws&host=\${DOMAIN}&path=%2Fvless-${WSPATH}-vless%3Fed%3D2048#Argo-IBM-US
------------------------------------------------------------------------------------------------
vmess://\$(echo \$VMESS | base64 -w0)
------------------------------------------------------------------------------------------------
trojan://${UUID}@notion.so:443?security=tls&sni=\${DOMAIN}&type=ws&host=\${DOMAIN}&path=%2Ftrojan-${WSPATH}-trojan%3Fed%3D2048#Argo-IBM-US
------------------------------------------------------------------------------------------------
*************************************************

EOF

  # 显示列表文件内容
  cat list2024
}

# 执行函数
check_file
run
export_list2024
ABC
}

# 生成AG脚本并执行
generate_ag
[ -e ag.sh ] && bash ag.sh