#!/usr/bin/env python3
"""
BoltzDesign1 Binder Generation Script
Generates protein binders for the target structure in af3_tleap.pdb
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path
import shutil


def check_environment():
    """Check if we're running in the correct virtual environment"""
    try:
        import torch
        import yaml
        from boltz.main import download
        print("✅ Environment check passed - all required packages available")
        return True
    except ImportError as e:
        print(f"❌ Environment check failed: {e}")
        print("\nPlease activate the virtual environment first:")
        print("  Windows: .\\boltz_venv\\Scripts\\Activate.ps1")
        print("  Linux/Mac: source boltz_venv/bin/activate")
        return False


def find_boltzdesign_script():
    """Find the boltzdesign.py script"""
    script_dir = Path(__file__).parent.resolve()
    
    # Check in BoltzDesign1 repo
    boltz_repo = script_dir / "BoltzDesign1"
    boltzdesign_script = boltz_repo / "boltzdesign.py"
    
    if boltzdesign_script.exists():
        return boltzdesign_script
    
    # Check if we need to clone the repo
    print(f"❌ Could not find boltzdesign.py at {boltzdesign_script}")
    print("Please run setup_environment.py first to clone the BoltzDesign1 repository")
    return None


def run_binder_generation(
    pdb_path,
    target_type="protein",
    pdb_target_ids="A",
    gpu_id=0,
    design_samples=2,
    suffix="boltz1",
    use_msa=True,
    output_dir=None,
    additional_args=None
):
    """
    Run the BoltzDesign1 binder generation pipeline
    
    Args:
        pdb_path: Path to the input PDB file
        target_type: Type of target (protein, dna, rna, small_molecule)
        pdb_target_ids: Comma-separated chain IDs for target
        gpu_id: GPU device ID to use
        design_samples: Number of binder designs to generate
        suffix: Suffix for output directory naming
        use_msa: Whether to use MSA for the target protein
        output_dir: Custom output directory (optional)
        additional_args: List of additional command-line arguments
    """
    
    pdb_path = Path(pdb_path).resolve()
    if not pdb_path.exists():
        print(f"❌ Error: PDB file not found at {pdb_path}")
        return False
    
    print(f"\n{'='*60}")
    print("🧬 BoltzDesign1 Binder Generation")
    print(f"{'='*60}")
    print(f"📁 Input PDB: {pdb_path}")
    print(f"🎯 Target Type: {target_type}")
    print(f"🔗 Target Chains: {pdb_target_ids}")
    print(f"💻 GPU ID: {gpu_id}")
    print(f"🔬 Design Samples: {design_samples}")
    print(f"{'='*60}\n")
    
    # Find the boltzdesign.py script
    script_dir = Path(__file__).parent.resolve()
    boltzdesign_script = find_boltzdesign_script()
    
    if not boltzdesign_script:
        return False
    
    # Change to the BoltzDesign1 directory for execution
    boltz_repo = boltzdesign_script.parent
    original_dir = Path.cwd()
    os.chdir(boltz_repo)
    
    try:
        # Build the command
        target_name = pdb_path.stem  # Use filename without extension as target name
        
        cmd = [
            sys.executable,
            str(boltzdesign_script),
            "--target_name", target_name,
            "--pdb_path", str(pdb_path),
            "--target_type", target_type,
            "--pdb_target_ids", pdb_target_ids,
            "--gpu_id", str(gpu_id),
            "--design_samples", str(design_samples),
            "--suffix", suffix,
            "--use_msa", str(use_msa),
        ]
        
        # Add custom output directory if specified
        if output_dir:
            output_dir = Path(output_dir).resolve()
            output_dir.mkdir(parents=True, exist_ok=True)
            cmd.extend(["--work_dir", str(output_dir)])
        
        # Add any additional arguments
        if additional_args:
            cmd.extend(additional_args)
        
        print("🚀 Running BoltzDesign1 pipeline...")
        print(f"Command: {' '.join(cmd)}\n")
        
        # Run the command
        result = subprocess.run(
            cmd,
            check=True,
            text=True,
            capture_output=False  # Show output in real-time
        )
        
        print(f"\n{'='*60}")
        print("✅ Binder generation completed successfully!")
        print(f"{'='*60}")
        
        # Print information about output location
        if output_dir:
            outputs_dir = output_dir / "outputs"
        else:
            outputs_dir = boltz_repo / "outputs"
        
        print(f"\n📦 Results location:")
        print(f"   {outputs_dir}")
        
        expected_result_dir = outputs_dir / f"{target_type}_{target_name}_{suffix}"
        if expected_result_dir.exists():
            print(f"\n📁 Design output directory:")
            print(f"   {expected_result_dir}")
            
            # Look for successful designs
            ligandmpnn_dir = list(expected_result_dir.glob("ligandmpnn_cutoff_*"))
            if ligandmpnn_dir:
                success_dir = ligandmpnn_dir[0] / "03_af_pdb_success"
                if success_dir.exists():
                    print(f"\n🎉 High-confidence designs found in:")
                    print(f"   {success_dir}")
        
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"\n❌ Error: Binder generation failed with exit code {e.returncode}")
        return False
    except Exception as e:
        print(f"\n❌ Error: {e}")
        return False
    finally:
        os.chdir(original_dir)


