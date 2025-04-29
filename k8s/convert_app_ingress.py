import os
import yaml

def update_ingress_structure(doc):
    if doc.get("apiVersion") == "networking.k8s.io/v1beta1" and doc.get("kind") == "Ingress":
        doc["apiVersion"] = "networking.k8s.io/v1"
        spec = doc.get("spec", {})
        rules = spec.get("rules", [])

        for rule in rules:
            http = rule.get("http", {})
            paths = http.get("paths", [])
            for path in paths:
                backend = path.get("backend", {})
                if "serviceName" in backend and "servicePort" in backend:
                    path["backend"] = {
                        "service": {
                            "name": backend["serviceName"],
                            "port": {
                                "number": backend["servicePort"]
                            }
                        }
                    }
        doc["spec"] = spec
    return doc

def convert_yaml_file(file_path):
    with open(file_path, "r") as f:
        docs = list(yaml.safe_load_all(f))

    updated = False
    new_docs = []
    for doc in docs:
        if doc is not None:
            new_doc = update_ingress_structure(doc)
            if new_doc != doc:
                updated = True
            new_docs.append(new_doc)

    if updated:
        with open(file_path, "w") as f:
            yaml.dump_all(new_docs, f, sort_keys=False)
        print(f"✅ Updated: {file_path}")
    else:
        print(f"⏩ Skipped: {file_path}")

for root, dirs, files in os.walk("applications"):
    for file in files:
        if file.endswith((".yaml", ".yml")):
            convert_yaml_file(os.path.join(root, file))