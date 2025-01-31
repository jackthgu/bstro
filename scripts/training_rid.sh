PRETRAINED="3dpw" 
BATCHSIZE=$1

# source /is/cluster/work/chuang2/virtualenv/metro/bin/activate
# conda activate bstro
# cd /home/chunhaoh/sensei-fs-symlink/users/chunhaoh/code_repo/bstro

echo "initializing backbone weights with $PRETRAINED"
resume_checkpoint=models/metro_release/metro_${PRETRAINED}_state_dict.bin

python3 -m torch.distributed.launch --nproc_per_node=1 \
        metro/tools/run_bstro_hsc.py \
        --train_yaml rich_for_bstro_tsv_db/train.yaml \
        --val_yaml rich_for_bstro_tsv_db/val.yaml \
        --arch hrnet-w32 \                       # 기존 hrnet-w64 → hrnet-w32로 경량화
        --num_hidden_layers 2 \                  # 기존 4 → 2 (Transformer 레이어 수 축소)
        --num_attention_heads 2 \                # 기존 4 → 2 (어텐션 헤드 수 축소)
        --num_workers 4 \
        --per_gpu_train_batch_size ${BATCHSIZE} \
        --per_gpu_eval_batch_size 8 \
        --lr 1e-4 \
        --num_train_epochs 100 \
        --input_feat_dim 2051,512,128 \
        --hidden_feat_dim 1024,256,128 \
        --output_dir output \
        --resume_checkpoint $resume_checkpoint