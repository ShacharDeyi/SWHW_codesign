import json
from collections import defaultdict

def add_stack(tree, stack, value):
    if not stack:
        return
    head, *tail = stack
    if head not in tree:
        tree[head] = {"value": 0, "children": {}}
    tree[head]["value"] += value
    add_stack(tree[head]["children"], tail, value)

def parse_folded_file(filename):
    tree = {}
    with open(filename) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            stack_part, val = line.rsplit(" ", 1)
            stack = stack_part.split(";")
            value = int(val)
            add_stack(tree, stack, value)
    return tree

def tree_to_json(tree):
    def convert(node_dict, name):
        children = [convert(child, child_name) for child_name, child in node_dict["children"].items()]
        return {"name": name, "value": node_dict["value"], "children": children}
    root_children = [convert(child, child_name) for child_name, child in tree.items()]
    return {"name": "root", "children": root_children}

if __name__ == "__main__":
    folded_path = "./results/out.folded"  # replace with your folded stack file path
    tree = parse_folded_file(folded_path)
    json_data = tree_to_json(tree)
    with open("flamegraph_to_json.json", "w") as f:
        json.dump(json_data, f, indent=2)
    print("Converted folded stack to flamegraph.json")
