#! /usr/bin/env bash

llama-server \
	--host 192.168.13.187 \
	--port 8081 \
	-hf unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q6_K_XL \
	--spec-type draft-mtp \
	--spec-draft-n-max 2 \
	--temp 0.6 \
	--top-k 20 \
	--top-p 0.95 \
	--min-p 0.00 \
	--threads 8 \
	--threads-batch 16 \
	--gpu-layers 99 \
	--flash-attn on \
	--cache-type-k q8_0 \
	--cache-type-v q8_0 \
	--image-min-tokens 1024 \
	--ctx-size 131072 \
	--reasoning auto \
	--reasoning-format auto \
	--reasoning-preserve

### DO NOT USE!!!
#	--chat-template qwen
#	--chat-template-kwargs '{"preserve_thinking":true}'
