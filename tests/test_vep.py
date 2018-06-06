import requests

# volume test vep endpoint

headers = {'Content-type': 'application/json'}

with open('protein_effects.tsv') as f:
    content = f.readlines()
# you may also want to remove whitespace characters like `\n` at the end of each line
content = [x.strip() for x in content] 
for protein_effect in content:
    if not protein_effect.startswith('ENSP'):
        continue
    url = 'http://localhost:3000/vep/human/hgvs/{}?domains=1&protein=1&uniprot=1' \
        .format(protein_effect)
    print url
    r = requests.get(url, timeout=60, headers=headers)
    veps = r.json()
    if 'error' in veps:
        print veps, url
        continue

