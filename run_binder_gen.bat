@echo off
cd /d C:\Users\christava\Documents\src\github.com\ctava-msft\customers-top\mayo-top\d3-boltz\BoltzDesign1
..\boltz_venv\Scripts\python.exe boltzdesign.py --target_name af3_tleap --input_type pdb --pdb_path ..\_inputs\af3_tleap.pdb --target_type protein --design_samples 2 --length_min 100 --length_max 150
