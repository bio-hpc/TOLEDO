import re,sys
protein=open(sys.argv[1])
charge=0
c1=0;i=0
for linea in protein:
    if re.search("@<TRIPOS>ATOM",linea):
        c1=1
    elif re.search("@<TRIPOS>BOND",linea):
        c1=0
    elif c1==1 and len(linea)>1:
        linea1=re.sub(' +', ' ',linea).strip()
        charges=linea1.split(" ")[8]
        charge=charge+float(charges)
ligando=open(sys.argv[2])
c1=0;i=0
for linea in ligando:
    if re.search("@<TRIPOS>ATOM",linea):
        c1=1
    elif re.search("@<TRIPOS>BOND",linea):
        c1=0
    elif c1==1 and len(linea)>1:
        linea1=re.sub(' +', ' ',linea).strip()
        charges=linea1.split(" ")[8]
        charge=charge+float(charges)
if (charge>0):
    print("Positive")
elif (charge<0):
    print("Negative")
else:
    print("Neutral")




