"""
Generador de imágenes Mermaid - Mapa Navegacional
Genera PNG desde archivos .md con diagramas Mermaid

Uso:
    python generador_mapa_navegacional.py

Requiere:
    pip install requests
"""

from pathlib import Path
from funcs import process_md_files


def main():
    base_dir = Path(__file__).parent.parent.parent
    docs_dir = base_dir / "docs"
    source_dir = docs_dir / "mapa_navegacional"
    output_dir = docs_dir / "mapa_navegacional" / "images"
    
    print("=" * 60)
    print("   Generador - Mapa Navegacional")
    print("=" * 60)
    print(f"Entrada:  {source_dir}")
    print(f"Salida:   {output_dir}")
    print("=" * 60)
    
    diagram_types = ['flowchart', 'sequenceDiagram', 'classDiagram']
    count, errors, skipped = process_md_files(source_dir, output_dir, diagram_types)
    
    print("\n" + "=" * 60)
    print(f"   OK {count} | FAIL {errors} | SKIP {skipped}")
    print("=" * 60)


if __name__ == "__main__":
    main()
