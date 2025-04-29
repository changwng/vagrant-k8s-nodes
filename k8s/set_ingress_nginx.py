import os
import yaml

def update_ingress_class(filepath):
    with open(filepath, 'r') as f:
        docs = list(yaml.safe_load_all(f))

    changed = False
    for doc in docs:
        if not isinstance(doc, dict):
            continue
        if doc.get("kind") != "Ingress":
            continue

        spec = doc.setdefault("spec", {})
        if spec.get("ingressClassName") != "nginx":
            spec["ingressClassName"] = "nginx"
            changed = True

    if changed:
        with open(filepath, 'w') as f:
            yaml.dump_all(docs, f, sort_keys=False)
        print(f"✅ Updated: {filepath}")
    else:
        print(f"⏩ Skipped: {filepath}")

def scan_directory(root):
    for dirpath, _, filenames in os.walk(root):
        for filename in filenames:
            if filename.endswith(".yaml") or filename.endswith(".yml"):
                filepath = os.path.join(dirpath, filename)
                update_ingress_class(filepath)

if __name__ == "__main__":
   # scan_directory("applications")
    scan_directory("environments")