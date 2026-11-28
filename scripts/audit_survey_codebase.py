import os, glob, re, json

def inspect_backend():
    print("=== 1. BACKEND INSPECTION ===")
    csproj_files = glob.glob("ProGroup_AI_Backend/**/*.csproj", recursive=True)
    print("Csproj files:", csproj_files)
    for csproj in csproj_files:
        with open(csproj, "r", encoding="utf-8") as f:
            content = f.read()
            tf = re.findall(r'<TargetFramework>(.*?)</TargetFramework>', content)
            pkgs = re.findall(r'<PackageReference\s+Include="(.*?)"\s+Version="(.*?)"', content)
            print(f"File {csproj}: TargetFramework = {tf}")
            print(f"Packages ({len(pkgs)}):")
            for p, v in pkgs:
                print(f"  - {p}: {v}")

    controllers = glob.glob("ProGroup_AI_Backend/**/Controllers/*.cs", recursive=True)
    print(f"\nControllers ({len(controllers)}):")
    for c in controllers:
        print(f"  - {os.path.basename(c)}")

    models = glob.glob("ProGroup_AI_Backend/**/Models/*.cs", recursive=True)
    print(f"\nModels/Entities ({len(models)}):")
    for m in models:
        print(f"  - {os.path.basename(m)}")

    services = glob.glob("ProGroup_AI_Backend/**/Services/*.cs", recursive=True)
    print(f"\nServices ({len(services)}):")
    for s in services:
        print(f"  - {os.path.basename(s)}")

    # Check DbContext
    db_ctx = glob.glob("ProGroup_AI_Backend/**/*DbContext*.cs", recursive=True)
    print(f"\nDbContext files: {db_ctx}")
    if db_ctx:
        with open(db_ctx[0], "r", encoding="utf-8") as f:
            ctx_content = f.read()
            dbsets = re.findall(r'DbSet<(\w+)>\s+(\w+)', ctx_content)
            print(f"DbSets in DbContext ({len(dbsets)}):")
            for model_name, set_name in dbsets:
                print(f"  - DbSet<{model_name}> {set_name}")

def inspect_frontend():
    print("\n=== 2. FRONTEND INSPECTION ===")
    pubspec = "ProGroup_AI_Frontend/progroup_ai_frontend/pubspec.yaml"
    if os.path.exists(pubspec):
        with open(pubspec, "r", encoding="utf-8") as f:
            content = f.read()
            sdk = re.findall(r'sdk:\s*["\']?(.*?)["\']?\s*$', content, re.MULTILINE)
            flutter_ver = re.findall(r'flutter:\s*["\']?(.*?)["\']?\s*$', content, re.MULTILINE)
            print(f"Pubspec SDK: {sdk}, flutter: {flutter_ver}")
            # Dependencies
            deps = re.findall(r'^\s\s([a-zA-Z0-9_]+):\s*(.*)$', content, re.MULTILINE)
            print(f"Dependencies ({len(deps)}):")
            for d, v in deps[:30]:
                print(f"  - {d}: {v.strip()}")
            if len(deps) > 30:
                print(f"  ... and {len(deps)-30} more")

    # Screens
    screens = glob.glob("ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens/**/*.dart", recursive=True)
    print(f"\nTotal Screens ({len(screens)}):")
    modules = {}
    for sc in screens:
        rel = os.path.relpath(sc, "ProGroup_AI_Frontend/progroup_ai_frontend/lib/screens")
        parts = rel.split(os.sep)
        mod = parts[0] if len(parts) > 1 else "root"
        modules.setdefault(mod, []).append(os.path.basename(sc))
    for mod, sc_list in modules.items():
        print(f"  Module '{mod}' ({len(sc_list)} screens): {', '.join(sc_list[:5])}{'...' if len(sc_list) > 5 else ''}")

    # Services
    fe_services = glob.glob("ProGroup_AI_Frontend/progroup_ai_frontend/lib/services/**/*.dart", recursive=True)
    print(f"\nFrontend Services ({len(fe_services)}):")
    for s in fe_services:
        print(f"  - {os.path.basename(s)}")

def inspect_database():
    print("\n=== 3. DATABASE INSPECTION ===")
    # Look for sql files, migrations
    sql_files = glob.glob("**/*.sql", recursive=True)
    print(f"SQL files found: {sql_files}")
    migrations = glob.glob("ProGroup_AI_Backend/**/Migrations/*.cs", recursive=True)
    print(f"Migrations ({len(migrations)}):")
    for m in migrations[:10]:
        print(f"  - {os.path.basename(m)}")

if __name__ == "__main__":
    inspect_backend()
    inspect_frontend()
    inspect_database()
