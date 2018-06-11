cd /root/src
apt-get install -y liblzma-dev libbz2-dev

wget https://github.com/samtools/htslib/releases/download/1.8/htslib-1.8.tar.bz2
tar xvjf  htslib-1.8.tar.bz2
ln -s /root/src/htslib-1.8 htslib
cd htslib
make
export HTSLIB_DIR=/root/src/htslib
export PATH=$PATH:$HTSLIB_DIR
cd ..


git clone --branch master --depth 1 https://github.com/Ensembl/faidx_xs.git
(cd faidx_xs && perl Makefile.PL && make && make install)


cpanm Bio::DB::HTS

