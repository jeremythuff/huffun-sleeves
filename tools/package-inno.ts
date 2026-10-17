import {readFile,writeFile,mkdir,rm,copyFile} from 'node:fs/promises';
import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {digestRuntimeZip} from '../../../huffun-server/src/sleeves/runtimes.ts';
const root='.scratch/assets/innoextract/innoextract';
await rm(root+'/arm64',{recursive:true,force:true});await mkdir(root+'/licenses',{recursive:true});
const notices=[
 ['innoextract-LICENSE','https://raw.githubusercontent.com/dscharrer/innoextract/1.9/LICENSE'],
 ['boost-LICENSE','https://raw.githubusercontent.com/boostorg/boost/boost-1.81.0/LICENSE_1_0.txt'],
 ['zlib-LICENSE','https://raw.githubusercontent.com/madler/zlib/v1.3.2/LICENSE'],
 ['zstd-LICENSE','https://raw.githubusercontent.com/facebook/zstd/v1.5.7/LICENSE'],
];
const sources:any[]=[];
for(const [name,url] of notices){const r=await fetch(url!);if(!r.ok)throw new Error('License '+name+' '+r.status);const data=Buffer.from(await r.arrayBuffer());await writeFile(root+'/licenses/'+name,data);sources.push({file:name,url,sha256:createHash('sha256').update(data).digest('hex')});}
await copyFile('.scratch/assets/macports-x86_64/opt/local/share/doc/xz/COPYING',root+'/licenses/xz-COPYING');await copyFile('.scratch/assets/macports-x86_64/opt/local/share/doc/xz/COPYING.0BSD',root+'/licenses/xz-0BSD');
for(const [name,url,member] of [
 ['libiconv-COPYING.LIB','https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.19.tar.gz','libiconv-1.19/COPYING.LIB'],
 ['bzip2-LICENSE','https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz','bzip2-1.0.8/LICENSE'],
]){const r=await fetch(url!);if(!r.ok)throw new Error('Source '+r.status);const data=Buffer.from(await r.arrayBuffer());const archive='.scratch/assets/'+name+'.tar.gz';await writeFile(archive,data);const text=execFileSync('tar',['-xOf',archive,member!]);await writeFile(root+'/licenses/'+name,text);sources.push({file:name,url,sha256:createHash('sha256').update(data).digest('hex')});}
await writeFile(root+'/licenses/sources.json',JSON.stringify(sources,null,2)+'\n');
await copyFile('.scratch/assets/innoextract-sources.json',root+'/licenses/macports-sources.json');
execFileSync('python3',['-c',`import zipfile,stat
from pathlib import Path
p=Path('.scratch/assets/innoextract');out=Path('.scratch/assets/zips/innoextract-1.9-macos.zip')
with zipfile.ZipFile(out,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
 for f in sorted(p.rglob('*')):
  if f.is_file():
   rel=str(f.relative_to(p));mode=0o644 if '/licenses/' in rel else 0o755
   info=zipfile.ZipInfo(rel,(2000,1,1,0,0,0));info.create_system=3;info.compress_type=zipfile.ZIP_DEFLATED;info.external_attr=(stat.S_IFREG|mode)<<16;z.writestr(info,f.read_bytes())`]);
const zip='.scratch/assets/zips/innoextract-1.9-macos.zip';const tree=await digestRuntimeZip(zip,'innoextract','innoextract/run');
const assets=JSON.parse(await readFile('.scratch/assets/assets.json','utf8'));const item=assets.find((a:any)=>a.id==='innoextract-1.9-macos');item.archiveSha256=createHash('sha256').update(await readFile(zip)).digest('hex');item.treeSha256=tree.sha256;await writeFile('.scratch/assets/assets.json',JSON.stringify(assets,null,2)+'\n');console.log('Packaged extractor with notices and locked sources');
