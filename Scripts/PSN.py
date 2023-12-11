import sys
import os,glob,re
import pandas as pd

lista1=[]
for file in glob.glob("*/*",recursive=True):
    if file[-10:]=="_comms.pml":
        lista1.append(file)
for file in lista1:
    diccionario={};c=0
    texto=""
    for linea in open(file):
        linea=linea.rstrip()
        if re.match("# node:",linea):
            c=1
            aa=linea.split(":")[-1]
        if c==1 and re.match("color",linea) :
            color=linea.split(" ")[1].split("_")[-1][:-1]
            if color in diccionario:
                lista=diccionario[color]
            else:
                lista=[]
            lista.append(aa)
            diccionario[color]=lista
            c=0
    diccionario1={}
    for grupo in diccionario.keys():
        diccionario_temp={}
        lista=diccionario[grupo]
        for residuo in lista:
            numero=int(residuo[1:])
            diccionario_temp[numero]=residuo
        orden=(sorted(diccionario_temp))
        lista=[]
        for residuo in orden:
            lista.append(diccionario_temp[residuo])
        diccionario1[grupo]=lista
    for grupo in diccionario1.keys():
        texto=texto+str(grupo)+":"
        for residuo in diccionario1[grupo]:
            texto=texto+str(residuo)+","
        texto=texto[:-1]+"\n"
        nombre_archivo="./"+str(file[:-10])+"_nodes.txt"
    archivo=open(nombre_archivo,"w+")
    archivo.write(texto[:-1])
    archivo.close()
lista=[];pdb=[]
for file in glob.glob("*/*",recursive=True):
    if file[-9:]=="nodes.txt":
        lista.append(file)
    elif file[-8:] == "_PDB.pdb" and len(pdb)==0:
        pdb.append(file)
residues=[]
dict_residues={"ALA":"A","ARG":"R","ASN":"N","ASP":"D","CYS":"C",
                "GLN":"Q","GLU":"E","GLY":"G","HIS":"H","ILE":"I",
                "LEU":"L","LYS":"K","MET":"M","PHE":"F","PRO":"P",
                 "SER":"S","THR":"T","TRP":"W","TYR":"Y","VAL":"V",
                 "CYX":"C"}
pdb_a=pdb[0]
for linea in open(pdb_a):
    linea1=re.sub(' +', ' ',linea).strip()
    linea1=linea1.split(" ")
    if len(linea1)==13:
        aa=(dict_residues[linea1[3]])+str(linea1[5])
        if aa not in residues:
            residues.append(aa)

df = pd.DataFrame(index=residues, columns=residues)
df = df.fillna(0)  
frames=len(lista)*2
for file in lista:
    for linea in open(file):
        if len(linea)>1:
            residuos=linea.rstrip().split(":")[1].split(",")
            l1=[]
            for aa in residuos:
               for aa1 in residuos:
                    if aa1 != aa:
                        df.loc[aa, aa1]+=float(1/frames)
                        df.loc[aa1, aa]+=float(1/frames)  
                    
df.to_csv(sys.argv[1])
