import matplotlib.pyplot as plt
import numpy as np
import re
import sys

path=sys.argv[1]
time=int(sys.argv[2])
def graphs_Maestro(path,time):
    fig, (ax1,ax2,ax3) = plt.subplots(3, 1)
    fig.subplots_adjust(hspace=0.75)

    archivo=open(path+"/PL_RMSD.dat","r")
    datos=[]
    for linea in archivo:
        linea=linea.strip()
        lista=re.sub('\s+',' ',linea).split(" ")
        datos.append(lista)
        
    datos=datos[1:]
    datos=np.array(datos)
    ligando=datos[:,3]
    ligando=ligando.astype(np.float)
    proteina=datos[:,4]
    proteina=proteina.astype(np.float)

    #Crear matriz con todo
    tiempo=list(range(0,len(proteina),1)) # automatizar
    ns= [x / (len(proteina)/time) for x in tiempo] #automatizar
    leyenda=["Ligand","Protein"];print(tiempo)
    ax1.plot(ns, ligando,color="green",linewidth=0.75);ax1.plot(ns, proteina,color="maroon",linewidth=0.75)
    #limite maximo automatizarlo
    maximo1=max(ligando);maximo2=max(proteina);maximo=int((max(maximo1,maximo2)/4)+1)*4
    ax1.set_xlim(0, time)
    ax1.set_xlabel('time (ns)')
    ax1.set_title("  a)", loc='left',fontsize=8)
    ax1.spines['top'].set_visible(False)
    ax1.set_ylabel('RMSD (Å)')
    ax1.set_yticks([maximo/4,maximo/2,maximo*0.75,maximo])
    ax1.legend(leyenda,loc='lower right',fontsize=7)
    ax1.grid(False)

    archivo=open(path+"/P_RMSF.dat","r")
    datos=[]
    for linea in archivo:
        linea=linea.strip()
        lista=re.sub('\s+',' ',linea).split(" ")
        datos.append(lista)
    datos=datos[1:]
    datos=np.array(datos)
    proteina=datos[:,5]
    proteina=proteina.astype(np.float)
    atomos=list(range(1,len(proteina)+1,1))
    maximo=int((max(proteina)/2)+1)*2
    ax2.plot(atomos, proteina,color="red")
    ax2.set_xlim(1, len(proteina))
    ax2.set_xlabel('no Residue of Protein')
    ax2.set_ylabel('RMSF (Å)')
    ax2.set_title("  b)", loc='left',fontsize=8)
    ax2.spines['top'].set_visible(False)
    ax2.set_yticks([maximo/2,maximo])
    ax2.grid(False)

    archivo=open(path+"/L_RMSF.dat","r")
    datos=[]
    for linea in archivo:
        linea=linea.strip()
        lista=re.sub('\s+',' ',linea).split(" ")
        datos.append(lista)
    datos=datos[1:]
    datos=np.array(datos)
    ligando=datos[:,2]
    ligando=ligando.astype(np.float)

    atomos=list(range(1,len(ligando)+1,1))

    maximo=int((max(ligando)/2)+1)*2
    ax3.plot(atomos, ligando,color="blue")
    ax3.set_xlim(0, len(ligando))
    ax3.set_xlabel('no Atom Index')
    ax3.set_ylabel('RMSF (Å)')
    ax3.set_title("  c)", loc='left',fontsize=8)
    ax3.spines['top'].set_visible(False)
    ax3.set_yticks([maximo/2,maximo])
    ax3.grid(False)
    plt.savefig(path+"/RMSD_RMSF_p38.png",bbox_inches='tight')

graphs_Maestro(path,time)

