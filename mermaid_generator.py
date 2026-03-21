"""
Generador de imágenes Mermaid
Genera PNG desde archivos .md con diagramas Mermaid

Uso:
    python mermaid_generator.py

Requiere:
    pip install requests
"""

import os
import time
import re
from pathlib import Path
import requests
import json
from urllib.parse import quote

def extract_mermaid_diagrams(md_content):
    """Extrae todos los bloques mermaid de un archivo markdown"""
    pattern = r'```mermaid\s+([\s\S]*?)```'
    matches = re.findall(pattern, md_content)
    return [m.strip() for m in matches if 'sequenceDiagram' in m or 'classDiagram' in m]

def generate_mermaid_image_mermaid_ink(mermaid_code, output_path):
    """
    Genera imagen usando la API de Kroki (más robusto para código largo)
    """
    # Limpiar el código
    clean_code = mermaid_code.strip()
    
    # Método 1: Kroki.io (mejor para código largo)
    try:
        kroki_url = "https://kroki.io/mermaid/png"
        response = requests.post(
            kroki_url,
            data=json.dumps({"diagram_source": clean_code, "diagram_type": "mermaid"}),
            headers={
                'Content-Type': 'application/json',
                'Accept': 'image/png'
            },
            timeout=120
        )
        
        if response.status_code == 200:
            with open(output_path, 'wb') as f:
                f.write(response.content)
            print(f"✓ Generado (kroki): {output_path}")
            return True
    except Exception as e:
        pass
    
    # Método 2: Mermaid.ink con POST
    try:
        api_url = "https://mermaid.ink/img"
        response = requests.post(
            api_url,
            data=clean_code.encode('utf-8'),
            headers={
                'Content-Type': 'text/plain',
                'Accept': 'image/png'
            },
            timeout=120
        )
        
        if response.status_code == 200 and 'image' in response.headers.get('Content-Type', ''):
            with open(output_path, 'wb') as f:
                f.write(response.content)
            print(f"✓ Generado (ink): {output_path}")
            return True
    except Exception as e:
        pass
    
    print(f"✗ Error al generar: {output_path}")
    return False

def main():
    base_dir = Path(__file__).parent
    docs_dir = base_dir / "docs"
    secuencia_dir = docs_dir / "secuencia"
    output_dir = docs_dir / "secuencia_images"
    
    # Crear directorio de salida
    if output_dir.exists():
        import shutil
        shutil.rmtree(output_dir)
    output_dir.mkdir(exist_ok=True)
    
    print("=" * 60)
    print("   Generador de Diagramas Mermaid")
    print("=" * 60)
    print(f"Entrada:  {secuencia_dir}")
    print(f"Salida:   {output_dir}")
    print("=" * 60)
    
    count = 0
    errors = 0
    skipped = 0
    
    # Buscar todos los archivos .md en secuencia
    md_files = list(secuencia_dir.rglob("*.md"))
    
    for md_file in sorted(md_files):
        # Ignorar README.md
        if md_file.name.upper() == "README.MD":
            print(f"\n📄 Saltando: {md_file.name} (README)")
            continue
        
        relative_path = md_file.relative_to(secuencia_dir)
        print(f"\n📄 Procesando: {relative_path}")
        
        # Leer contenido
        try:
            with open(md_file, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"  ✗ Error leyendo archivo: {e}")
            errors += 1
            continue
        
        # Extraer diagramas
        diagrams = extract_mermaid_diagrams(content)
        
        if not diagrams:
            print("  (sin diagramas de secuencia/clase)")
            skipped += 1
            continue
        
        print(f"  {len(diagrams)} diagrama(s) encontrado(s)")
        
        # Crear subcarpeta para el módulo
        module_dir = output_dir / md_file.parent.name
        module_dir.mkdir(exist_ok=True)
        
        # Generar cada diagrama
        for i, diagram in enumerate(diagrams, 1):
            # Nombre del archivo de salida
            if len(diagrams) == 1:
                output_file = module_dir / f"{md_file.stem}.png"
            else:
                output_file = module_dir / f"{md_file.stem}_{i}.png"
            
            # Generar imagen
            if generate_mermaid_image_mermaid_ink(diagram, output_file):
                count += 1
            else:
                errors += 1
            
            # Rate limiting amigable
            time.sleep(0.5)
    
    print("\n" + "=" * 60)
    print(f"   Resultado:")
    print(f"   ✓ {count} imágenes generadas")
    print(f"   ✗ {errors} errores")
    print(f"   ⊘ {skipped} archivos sin diagramas")
    print(f"   📁 Ubicación: {output_dir}")
    print("=" * 60)

if __name__ == "__main__":
    main()
