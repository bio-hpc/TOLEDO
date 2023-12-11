## TOLEDO: a tool that allows to run and analyze Desmond Molecular Dynamics simulations with higher throughput than Maestro GUI

TOLEDO is a tool that allows run multiple Maestro-Desmond MDs at the same time using one single command line.

### Installation (choose one)
1. git clone https://github.com/bio-hpc/TOLEDO.git
2. git clone git@github.com:bio-hpc/TOLEDO.git
3. Download the .zip and unzip it in the supercomputing centers you are going to use

### Dependencies 
Mandatory:
Python3.10
Maestro-Desmond installation


### Download Singularity Image
Needed to secure compatibility with the HPC cluster.
wget --no-check-certificate -r "https://drive.google.com/u/1/uc?export=download&confirm=TLUF&id=1AzDw0DmtX9MBv-lNPaj1-LZ-90GEj9tX" -O singularity.tar
tar xf singularity.tar

### Configuration
Modify the following scripts: Toledo_AN_1.sh, Toledo_AN_M.sh, Toledo_AN_ES.sh, Toledo_AN_Main.sh and Toledo_AN_UN.sh.
In all these scripts change the line:
export SCHRODINGER="/opt/schrodinger/2020-04/" to your $SCHRODINGER path

### Examples:
**Example to run VS:
1. Without modifications or membrane:
./TOLEDO.sh -f example1.txt -t 1000000 -d MD_1/ -p accel  -m N -G --gres=gpu:1

2. Without modifications and with membrane (or complex build by user):
./TOLEDO.sh -f example2.txt -t 1000000 -d MD_1/ -p accel -m Y -G --gres=gpu:1 

3. With WB modifications and without membrane:
./TOLEDO.sh -f example3.txt -t 1000000 -d MD_1/ -p accel -m N -G --gres=gpu:1 

4. With MD modifications and without membrane:
./TOLEDO.sh -f example4.txt -t 1000000 -d MD_1/ -p accel -m N -G --gres=gpu:1 

5. With WB and MD modifications and without membrane:
./TOLEDO.sh -f example5.txt -t 1000000 -d MD_1/ -p accel -m N -G --gres=gpu:1 

6. With MD modifications and with membrane (or complex build by user):
./TOLEDO.sh -f example6.txt  -m N -t 1000000 -d MD_1/ -p accel -G --gres=gpu:1


### Script to generate BD
**Uses to generate the Complex_Lig.mol2 (mol2 with all ligands in their coordinates but without protein) to use in examples without Membrane (to do with Membrane the script is not useful and the complex must be generated with the GUI of Maestro).
The parameters are: first the basename of each ligand ad second the number of ligands. Finally, the user obtain a mol2 file named Complex_Lig.mol2 with all ligands.
python3.10 Scripts/BD_Ligand.py Examples/Lig_ 8



