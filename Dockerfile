# ===== Base: Baidu FastDeploy CUDA 12.6 =====
FROM xiaoluo888/worker-fastdeploy:latest

EXPOSE 8180

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["python3", "/src/handler.py"]
