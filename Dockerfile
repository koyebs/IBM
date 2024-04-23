# 指定基础镜像为 node:latest
FROM node:latest

# 设置工作目录为 /app
WORKDIR /app

# 将当前目录下的所有文件复制到容器的 /app 目录下
COPY . .

# 更新系统并安装 wget 工具，为 memo.js 文件添加执行权限，然后安装应用的依赖项
RUN apt-get update && \
    apt-get install -y wget && \
    chmod +x memo.js && \
    npm install

# 定义容器启动时执行的命令为 node memo.js
CMD ["node", "memo.js"]