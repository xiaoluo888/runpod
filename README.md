
[![Runpod](https://api.runpod.io/badge/xiaoluo888/runpod)](https://www.console.runpod.io/hub/xiaoluo888/runpod)

# FastDeploy Serverless Worker (Test)

Serverless worker using Baidu FastDeploy (CUDA 12.6) on RunPod Hub.

What’s included

Type: serverless

Category: language

GPU: gpuCount=1

Allowed CUDA: 12.8 / 12.7 / 12.6

GPU IDs：
NVIDIA H100 80GB HBM3,
NVIDIA A100 80GB PCIe,
NVIDIA RTX A2000, NVIDIA RTX A4000, NVIDIA RTX A5000, NVIDIA RTX A6000,
NVIDIA GeForce RTX 4090, NVIDIA GeForce RTX 3090


Preset: ERNIE

MODEL_REPO=baidu/ERNIE-4.5-0.3B-Paddle

MAX_MODEL_LEN=32768

MAX_NUM_SEQS=32

ENABLE_V1_KVCACHE_SCHEDULER=1

Environment variables (editable in the UI):

MAX_MODEL_LEN (number 1024–65536)

MAX_NUM_SEQS (number 1–64)


