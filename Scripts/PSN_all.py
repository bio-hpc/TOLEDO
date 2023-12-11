import pandas as pd
import sys
def process_csv(input_path, output_path):
    # Leer el archivo CSV usando '/t' como delimitador
    data = pd.read_csv(input_path, delimiter=',', header=0, index_col=0)
    
    # Conjunto para almacenar las combinaciones ya vistas y evitar duplicados
    seen_combinations = set()
    
    # Lista para almacenar los resultados sin duplicados
    results = []

    # Iterar sobre cada fila y columna
    for row_label, row_data in data.iterrows():
        for col_label, value in row_data.iteritems():
            try:
                value_float = float(value)
                if value_float >= 0.5:
                    # Crear un conjunto para la combinación actual y su inversa
                    current_combination = frozenset([row_label, col_label])
                    if current_combination not in seen_combinations:
                        seen_combinations.add(current_combination)
                        results.append((f"{row_label}, {col_label}", value_float))
            except ValueError:  # Si no puede convertirse a float, simplemente continuar
                pass

    # Ordenar los resultados de mayor a menor según el valor
    sorted_results = sorted(results, key=lambda x: x[1], reverse=True)
    
    # Escribir los resultados ordenados en un archivo TXT
    with open(output_path, 'w') as f:
        for line, value in sorted_results:
            f.write(f"{line}: {value:.2f}\n")
            
if __name__ == "__main__":
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    process_csv(input_path, output_path)

