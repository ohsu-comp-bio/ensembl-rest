# ensembl-rest
Language agnostic RESTful data access to Ensembl data over HTTP
Inspired by andrewyatz's vagrant effort https://github.com/andrewyatz/vagrant_machines/tree/master/ensembl/rest
## pre-requisites
docker
## setup perl environment, ubuntu packages, etc.
docker build -t ensembl-base -f Dockerfile-base . 
## data setup
```
mkdir ./data
docker run -v $(pwd)/data:/root/.vep   --rm -it ensembl-base bash /deploy/data.sh
```
( now the $(pwd)/data persists across instances.  It can be backed-up / restored from an object store ) 
## configure it
docker build -t ensembl-rest -f Dockerfile-rest  . 
## start it , mapping persistent data to the instance
docker run -v $(pwd)/data:/root/.vep  -p 3000:3000  -it ensembl-rest
## test 
curl 'http://localhost:3000/vep/human/hgvs/ENSP00000361021.3:p.Arg15Lys?domains=1&protein=1&uniprot=1'  -H "Accept: application/json"  | jq '.[0].id == "ENSP00000361021.3:p.Arg15Lys"'
curl 'http://localhost:3000/lookup/id/ENST00000275493?expand=1'  -H 'Content-type:application/json' | jq '.id == "ENST00000275493"'
## documentation
### installation
https://github.com/Ensembl/ensembl-rest/wiki/REST-Installation-and-Development
### api
https://rest.ensembl.org/documentation/info/lookup
https://rest.ensembl.org/documentation/info/vep_hgvs_get
### known issues
* Due to slow build times, docker build broken into two steps: ensembl-base contains perl and data , ensemble-rest configures endpoint
* The first request to each endpoint is slow due to startup 
* Local mysql data has not been setup, the /lookup service uses external db at anonymous@ensembldb.ensembl.org:3337 
  * https://github.com/Ensembl/ensembl-rest/wiki/REST-Installation-and-Development#speeding-up-id-lookup
  * https://uswest.ensembl.org/info/docs/webcode/mirror/install/ensembl-data.html
    * ftp://ftp.ensembl.org/pub/grch37/release-92/mysql/
  * If environmental var DEPLOY_MYSQL is set, mysql will be installed in ensembl-base.  Optionally, you can set  MYSQL_PASSWORD, MYSQL_USER
#### next steps
* define volumes to persist ensembl data outside the container.  (externalize /root/.vep and persist data to object store)


