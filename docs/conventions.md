# Worker FastDeploy - Development Conventions & Architecture Guide

## Project Overview

**worker-FastDeploy** is a RunPod serverless worker that provides OpenAI-compatible endpoints for Large Language Model (LLM) inference, powered by the FastDeploy engine (PaddlePaddle-based). It enables blazing-fast LLM deployment on RunPod's serverless infrastructure with minimal configuration.

### Core Purpose

- **Primary Function**: Deploy any FastDeploy-compatible LLM as an OpenAI-compatible API endpoint
- **Platform**: RunPod Serverless infrastructure
- **Engine**: FastDeploy (high-performance LLM inference engine built on PaddlePaddle and custom kernels)
- **Compatibility**: Drop-in replacement for OpenAI API (Chat Completions, Models)

## High-Level Architecture

### 1. **Entry Point & Request Flow**

```
RunPod Request → handler.py → JobInput → Engine Selection → FastDeploy Generation → Streaming Response
```

**Key Components:**

- `src/handler.py`: Main entry point using RunPod serverless framework
- `src/utils.py`: Request parsing and utility classes (`JobInput`, `BatchSize`)
- Two engine modes: OpenAI-compatible vs. standard FastDeploy API

### 2. **Engine Architecture**

#### Core Classes:

- **`FastDeployEngine`**: Base engine handling FastDeploy initialization and generation
- **`OpenAIFastDeployEngine`**: Wrapper providing OpenAI API compatibility
- **Engine Selection**: Automatic routing based on `job_input.openai_route`

#### Key Design Patterns:

- **Dual API Support**: Same codebase serves both OpenAI-compatible and native FastDeploy-style APIs
- **Streaming by Default**: Token-level streaming with configurable batching
- **Dynamic Batching**: Adaptive batch sizes that grow from min → max for efficiency

### 3. **Configuration System**

#### Environment-Based Configuration:

- **Single Source of Truth**: All configuration via environment variables
- **Hierarchical Loading**: `DEFAULT_ARGS` → `os.environ` → `local_model_args.json` (for baked models)
- **FastDeploy Argument Mapping**: Automatic translation of env vars to FastDeploy engine arguments

#### Key Configuration Files:

- `src/engine_args.py`: Centralized configuration management
- `src/constants.py`: Default values for core settings
- `.runpod/hub.json`: Hub UI configuration (CRITICAL: always update when changing defaults)
- `worker-config.json`: UI form generation for RunPod console (if exists)

## Core Development Concepts

### 1. **Deployment Models**

#### Pre-built Docker Installation (Recommended)
For production or quick setup, the recommended approach is to use a pre-built Docker image with FastDeploy GPU pre-installed.

Notice: The pre-built image only supports SM80/SM90 GPUs (e.g. H800 / A800).
If you are deploying on SM86/SM89 GPUs (e.g. L40 / 4090 / L20), you should reinstall fastdeploy-gpu inside the container after creation.


- **Image**: `docker pull ccr-2vdh3abv-pub.cnc.bj.baidubce.com/paddlepaddle/fastdeploy-cuda-12.6:2.3.0` 
- **Configuration**: Entirely via environment variables
- **Model Loading**: Downloads or mounts model at runtime (e.g., from local volume or remote storage)
- **Use Case**: Quick deployment, model experimentation


### 2. **Request Processing Patterns**

#### Input Handling:

```python
class JobInput:
    - llm_input: str | List[Dict] (prompt or messages)
    - sampling_params: SamplingParams (generation settings)
    - stream: bool (streaming vs batch response)
    - openai_route: bool (API compatibility mode)
    - batch_size configs: Dynamic batching parameters
```

#### Response Streaming:

- **Batched Streaming**: Tokens grouped into configurable batch sizes
- **Usage Tracking**: Input/output token counting for billing and analytics

### 3. **Model & Tokenizer Management**

#### Tokenizer Handling:

- **Wrapper Pattern**: `TokenizerWrapper` for consistent chat template application
- **Special Cases**: Certain models may use their own native tokenizer or special chat formatting
- **Chat Templates**: Automatic application for message-based inputs

#### Model Loading:

- **Multi-GPU Support**: Automatic tensor parallelism detection or configuration
- **Quantization**: Support for quantized FastDeploy models (e.g., block_wise_fp8 / W4A8)
- **Caching**: Hugging Face cache management

## Development Patterns & Best Practices

### 1. **Code Organization**

#### File Structure:

```
src/
├── handler.py          # RunPod entry point
├── engine.py          # Core vLLM engines
├── engine_args.py     # Configuration management
├── utils.py           # Request parsing & utilities
├── tokenizer.py       # Tokenizer wrapper
├── constants.py       # Default constants
└── download_model.py  # Model downloading logic
```

#### Separation of Concerns:

- **Engine Logic**: Isolated in `engine.py` classes
- **Configuration**: Centralized in `engine_args.py`
- **Request Handling**: Abstracted via `JobInput` class
- **Platform Integration**: Contained in `handler.py`

### 2. **Error Handling & Logging**

#### Logging Strategy:

- **Structured Logging**: Consistent format across components
- **Error Context**: Detailed error messages with configuration context

#### Error Responses:

- **OpenAI Compatibility**: Standard OpenAI error format
- **Graceful Degradation**: Fallback behaviors for edge cases

### 3. **Environment Variable Conventions**

#### Naming Patterns:

- **FastDeploy Settings**: Match engine parameter names (uppercase)
- **RunPod Settings**: `MAX_CONCURRENCY`, `DEFAULT_BATCH_SIZE`
- **OpenAI Settings**: `OPENAI_` prefix for compatibility settings
- **Feature Flags**: `ENABLE_*`, `DISABLE_*` pattern

#### Type Conventions:

- **Booleans**: String 'true'/'false' or int 0/1
- **Lists**: Comma-separated strings
- **Objects**: JSON strings for complex configurations

### 4. **Docker & Deployment**

#### Multi-Stage Builds:

- **Base**: CUDA runtime environment
- **Dependencies**: Python packages, PaddlePaddle and FastDeploy
- **Model Download**: Model baking stage
- **Runtime**: Final application layer

#### Build Arguments:

- **MODEL**: Primary model identifier or path
- **QUANTIZATION**: Optimization settings
- **WORKER_CUDA_VERSION**: CUDA compatibility



