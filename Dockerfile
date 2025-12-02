# ===== Base: Baidu FastDeploy CUDA 12.6 =====
FROM ccr-2vdh3abv-pub.cnc.bj.baidubce.com/paddlepaddle/fastdeploy-cuda-12.6:2.2.1

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
