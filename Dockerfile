# ⚔️ 三省六部 · Dashboard (Standalone, no OpenClaw required)

# Stage 1: 构建 React 前端
FROM node:20-alpine AS frontend-build
WORKDIR /build
COPY edict/frontend/package.json edict/frontend/package-lock.json ./
RUN npm ci --silent
COPY edict/frontend/ ./
# Build 输出到 /build/dist
RUN npx vite build --outDir /build/dist

# Stage 2: 运行时
FROM python:3.11-slim
WORKDIR /app

# 复制看板核心文件
COPY dashboard/ ./dashboard/
COPY scripts/ ./scripts/

# 复制 React 构建产物
COPY --from=frontend-build /build/dist ./dashboard/dist/

# 注入演示数据
COPY docker/demo_data/ ./data/

# 非 root 用户运行
RUN groupadd -r appuser && useradd -r -g appuser -d /app appuser \
    && chown -R appuser:appuser /app
USER appuser

EXPOSE 7891

# server_standalone.py 会自动读取 PORT 环境变量
CMD ["python3", "dashboard/server_standalone.py"]
