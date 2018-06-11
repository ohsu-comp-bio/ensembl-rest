cd /root/src


PERL5LIB=/root/src/ensembl-vep/modules:/root/src/ensembl-io/modules:/root/src/ensembl-funcgen/modules:/root/src/ensembl-variation/modules:/root/src/ensembl-compara/modules:/root/src/ensembl/modules:/root/src/bioperl-1.6.9:/root/src/ensembl-rest/ensembl-funcgen/modules:/root/src/ensembl-rest/ensembl-variation/modules:/root/src/ensembl-rest/ensembl-compara/modules:/root/src/ensembl-rest/ensembl/modules:/root/src/ensembl-rest/bioperl-1.6.9::/root/src/tabix-master/perl/blib/lib:/root/src/tabix-master/perl/blib/arch


TABIX_HOME=/root/src/tabix-master
PERL5LIB=${PERL5LIB}:${TABIX_HOME}/perl/blib/lib:${TABIX_HOME}/perl/blib/arch
export PERL5LIB

# Setup LD_LIBRARY_PATH
LD_LIBRARY_PATH=${TABIX_HOME}
export LD_LIBRARY_PATH

cd /root/src/ensembl-vep
perl INSTALL.pl -a cf -s homo_sapiens -y GRCh37
cd /root/.vep/homo_sapiens/92_GRCh37
uncompress  Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz

cd /root/src/ensembl-rest
cpanm --installdeps .

# Confirming the setup
perl Makefile.PL


wget ftp://ftp.ensembl.org/pub/release-75/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.75.dna.toplevel.fa.gz -O /root/.vep/Homo_sapiens.GRCh37.75.dna.toplevel.fa.gz
cd /root/.vep
uncompress Homo_sapiens.GRCh37.75.dna.toplevel.fa.gz

