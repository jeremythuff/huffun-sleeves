"""Repackage verified runtime trees on the Mac's Podman; never run on a Pi."""
import hashlib,json,os,stat,sys,zipfile
from pathlib import Path
stage=Path(sys.argv[1]); resources=json.loads((stage/'resources.json').read_text());out=stage/'zips';out.mkdir(exist_ok=True)
result=[]
for resource in resources:
    entries=json.loads(resource['manifest']);file=out/(resource['id']+'.zip')
    with zipfile.ZipFile(file,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
        for entry in sorted(entries,key=lambda x:x['path']):
            info=zipfile.ZipInfo(entry['path'],(2000,1,1,0,0,0));info.create_system=3;info.compress_type=zipfile.ZIP_DEFLATED
            if 'link' in entry:
                data=entry['link'].encode();info.external_attr=(stat.S_IFLNK|0o777)<<16
            else:
                p=stage/'trees'/resource['relative_path']/entry['path'];data=p.read_bytes()
                if len(data)!=entry['size']: raise RuntimeError('Runtime file size changed: '+entry['path'])
                info.external_attr=(stat.S_IFREG|(0o755 if entry['executable'] else 0o644))<<16
            z.writestr(info,data)
    result.append({'id':resource['id'],'file':file.name,'archiveSha256':hashlib.sha256(file.read_bytes()).hexdigest(),'treeSha256':resource['tree_sha256'],'sourceUrl':resource['source_url']})
(stage/'existing-assets.json').write_text(json.dumps(result,indent=2)+'\n')
print('Repacked',len(result),'runtime archives with original paths, modes and link targets')
