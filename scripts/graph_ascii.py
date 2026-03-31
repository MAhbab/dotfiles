import sys
from collections import defaultdict

edges = [line.strip() for line in sys.stdin if "->" in line]

children = defaultdict(set)
parents = defaultdict(set)
nodes = set()

for line in edges:
    a, b = [x.strip() for x in line.split("->")]
    children[a].add(b)
    parents[b].add(a)
    nodes.add(a)
    nodes.add(b)

# --- pick center node ---
def pick_center():
    best = None
    best_score = -1
    for n in nodes:
        score = len(children[n]) + len(parents[n])
        if score > best_score:
            best = n
            best_score = score
    return best

center = pick_center()

# --- collect layers ---
def collect(layer_fn, start):
    seen = set()
    frontier = {start}
    layers = []

    while frontier:
        next_frontier = set()
        layer = set()

        for node in frontier:
            for nxt in layer_fn[node]:
                if nxt not in seen:
                    layer.add(nxt)
                    next_frontier.add(nxt)

        if layer:
            layers.append(sorted(layer))
        seen |= layer
        frontier = next_frontier

    return layers

parent_layers = collect(parents, center)[::-1]
child_layers = collect(children, center)

columns = parent_layers + [[center]] + child_layers

# --- layout prep ---
widths = [max(len(x) for x in col) if col else 0 for col in columns]
height = max(len(col) for col in columns)

# pad columns
for i in range(len(columns)):
    columns[i] = columns[i] + [""] * (height - len(columns[i]))

# normalize width
for i in range(len(columns)):
    columns[i] = [x.ljust(widths[i]) for x in columns[i]]

# --- build lookup for positions ---
positions = {}  # node -> (col, row)

for c_idx, col in enumerate(columns):
    for r_idx, node in enumerate(col):
        if node:
            positions[node.strip()] = (c_idx, r_idx)

# --- render ---
output = [[" " for _ in range(sum(widths) + 3 * (len(columns)-1))]
          for _ in range(height)]

# place nodes
col_offsets = []
offset = 0
for w in widths:
    col_offsets.append(offset)
    offset += w + 3

for node, (c, r) in positions.items():
    start = col_offsets[c]
    for i, ch in enumerate(node):
        output[r][start + i] = ch

# draw edges
for line in edges:
    a, b = [x.strip() for x in line.split("->")]

    if a not in positions or b not in positions:
        continue

    c1, r1 = positions[a]
    c2, r2 = positions[b]

    if c2 != c1 + 1:
        continue  # only draw between adjacent columns

    x1 = col_offsets[c1] + len(a)
    x2 = col_offsets[c2] - 1

    y = r1

    # horizontal line
    for x in range(x1, x2):
        output[y][x] = "─"

    # vertical adjustment if needed
    if r2 != r1:
        step = 1 if r2 > r1 else -1
        for y2 in range(r1, r2, step):
            output[y2][x2] = "│"

    output[r2][x2] = "►"

# print
for row in output:
    print("".join(row).rstrip())