def main():
    """Main function with command-line interface"""
    parser = argparse.ArgumentParser(
        description="Generate protein binders using BoltzDesign1",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic usage with default settings
  python run_binder_generation.py

  # Specify custom PDB and target chains
  python run_binder_generation.py --pdb custom_protein.pdb --target_chains A,B

  # Generate more designs
  python run_binder_generation.py --design_samples 5

  # Design binder for DNA target
  python run_binder_generation.py --target_type dna --target_chains C,D

  # Disable AlphaFold3 validation (faster)
  python run_binder_generation.py --no-alphafold

  # Advanced: specify contact residues for binding site
  python run_binder_generation.py --contact_residues "100,101,105" --constraint_target A
        """
    )
    
    # Check environment first
    if not check_environment():
        sys.exit(1)
    
    # Input file arguments
    parser.add_argument(
        "--pdb",
        type=str,
        default="_inputs/af3_tleap.pdb",
        help="Path to input PDB file (default: _inputs/af3_tleap.pdb)"
    )
    
    # Target configuration
    parser.add_argument(
        "--target_type",
        type=str,
        choices=["protein", "dna", "rna", "small_molecule", "metal"],
        default="protein",
        help="Type of target molecule (default: protein)"
    )
    
    parser.add_argument(
        "--target_chains",
        type=str,
        default="A",
        help="Comma-separated chain IDs for target (default: A)"
    )
    
    # Design parameters
    parser.add_argument(
        "--design_samples",
        type=int,
        default=2,
        help="Number of binder designs to generate (default: 2)"
    )
    
    parser.add_argument(
        "--gpu_id",
        type=int,
        default=0,
        help="GPU device ID to use (default: 0)"
    )
    
    parser.add_argument(
        "--suffix",
        type=str,
        default="boltz1",
        help="Suffix for output directory naming (default: boltz1)"
    )
    
    parser.add_argument(
        "--no-msa",
        action="store_true",
        help="Disable MSA generation for target protein"
    )
    
    parser.add_argument(
        "--output_dir",
        type=str,
        default=None,
        help="Custom output directory (default: BoltzDesign1/outputs)"
    )
    
    # Advanced options
    parser.add_argument(
        "--contact_residues",
        type=str,
        default="",
        help="Contact residues for binding constraints (comma-separated, e.g., '100,101,105')"
    )
    
    parser.add_argument(
        "--constraint_target",
        type=str,
        default="",
        help="Target chain ID for constraints (e.g., 'A')"
    )
    
    parser.add_argument(
        "--length_min",
        type=int,
        default=100,
        help="Minimum binder length (default: 100)"
    )
    
    parser.add_argument(
        "--length_max",
        type=int,
        default=150,
        help="Maximum binder length (default: 150)"
    )
    
    parser.add_argument(
        "--no-alphafold",
        action="store_true",
        help="Disable AlphaFold3 cross-validation (faster)"
    )
    
    parser.add_argument(
        "--no-ligandmpnn",
        action="store_true",
        help="Disable LigandMPNN redesign step"
    )
    
    args = parser.parse_args()
    
    # Build additional arguments for boltzdesign.py
    additional_args = []
    
    if args.contact_residues:
        additional_args.extend(["--contact_residues", args.contact_residues])
    
    if args.constraint_target:
        additional_args.extend(["--constraint_target", args.constraint_target])
    
    additional_args.extend(["--length_min", str(args.length_min)])
    additional_args.extend(["--length_max", str(args.length_max)])
    
    if args.no_alphafold:
        additional_args.extend(["--run_alphafold", "False"])
    
    if args.no_ligandmpnn:
        additional_args.extend(["--run_ligandmpnn", "False"])
    
    # Run the binder generation
    success = run_binder_generation(
        pdb_path=args.pdb,
        target_type=args.target_type,
        pdb_target_ids=args.target_chains,
        gpu_id=args.gpu_id,
        design_samples=args.design_samples,
        suffix=args.suffix,
        use_msa=not args.no_msa,
        output_dir=args.output_dir,
        additional_args=additional_args
    )
    
    if not success:
        sys.exit(1)


if __name__ == "__main__":
    main()
