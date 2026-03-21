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
    """Extrae todos los bloques mermaid con su encabezado ##"""
    sections = []
    lines = md_content.split('\n')
    current_heading = None
    
    for i, line in enumerate(lines):
        if line.startswith('## '):
            current_heading = line.replace('## ', '').strip()
            current_heading = re.sub(r'[^a-zA-Z0-9\s]', '', current_heading)
            current_heading = re.sub(r'\s+', '_', current_heading).lower()
        elif line.startswith('```mermaid'):
            diagram_lines = []
            j = i + 1
            while j < len(lines) and not lines[j].startswith('```'):
                diagram_lines.append(lines[j])
                j += 1
            diagram = '\n'.join(diagram_lines).strip()
            if 'sequenceDiagram' in diagram or 'classDiagram' in diagram:
                sections.append({
                    'heading': current_heading or f'diagrama_{len(sections)+1}',
                    'diagram': diagram
                })
    
    return sections

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
        
        # Extraer diagramas con sus encabezados
        diagrams = extract_mermaid_diagrams(content)
        
        if not diagrams:
            print("  (sin diagramas de secuencia/clase)")
            skipped += 1
            continue
        
        print(f"  {len(diagrams)} diagrama(s) encontrado(s)")
        
        # Crear subcarpeta para el modulo
        module_dir = output_dir / md_file.parent.name
        module_dir.mkdir(exist_ok=True)
        
        # Generar cada diagrama
        for section in diagrams:
            heading = section['heading']
            diagram = section['diagram']
            
            # Nombre del archivo: stem_accion.png
            output_file = module_dir / f"{md_file.stem}_{heading}.png"
            
            # Generar imagen
            if generate_mermaid_image_mermaid_ink(diagram, output_file):
                count += 1
            else:
                errors += 1
            
            # Rate limiting
            # time.sleep(0.5)
    
    print("\n" + "=" * 60)
    print(f"   Resultado:")
    print(f"   ✓ {count} imágenes generadas")
    print(f"   ✗ {errors} errores")
    print(f"   ⊘ {skipped} archivos sin diagramas")
    print(f"   📁 Ubicación: {output_dir}")
    print("=" * 60)

if __name__ == "__main__":
    main()
