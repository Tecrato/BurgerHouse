"""
Funciones comunes para generadores de diagramas Mermaid
"""

import re
import requests
import json
import time


def extract_mermaid_sections(md_content, diagram_types=None):
    """
    Extrae bloques mermaid con su encabezado ## y tipo de diagrama.
    
    Args:
        md_content: Contenido del archivo markdown
        diagram_types: Lista de tipos a filtrar (None = todos)
                      Opciones: 'flowchart', 'sequenceDiagram', 'classDiagram'
    
    Returns:
        Lista de dicts con 'heading' y 'diagram'
    """
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
            
            if diagram_types:
                if not any(dtype in diagram for dtype in diagram_types):
                    continue
            else:
                if not any(dtype in diagram for dtype in ['flowchart', 'sequenceDiagram', 'classDiagram']):
                    continue
            
            sections.append({
                'heading': current_heading or f'diagrama_{len(sections)+1}',
                'diagram': diagram
            })
    
    return sections


def generate_mermaid_image(mermaid_code, output_path):
    """
    Genera imagen PNG usando APIs de Mermaid (Kroki o Mermaid.ink).
    
    Args:
        mermaid_code: Codigo Mermaid
        output_path: Ruta donde guardar la imagen
    
    Returns:
        True si exitoso, False si falla
    """
    clean_code = mermaid_code.strip()
    
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
            print(f"  OK {output_path.name}")
            return True
    except Exception as e:
        print(f"  FAIL {output_path.name}: {e}")
        pass
    
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
            print(f"  OK {output_path.name}")
            return True
    except Exception as e:
        print(f"  FAIL {output_path.name}: {e}")
        pass
    
    print(f"  FAIL {output_path.name}")
    return False


def process_md_files(source_dir, output_dir, diagram_types=None):
    """
    Procesa archivos .md y genera imagenes PNG.
    
    Args:
        source_dir: Directorio con archivos .md (Path o string)
        output_dir: Directorio donde guardar imagenes (Path o string)
        diagram_types: Tipos de diagrama a incluir
    
    Returns:
        Tupla (count, errors, skipped)
    """
    from pathlib import Path
    import shutil
    
    source_dir = Path(source_dir)
    output_dir = Path(output_dir)
    
    output_dir.mkdir(parents=True, exist_ok=True)
    
    count = 0
    errors = 0
    skipped = 0
    
    md_files = list(source_dir.rglob("*.md")) if source_dir.is_dir() else [source_dir]
    
    for md_file in sorted(md_files):
        if md_file.name.lower() == "readme.md":
            continue
        
        relative_path = md_file.relative_to(source_dir) if source_dir.is_dir() else md_file.name
        print(f"\n> {relative_path}")
        
        try:
            with open(md_file, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"  X Error: {e}")
            errors += 1
            continue
        
        diagrams = extract_mermaid_sections(content, diagram_types)
        
        if not diagrams:
            print("  - Sin diagramas")
            skipped += 1
            continue
        
        print(f"  {len(diagrams)} diagrama(s)")
        
        module_dir = output_dir / md_file.parent.name
        module_dir.mkdir(exist_ok=True)
        
        for section in diagrams:
            heading = section['heading']
            diagram = section['diagram']
            output_file = module_dir / f"{md_file.stem}_{heading}.png"
            
            if generate_mermaid_image(diagram, output_file):
                count += 1
            else:
                errors += 1
            time.sleep(.5)
    
    return count, errors, skipped
