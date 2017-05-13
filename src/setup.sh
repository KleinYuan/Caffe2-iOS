echo "[Step1] Installing dependencies"
brew install automake libtool

echo "[Step2] git cloning Caffe2"
git clone --recursive https://github.com/caffe2/caffe2.git

echo "[Step3] build ios"
cd caffe2 && ./scripts/build_ios.sh

echo "[Tada!] Done"
