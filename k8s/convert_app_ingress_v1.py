import os
import yaml

def convert_ingress_v1(file_path):
    changed = False
    with open(file_path, 'r') as f:
        docs = list(yaml.safe_load_all(f))

    for doc in docs:
        if not isinstance(doc, dict):
            continue
        if doc.get("kind") != "Ingress":
            continue
        spec = doc.get("spec", {})
        rules = spec.get("rules", [])
        for rule in rules:
            http = rule.get("http", {})
            paths = http.get("paths", [])
            for path in paths:
                backend = path.get("backend", {})
                # Convert serviceName/servicePort → service.name/service.port.number
                if "serviceName" in backend and "servicePort" in backend:
                    service_name = backend.pop("serviceName")
                    service_port = backend.pop("servicePort")
                    backend["service"] = {
                        "name": service_name,
                        "port": {
                            "number": service_port
                        }
                    }
                    path["backend"] = backend
                    changed = True
                # Add pathType if missing
                if "pathType" not in path:
                    path["pathType"] = "Prefix"
                    changed = True

    if changed:
        backup_path = file_path + ".bak"
        os.rename(file_path, backup_path)
        with open(file_path, 'w') as f:
            yaml.dump_all(docs, f, sort_keys=False)
        print(f"✅ Converted: {file_path} (backup saved as *.bak)")
    else:
        print(f"⏩ Skipped (no changes): {file_path}")

def scan_and_convert(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith((".yaml", ".yml")):
                path = os.path.join(root, file)
                convert_ingress_v1(path)

if __name__ == "__main__":
    target_dir = "applications"  # 수정 가능
    scan_and_convert(target_dir)