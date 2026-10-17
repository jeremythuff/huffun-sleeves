"""Copy text sources into the application's ignored, container-visible area."""
from pathlib import Path
import shutil,sys
repo=Path(__file__).resolve().parents[1]
target=Path(sys.argv[1]).resolve()/'.scratch'/'sleeves-p35'
if target.exists(): shutil.rmtree(target)
shutil.copytree(repo,target,ignore=shutil.ignore_patterns('.git','.scratch','__pycache__'))
