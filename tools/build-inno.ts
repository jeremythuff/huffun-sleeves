import {readFile,writeFile,mkdir,readdir,copyFile} from 'node:fs/promises';
import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import path from 'node:path';
import {readMachO} from '../../../huffun-server/src/sleeves/macho.ts';
const lock:unknown[]=[];
// Run via the application Makefile after tools/stage.py. Only locked packages are used.
for(const arch of ['x86_64']) {
 const archives=`.scratch/assets/macports-${arch}`;await mkdir(archives,{recursive:true});
 for(const pkg of ['innoextract','boost181','xz','libiconv','zlib','zstd','bzip2']){
  const source=JSON.parse(await readFile('.scratch/sleeves-p35/resources/innoextract-sources.json','utf8')).find((x:any)=>x.pkg===pkg && x.arch===arch);
  if(!source)throw new Error('Missing locked source '+pkg);
  const url=source.url;const name=url.split('/').at(-1)!;
  const file=archives+'/'+name;
  const bytes=await readFile(file).catch(async()=>{const res=await fetch(url);if(!res.ok)throw new Error(`${pkg} ${res.status}`);return Buffer.from(await res.arrayBuffer());});
  if(createHash('sha256').update(bytes).digest('hex')!==source.sha256)throw new Error('Source digest changed '+pkg);
  await writeFile(file,bytes);execFileSync('tar',['-xjf',file,'-C',archives],{stdio:'ignore'});
  lock.push({arch,pkg,url,sha256:createHash('sha256').update(bytes).digest('hex')});
 }
 const files:string[]=[];async function walk(dir:string){for(const e of await readdir(dir,{withFileTypes:true})){const file=path.join(dir,e.name);if(e.isDirectory())await walk(file);else if(e.isFile()||e.isSymbolicLink())files.push(file);}}await walk(archives+'/opt/local');
 const wanted=[archives+'/opt/local/bin/innoextract'];const copied=new Set<string>();
 const out=`.scratch/assets/innoextract/innoextract/${arch}`;await mkdir(out+'/bin',{recursive:true});await mkdir(out+'/lib',{recursive:true});
 for(let i=0;i<wanted.length;i++){
  const file=wanted[i]!;const base=path.basename(file);if(copied.has(base))continue;copied.add(base);
  const bytes=await readFile(file);const images=await readMachO(async(o,n)=>bytes.subarray(o,o+n));if(!images)throw new Error(`${base} is not Mach-O`);
  await copyFile(file,out+(i===0?'/bin/':'/lib/')+base);
  for(const image of images)for(const lib of image.libraries){
   if(lib.name.startsWith('/usr/lib/')||lib.name.startsWith('/System/Library/'))continue;
   const found=files.find(f=>path.basename(f)===path.basename(lib.name));
   if(!found){if(lib.weak)continue;throw new Error(`Missing ${lib.name} for ${arch}`);}
   wanted.push(found);
  }
 }
 console.log(arch,'bundled',copied.size,'Mach-O files with closed dependency paths');
}
await writeFile('.scratch/assets/innoextract-sources.json',JSON.stringify(lock,null,2)+'\n');
const wrapper='#!/bin/sh\nset -eu\nHERE="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"\ncase "$(uname -m)" in arm64) CPU=x86_64 ;; x86_64) CPU=x86_64 ;; *) echo "Unsupported Mac CPU" >&2; exit 1 ;; esac\nexport DYLD_LIBRARY_PATH="$HERE/$CPU/lib"\nexec "$HERE/$CPU/bin/innoextract" "$@"\n';
await writeFile('.scratch/assets/innoextract/innoextract/run',wrapper,{mode:0o755});
