# 阶段一：依赖安装与构建
FROM node:20-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制子目录中的 package.json 和 lock 文件
COPY all-model-chat/package*.json ./

# 安装依赖
RUN npm install

# 复制子目录中的全部源码
COPY all-model-chat/ ./

# 执行构建（如果是 Next.js 项目，会生成 .next 产物）
RUN npm run build

# 阶段二：运行环境
FROM node:20-alpine AS runner

WORKDIR /app

# 从构建阶段复制所有文件（包含 node_modules 和构建产物）
COPY --from=builder /app ./

# 暴露默认端口 (一般是 3000)
EXPOSE 5173

# 启动服务
CMD ["npm", "start"]
