"""
Generador de imágenes Mermaid - Diagramas de Secuencia
Genera PNG desde archivos .md con diagramas Mermaid

Uso:
    python generador_diagramas_secuencia.py

Requiere:
    pip install requests
"""

from pathlib import Path
from funcs import process_md_files


def main():
    base_dir = Path(__file__).parent
    # From scripts/, go to parent docs/ then to secuencia/
    docs_dir = base_dir.parent
    source_dir = docs_dir / "secuencia"
    output_dir = docs_dir / "secuencia" / "images"
    
    print("=" * 60)
    print("   Generador - Diagramas de Secuencia")
    print("=" * 60)
    print(f"Entrada:  {source_dir}")
    print(f"Salida:   {output_dir}")
    print("=" * 60)
    
    diagram_types = ['sequenceDiagram', 'classDiagram']
    count, errors, skipped = process_md_files(source_dir, output_dir, diagram_types)
    
    print("\n" + "=" * 60)
    print(f"   OK {count} | FAIL {errors} | SKIP {skipped}")
    print("=" * 60)


if __name__ == "__main__":
    main()
