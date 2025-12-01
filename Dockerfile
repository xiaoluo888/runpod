# ===== Base: Baidu FastDeploy CUDA 12.6 =====
FROM nvidia/cuda:12.6.0-base-ubuntu22.04 

RUN apt-get update -y \
    && apt-get install -y python3-pip

RUN ldconfig /usr/local/cuda-12.6/compat/

# Install Python dependencies
COPY builder/requirements.txt /requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    python3 -m pip install --upgrade pip && \
    python3 -m pip install paddlepaddle-gpu==3.2.2 -i https://www.paddlepaddle.org.cn/packages/stable/cu126/ && \
    python3 -m pip install fastdeploy-gpu==2.3.0 -i https://www.paddlepaddle.org.cn/packages/stable/fastdeploy-gpu-80_90/  --extra-index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple



# 避免交互 & 打印不缓冲
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# 可选：加一些系统工具（调试日志/证书等）
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl tini && \
    rm -rf /var/lib/apt/lists/*

# install runpod（Serverless SDK）
RUN pip install --no-cache-dir runpod


EXPOSE 8180

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["python3", "/src/handler.py"]
