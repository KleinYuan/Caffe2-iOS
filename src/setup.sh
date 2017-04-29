echo "git cloning Caffe2"
git clone --recursive https://github.com/caffe2/caffe2.git

echo "build ios"
cd caffe2 && ./scripts/build_ios.sh

echo "Done"
