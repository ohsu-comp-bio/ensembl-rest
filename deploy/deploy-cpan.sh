#!/bin/sh
# Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ENSEMBL_VERSION=$1
TEST_ENV=$2


# Go for catalyst & main dependencies from CPAN
cpanm Module::Install
cpanm Catalyst Catalyst::Devel
cpanm Hash::Merge

# Going for the other CPANM dependencies
cpanm Catalyst::Plugin::ConfigLoader Catalyst::Plugin::Static::Simple Catalyst::Action::RenderView Catalyst::Component::InstancePerContext Catalyst::View::JSON Log::Log4perl::Catalyst Catalyst::Plugin::Cache Parse::RecDescent Catalyst::Controller::REST Catalyst::View::TT

# CHI dependencies
cpanm CHI CHI::Driver::Memcached::Fast

# Test case dependencies
cpanm Test::XPath Test::XML::Simple

# ensembl-test dependencies
cpanm Devel::Peek Devel::Cycle Error IO::String PadWalker Test::Builder::Module

# User settings
home=/root
user=vagrant

mkdir -p $home
# Install Ensembl Git Tools
if [ -d $home/programs ]; then
  rm -rf $home/programs
fi
mkdir $home/programs
cd $home/programs
git clone https://github.com/Ensembl/ensembl-git-tools.git
cd $home

# Install BioPerl
mkdir -p $home/src
cd $home/src
wget https://github.com/bioperl/bioperl-live/archive/bioperl-release-1-6-9.tar.gz
tar zxf bioperl-release-1-6-9.tar.gz
mv bioperl-live-bioperl-release-1-6-9 bioperl-1.6.9

# Install Tabix locally
wget https://github.com/samtools/tabix/archive/master.tar.gz
tar zxf master.tar.gz
(cd tabix-master && make)
(cd tabix-master/perl && perl Makefile.PL && make)

# Install Ensembl APIs using shallow clone & move onto the release branch
cd $home/src
$home/programs/ensembl-git-tools/bin/git-ensembl --clone rest ensembl-test
$home/programs/ensembl-git-tools/bin/git-ensembl --checkout --branch "release/$ENSEMBL_VERSION" rest ensembl-test

# Copy settings into place
cp /settings/profile $home/.profile

if [ -n "$TEST_ENV" ]; then
  cp /settings/MultiTestDB.conf $home/src/ensembl-rest/t/.
fi

# Chown all these files to vagrant
# chown -R $user:$user $home/.profile $home/src $home/programs

# DONE!


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


cpanm Bio::DB::HTS --force

PERL5LIB=/root/src/ensembl-vep/modules:/root/src/ensembl-io/modules:/root/src/ensembl-funcgen/modules:/root/src/ensembl-variation/modules:/root/src/ensembl-compara/modules:/root/src/ensembl/modules:/root/src/bioperl-1.6.9:/root/src/ensembl-rest/ensembl-funcgen/modules:/root/src/ensembl-rest/ensembl-variation/modules:/root/src/ensembl-rest/ensembl-compara/modules:/root/src/ensembl-rest/ensembl/modules:/root/src/ensembl-rest/bioperl-1.6.9::/root/src/tabix-master/perl/blib/lib:/root/src/tabix-master/perl/blib/arch


TABIX_HOME=/root/src/tabix-master
PERL5LIB=${PERL5LIB}:${TABIX_HOME}/perl/blib/lib:${TABIX_HOME}/perl/blib/arch
export PERL5LIB

# Setup LD_LIBRARY_PATH
LD_LIBRARY_PATH=${TABIX_HOME}
export LD_LIBRARY_PATH

cd /root/src/ensembl-rest
cpanm --installdeps . --force

# Confirming the setup
perl Makefile.PL
