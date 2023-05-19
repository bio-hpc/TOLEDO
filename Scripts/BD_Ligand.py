from asyncore import write
import re,sys
numero=int(sys.argv[2]);texto="";nuevo=open("Complex_Lig.mol2","w+")
for i in range(0,numero):
    i1=str(i+1)+" UNK"
    original=open(str(sys.argv[1])+str(i+1)+".mol2")
    posicion=[];c1=0
    for linea in original:
        if re.search("@<TRIPOS>ATOM",linea):
            c1=1
            texto+=linea
        elif re.search("@<TRIPOS>BOND",linea):
            c1=0
            texto+=linea
        elif c1==1:
            lineam=linea.replace("1 UNK",i1)
            texto+=lineam
        else:
            texto+=linea
nuevo.write(texto)
nuevo.close()
