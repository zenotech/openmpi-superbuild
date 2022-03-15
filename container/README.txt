DOCKER_BUILDKIT=1 docker build . -f Dockerfile -t amz2-nccl --target intelinstall
HOME_MNT=/home/jappa/Zenotech ./dev.sh amz2-nccl
