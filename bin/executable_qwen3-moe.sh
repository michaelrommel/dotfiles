#! /usr/bin/env bash

llama-server \
	--host 192.168.13.187 \
	--port 8081 \
	--model /Volumes/DataMirror/Software/ai-models/models--unsloth--Qwen3.6-35B-A3B-MTP-GGUF/snapshots/5bc3e238d916f48a861bac2f8a1990a0e9b7e98d/Qwen3.6-35B-A3B-UD-Q6_K_XL.gguf \
	--mmproj /Volumes/DataMirror/Software/ai-models/models--unsloth--Qwen3.6-35B-A3B-MTP-GGUF/snapshots/5bc3e238d916f48a861bac2f8a1990a0e9b7e98d/mmproj-BF16.gguf \
	--alias "unsloth/Qwen3.6-35B" \
	--spec-type draft-mtp \
	--spec-draft-n-max 4 \
	--temp 0.4 \
	--top-k 20 \
	--top-p 0.95 \
	--min-p 0.00 \
	--threads 8 \
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
