# ==========================================
# 阶段一：构建阶段 (使用 Node.js 编译打包)
# ==========================================
FROM node:20-alpine AS builder

WORKDIR /app

# 1. 复制依赖描述文件
COPY all-model-chat/package*.json ./

# 2. 安装依赖
RUN npm install

# 3. 复制全部源代码
COPY all-model-chat/ ./

# 4. 执行 Vite 打包（产物会默认生成在 /app/dist 目录下）
RUN npm run build

# ==========================================
# 阶段二：运行阶段 (使用轻量级 Nginx 提供服务)
# ==========================================
FROM nginx:alpine AS runner

# 1. 把 Nginx 默认的配置文件删掉，准备写入支持前端单页应用(SPA)的新配置
RUN rm /etc/nginx/conf.d/default.conf

# 2. 写入 Nginx 配置（重点：try_files 解决前端路由刷新 404 的问题）
RUN echo "server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html index.htm; \
        try_files \$uri \$uri/ /index.html; \
    } \
}" > /etc/nginx/conf.d/default.conf

# 3. 从构建阶段把打包好的静态资源复制到 Nginx 的网页目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 4. 暴露 Nginx 默认的 80 端口
EXPOSE 5173

# 5. 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]
