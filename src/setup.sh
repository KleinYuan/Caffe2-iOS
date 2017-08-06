echo "[Step1] Installing dependencies"
brew install automake libtool

echo "[Step2] git cloning Caffe2"
git clone --recursive https://github.com/caffe2/caffe2.git

echo "[Step2 - b] checkout to a stable version tags/v0.7.0-163-gebc17cc8"
cd caffe2 && git checkout tags/v0.7.0-163-gebc17cc8

echo "[Step3] build ios"
./scripts/build_ios.sh

echo "[Tada!] Done"
