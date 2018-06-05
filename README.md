# ensembl-rest
Language agnostic RESTful data access to Ensembl data over HTTP
Inspired by andrewyatz's vagrant effort https://github.com/andrewyatz/vagrant_machines/tree/master/ensembl/rest
## pre-requisites
docker
## setup perl environment, ubuntu packages, etc.
docker build -t ensembl-base -f Dockerfile-base . 
## configure it
docker build -t ensembl-rest -f Dockerfile-rest  . 
## start it 
docker run -d  --name ensembl-rest -p 3000:3000  -it ensembl-rest
## test 
curl 'http://localhost:3000/vep/human/hgvs/ENSP00000361021.3:p.Arg15Lys?domains=1&protein=1&uniprot=1'  -H "Accept: application/json"  | jq '.[0].id == "ENSP00000361021.3:p.Arg15Lys"'
curl 'http://localhost:3000/lookup/id/ENST00000275493?expand=1'  -H 'Content-type:application/json' | jq '.id == "ENST00000275493"'
## documentation
### installation
https://github.com/Ensembl/ensembl-rest/wiki/REST-Installation-and-Development
### api
https://rest.ensembl.org/documentation/info/lookup
https://rest.ensembl.org/documentation/info/vep_hgvs_get


