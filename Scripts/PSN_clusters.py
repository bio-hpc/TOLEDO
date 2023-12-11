import pandas as pd
import sys
import pandas as pd

class UnionFind:
    def __init__(self):
        self.parent = {}
        self.rank = {}

    def make_set(self, x):
        self.parent[x] = x
        self.rank[x] = 0

    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x, y):
        root_x = self.find(x)
        root_y = self.find(y)

        if root_x == root_y:
            return

        if self.rank[root_x] > self.rank[root_y]:
            self.parent[root_y] = root_x
        else:
            self.parent[root_x] = root_y
            if self.rank[root_x] == self.rank[root_y]:
                self.rank[root_y] += 1

def process_csv(input_path, output_path):
    data = pd.read_csv(input_path, delimiter=',', header=0, index_col=0)

    uf = UnionFind()

    for row_label, row_data in data.iterrows():
        for col_label, value in row_data.iteritems():
            try:
                value_float = float(value)
                if value_float >= 0.5:
                    if row_label not in uf.parent:
                        uf.make_set(row_label)
                    if col_label not in uf.parent:
                        uf.make_set(col_label)
                    uf.union(row_label, col_label)
            except ValueError:
                pass

    classes = {}
    for item in uf.parent.keys():
        root = uf.find(item)
        if root not in classes:
            classes[root] = []
        classes[root].append(item)

    sorted_classes = sorted(classes.values(), key=len, reverse=True)
    formatted_output = "\n".join([f"{idx+1}: {','.join(group)}" for idx, group in enumerate(sorted_classes)])

    with open(output_path, 'w') as f:
        f.write(formatted_output)

if __name__ == "__main__":
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    process_csv(input_path, output_path)

