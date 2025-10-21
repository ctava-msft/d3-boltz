
import sys
sys.path.insert(0, r'C:\Users\christava\Documents\src\github.com\ctava-msft\customers-top\mayo-top\d3-boltz\BoltzDesign1\boltz')
from boltz.main import download
from pathlib import Path

cache = Path.home() / '.boltz'
cache.mkdir(parents=True, exist_ok=True)
download(cache)
print('Boltz weights downloaded successfully!')
