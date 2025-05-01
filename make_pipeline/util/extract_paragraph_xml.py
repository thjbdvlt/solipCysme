from lxml import etree
import os
import typer
from pathlib import Path


def main(directory: Path, fp_out: Path, max: int = 10000):
    """Extract paragraphs from XML files stored in a directory."""
    if not directory.is_dir():
        raise ValueError("Not a directory:", directory)
    files = os.listdir(directory)
    files = sorted(files)  # Ensure reproductibility
    n = 0
    fo = fp_out.open("bw")
    for file in files:
        if file.endswith(".xml"):
            x = etree.parse(file)
            for i in x.iterdescendants():
                if i.tag == "p":
                    n += 1
                    if n >= max:
                        fo.close()
                        return
                    s = etree.tostring(
                        i,
                        with_tail=False,
                        method="text",
                        encoding="utf-8",
                    )
                    fo.write(s)
    fo.close()


if __name__ == "__main__":
    typer.run(main)
