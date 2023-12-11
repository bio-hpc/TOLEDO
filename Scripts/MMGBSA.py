import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import sys 

df = pd.read_csv(sys.argv[1], delimiter=',')

df = df.drop(columns=['title'])
cols_to_drop = df.columns[(df == 0).all()]
df = df.drop(columns=cols_to_drop)

df = df[['r_psp_MMGBSA_dG_Bind', 'r_psp_MMGBSA_dG_Bind_Coulomb', 'r_psp_MMGBSA_dG_Bind_vdW']]

df = df.reset_index(drop=True)
x_original = np.linspace(0, int(sys.argv[2]), df.shape[0])
x_new = np.linspace(0, int(sys.argv[2]), int(sys.argv[2]))
df_interpolated = pd.DataFrame()
for col in df.columns:
    df_interpolated[col] = np.interp(x_new, x_original, df[col])

plt.figure(figsize=(15, 10))
for col in df_interpolated.columns:
    plt.plot(x_new, df_interpolated[col], marker='', linestyle='-', label=col)

plt.title("MMGBSA Analysis")
plt.xlabel("time (ns)")
plt.ylabel("Energy (kcal/mol)")
plt.legend()
plt.grid(False)
plt.tight_layout()

plt.legend(loc='upper center', bbox_to_anchor=(0.85, 0.95), fancybox=True, shadow=True, ncol=1)

plt.savefig(sys.argv[3], dpi=300)
