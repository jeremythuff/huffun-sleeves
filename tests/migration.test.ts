import assert from 'node:assert/strict';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';
import { checkRepository,readRepositoryFolder } from '../../../huffun-server/src/sleeve-repos/fixtures.ts';
import { parseRepoManifest,parseSleeveManifest } from '../../../huffun-server/src/sleeve-repos/manifest.ts';
import { applyEdge } from '../../../huffun-server/src/graph/edges.ts';
const folder=fileURLToPath(new URL('../',import.meta.url));
test('the migration contains every existing job as executable, fixture-tested repository sleeves',async()=>{
 const files=await readRepositoryFolder(folder);const repo=parseRepoManifest(JSON.parse(files.get('huffun-sleeves.json')!));
 assert.deepEqual(repo.sleeves.map(x=>x.id).sort(),['steamless','steamworks-windows','steamworks-macos','wine','scummvm','fallout-ce','fallout2-ce','gog-inno','gog-pkg','retroarch-snes9x','retroarch-snes9x-windows'].sort());
 for(const index of repo.sleeves){const s=parseSleeveManifest(JSON.parse(files.get(index.folder+'/sleeve.json')!),repo,index,files);assert(s.execution);assert(s.execution.fixtures.length>=2);assert(s.pins.every(p=>p.source==='fetch' && p.archiveSha256 && p.url?.startsWith('https://')));}
 const report=await checkRepository(files);assert.equal(report.ok,true,JSON.stringify(report,null,2));
});
test('emulation consumes its requirement without leaving an unsatisfied informational fact',async()=>{
 const files=await readRepositoryFolder(folder);const repo=parseRepoManifest(JSON.parse(files.get('huffun-sleeves.json')!));
 const index=repo.sleeves.find(x=>x.id==='steamworks-windows')!;assert(index);
 const s=parseSleeveManifest(JSON.parse(files.get(index.folder+'/sleeve.json')!),repo,index,files);
 assert.deepEqual(applyEdge({os:['windows'],arch:['x86_64'],'huffun-sleeves:steamworks':['required']},s.edge),{os:['windows'],arch:['x86_64']});
});
test('a Windows PC runs DirectDraw programs and a Windows release\'s own Fallout engine as archived',async()=>{
 const files=await readRepositoryFolder(folder);const repo=parseRepoManifest(JSON.parse(files.get('huffun-sleeves.json')!));
 const { memberCapabilities }=await import('../../../huffun-server/src/graph/platform.ts');
 const { searchPaths }=await import('../../../huffun-server/src/graph/search.ts');
 const state={os:['windows'],arch:['x86'],'huffun-sleeves:graphics':['directdraw'],'huffun-sleeves:engine':['fallout']};
 const model={clientFacts:repo.clients};
 assert(searchPaths(state,memberCapabilities('windows',{chip:'x86_64'},model),[]).some(p=>p.sleeves.length===0));
 assert.equal(searchPaths(state,memberCapabilities('macos',{chip:'arm64',rosetta:true},model),[]).length,0,'a Mac still needs sleeves');
});
