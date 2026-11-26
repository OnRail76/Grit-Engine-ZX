#!/usr/bin/env python3
"""Unified profile launcher; upstream trees stay isolated and pinned."""
import argparse, hashlib, json, pathlib, shutil, subprocess, sys, tempfile
ROOT=pathlib.Path(__file__).resolve().parent
MANIFEST=json.loads((ROOT/'provenance/repos.json').read_text())

def run(args,cwd=None):
    print('+',' '.join(map(str,args)),flush=True)
    return subprocess.run(list(map(str,args)),cwd=cwd,check=True)

def git(cwd,*args):
    return subprocess.check_output(['git','-C',str(cwd),*args],text=True).strip()

def import_repo(name, record):
    # Clone into a temporary directory, verify pinned revision, then copy it.
    # Never reset or replace a user's existing checkout.
    dst=ROOT/'upstream'/name
    if dst.exists():
        if git(dst,'rev-parse','HEAD') != record['commit']:
            raise RuntimeError(f'{dst} is not the pinned commit; not replacing it')
        print(f'{name}: already imported at pinned commit')
        return
    dst.parent.mkdir(exist_ok=True)
    tmp=pathlib.Path(tempfile.mkdtemp(prefix='.import-',dir=dst.parent))
    try:
        run(['git','init',tmp]);run(['git','-C',tmp,'remote','add','origin',f'https://github.com/OnRail76/{name}.git'])
        run(['git','-C',tmp,'fetch','--depth=1','origin',record['commit']]);run(['git','-C',tmp,'checkout','--detach','FETCH_HEAD'])
        assert git(tmp,'rev-parse','HEAD')==record['commit']
        for p,sha in record.get('blobs',{}).items():
            assert git(tmp,'rev-parse',f'HEAD:{p}')==sha,(name,p)
        tmp.rename(dst)
    finally:
        if tmp.exists():shutil.rmtree(tmp)

def profile(name):
    if name=='vertical_bench':return ROOT/'profiles'/name,['build.py'],['test_cpu.py']
    if name=='vertical_neptuno':return ROOT/'profiles'/name,['pack.py'],['test_campaign011.py','test_audio.py']
    for repo,r in MANIFEST.items():
        if r['profile']==name:
            base=ROOT/'upstream'/repo
            if not base.exists():raise SystemExit(f'Perfil no descargado: python3 grit.py import {repo}')
            if git(base,'rev-parse','HEAD')!=r['commit']:raise SystemExit('Commit distinto al fijado; abortando')
            return base/r['cwd'],r['build'],(['test_kempston.py','test_loading.py','test_audio.py','test_audio212.py','test_render.py','test_boss20.py'] if name=='horizontal_escoria' else [])
    raise SystemExit(f'Perfil desconocido: {name}')

def main():
    p=argparse.ArgumentParser();sub=p.add_subparsers(dest='action',required=True)
    sub.add_parser('list');q=sub.add_parser('import');q.add_argument('repo',nargs='?',default='all',choices=['all',*MANIFEST]);
    for cmd in ['build','test']:
        q=sub.add_parser(cmd);q.add_argument('profile')
    sub.add_parser('verify');sub.add_parser('demo6')
    a=p.parse_args()
    if a.action=='list':
        for repo,r in MANIFEST.items():print(r['profile'],r['commit'], 'local' if r['profile']=='vertical_neptuno' or (ROOT/'upstream'/repo).is_dir() else 'import required')
        print('vertical_bench local');return
    if a.action=='import':
        for n,r in MANIFEST.items():
            if a.repo in ('all',n):import_repo(n,r)
        return
    if a.action=='demo6':
        cwd,_,_=profile('horizontal_escoria')
        run([sys.executable,ROOT/'profiles/horizontal_escoria/build_demo.py','--source',cwd],ROOT)
        return
    if a.action=='verify':
        run([sys.executable,'-m','unittest','discover','-s','tests','-v'],ROOT)
        from core.formats import read_tap
        files=list((ROOT/'profiles').rglob('*.tap'))+list((ROOT/'reference').glob('*.tap'))
        for f in files:print(f.relative_to(ROOT),len(read_tap(f.read_bytes())),hashlib.sha256(f.read_bytes()).hexdigest())
        want=MANIFEST['Neptuno-Ataca-ZX']['tap_sha256'];assert hashlib.sha256((ROOT/'profiles/vertical_neptuno/NEPTUNO_ATACA_011.tap').read_bytes()).hexdigest()==want
        assert hashlib.sha256((ROOT/'reference/NEPTUNO_ATACA_V1.0.tap').read_bytes()).hexdigest()==want
        escoria=ROOT/'upstream/Escoria-Sideral/JUEGO/ESCORIA_SIDERAL_V1.0.tap'
        if escoria.is_file():
            record=MANIFEST['Escoria-Sideral'];assert git(escoria.parents[1],'rev-parse','HEAD')==record['commit']
            assert hashlib.sha256(escoria.read_bytes()).hexdigest()==record['tap_sha256']
            assert len(read_tap(escoria.read_bytes()))==28
            print('horizontal_escoria Gold Master verified')
        else: print('horizontal_escoria: not imported; verification skipped')
        return
    cwd,build,tests=profile(a.profile)
    if a.action=='build':run([sys.executable,*build],cwd)
    else:
        if not tests:raise SystemExit('Ejecuta los tests de upstream descritos en el manual; este perfil no tiene adaptación de test aún.')
        for t in tests:run([sys.executable,t],cwd)
if __name__=='__main__':main()
