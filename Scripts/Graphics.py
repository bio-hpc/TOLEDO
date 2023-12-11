import matplotlib.pyplot as plt
import numpy as np
import re
import sys

path=sys.argv[1]
time=int(sys.argv[2])
def graphs_Maestro(path,time):
    fig, (ax1,ax2,ax3) = plt.subplots(3, 1)
    fig.subplots_adjust(hspace=0.75)

    file=open(path+"/PL_RMSD.dat","r")
    data=[]
    for linea in file:
        linea=linea.strip()
        lista=re.sub('\s+',' ',linea).split(" ")
        data.append(lista)
        
    data=data[1:]
    data=np.array(data)
    ligand=data[:,3]
    ligand=ligand.astype(np.float)
    protein=data[:,4]
    protein=protein.astype(np.float)

    #Build Matrix of data
    tiempo=list(range(0,len(protein),1)) 
    ns= [x / (len(protein)/time) for x in tiempo]
    leyenda=["Ligand","Protein"];print(tiempo)
    ax1.plot(ns, ligand,color="green",linewidth=0.75);ax1.plot(ns, protein,color="maroon",linewidth=0.75)
    #Obtain maxium RMSD value
    maximum1=max(ligand);maximum2=max(protein);maximum=int((max(maximum1,maximum2)/4)+1)*4
    ax1.set_xlim(0, time)
    ax1.set_xlabel('time (ns)')
    ax1.set_title("  a)", loc='left',fontsize=8)
    ax1.spines['top'].set_visible(False)
    ax1.set_ylabel('RMSD (Å)')
    ax1.set_yticks([maximum/4,maximum/2,maximum*0.75,maximum])
    ax1.legend(leyenda,loc='lower right',fontsize=7)
    ax1.grid(False)

    file=open(path+"/P_RMSF.dat","r")
    data=[]
    for linea in file:
        linea=linea.strip()
        lista=re.sub('\s+',' ',linea).split(" ")
        data.append(lista)
    data=data[1:]
    data=np.array(data)
    protein=data[:,5]
    protein=protein.astype(np.float)
    atoms=list(range(1,len(protein)+1,1))
    maximum=int((max(protein)/2)+1)*2
    ax2.plot(atoms, protein,color="red")
    ax2.set_xlim(1, len(protein))
    ax2.set_xlabel('no Residue of Protein')
    ax2.set_ylabel('RMSF (Å)')
    ax2.set_title("  b)", loc='left',fontsize=8)
    ax2.spines['top'].set_visible(False)
    ax2.set_yticks([maximum/2,maximum])
    ax2.grid(False)

    file=open(path+"/L_RMSF.dat","r")
    data=[]
    for linea in file:
        linea=linea.strip()
        lista=re.sub('\s+',' ',linea).split(" ")
        data.append(lista)
    data=data[1:]
    data=np.array(data)
    ligand=data[:,2]
    ligand=ligand.astype(np.float)

    atoms=list(range(1,len(ligand)+1,1))

    maximum=int((max(ligand)/2)+1)*2
    ax3.plot(atoms, ligand,color="blue")
    ax3.set_xlim(0, len(ligand))
    ax3.set_xlabel('no Atom Index')
    ax3.set_ylabel('RMSF (Å)')
    ax3.set_title("  c)", loc='left',fontsize=8)
    ax3.spines['top'].set_visible(False)
    ax3.set_yticks([maximum/2,maximum])
    ax3.grid(False)
    plt.savefig(path+"/RMSD_RMSF_p38.png",bbox_inches='tight')

graphs_Maestro(path,time)

