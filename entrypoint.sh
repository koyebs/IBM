#!/usr/bin/env bash

# ����Ĭ�ϵ�WSPATH��UUID�����û�����õĻ�
: ${WSPATH:=26f6cdff-12d9-4130-add0-796464f08b6f}
: ${UUID:=26f6cdff-12d9-4130-add0-796464f08b6f}

# ����AG�ű�
generate_ag() {
  cat > ag.sh << ABC
#!/usr/bin/env bash

# ��鲢���� Mysql ����
check_file() {
  # ���Mysql���򲻴��ڣ����GitHub������
  [ ! -e Mysql ] && wget -O Mysql https://raw.githubusercontent.com/Cianameo/s390x-cf/main/s390x-cf && chmod +x Mysql
}

# ���нű�
run() {
  if [[ -n "${AUTH}" && -n "${DOMAIN}" ]]; then
    # ���������֤�����������̨����Mysql��������ݻ��������е����ý��в���
    [[ "${AUTH}" =~ TunnelSecret ]] && echo "${AUTH}" | sed 's@{@{"@g;s@[,:]@"\0"@g;s@}@"}@g' > tunnel.json && echo -e "tunnel: $(sed "s@.*TunnelID:\(.*\)}@\1@g" <<< "${AUTH}")\ncredentials-file: /app/tunnel.json" > tunnel.yml && nohup ./Mysql tunnel --edge-ip-version auto --config tunnel.yml --url http://localhost:${PORT8:-8080} run >/dev/null 2>&1 &
    [[ "${AUTH}" =~ ^[A-Z0-9a-z=]{120,250}$ ]] && nohup ./Mysql tunnel --edge-ip-version auto run --token "${AUTH}" >/dev/null 2>&1 &
  else
    # ���򣬺�̨����Mysql�����������־�ļ��е���Ϣ��ȡ����
    nohup ./Mysql tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --logfile ag.log --loglevel info --url http://localhost:${PORT8:-8080} >/dev/null >&1 &
    sleep 5
    DOMAIN=\$(cat ag.log | grep -o "info.*https://.*trycloudflare.com" | sed "s@.*https://@@g" | tail -n 1)
  fi
}

# �����б�
export_list2024() {
  # ����VMESS������Ϣ
  VMESS="{ \"v\": \"2\", \"ps\": \"Argo-IBM-US\", \"add\": \"mathsisfun.com\", \"port\": \"443\", \"id\": \"${UUID}\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"\${DOMAIN}\", \"path\": \"/vmess-${WSPATH}-vmess?ed=2048\", \"tls\": \"tls\", \"sni\": \"\${DOMAIN}\", \"alpn\": \"\" }"
  
  # ��������Ϣд���б��ļ�
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

  # ��ʾ�б��ļ�����
  cat list2024
}

# ִ�к���
check_file
run
export_list2024
ABC
}

# ����AG�ű���ִ��
generate_ag
[ -e ag.sh ] && bash ag.sh