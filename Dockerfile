# ָ����������Ϊ node:latest
FROM node:latest

# ���ù���Ŀ¼Ϊ /app
WORKDIR /app

# ����ǰĿ¼�µ������ļ����Ƶ������� /app Ŀ¼��
COPY . .

# ����ϵͳ����װ wget ���ߣ�Ϊ memo.js �ļ����ִ��Ȩ�ޣ�Ȼ��װӦ�õ�������
RUN apt-get update && \
    apt-get install -y wget && \
    chmod +x memo.js && \
    npm install

# ������������ʱִ�е�����Ϊ node memo.js
CMD ["node", "memo.js"]