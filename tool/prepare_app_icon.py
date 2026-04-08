from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


def find_subject_bbox(image: Image.Image, threshold: int = 28) -> tuple[int, int, int, int]:
    rgba = image.convert("RGBA")
    width, height = rgba.size
    pixels = rgba.load()

    min_x, min_y = width, height
    max_x, max_y = 0, 0
    found = False

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            if max(r, g, b) <= threshold:
                continue
            found = True
            if x < min_x:
                min_x = x
            if y < min_y:
                min_y = y
            if x > max_x:
                max_x = x
            if y > max_y:
                max_y = y

    if not found:
        return 0, 0, width, height

    return min_x, min_y, max_x + 1, max_y + 1


def render_icon_canvas(
    image: Image.Image,
    bbox: tuple[int, int, int, int],
    output_size: int = 1024,
    inset_ratio: float = 0.14,
) -> Image.Image:
    min_x, min_y, max_x, max_y = bbox
    subject = image.convert("RGBA").crop((min_x, min_y, max_x, max_y))
    subject_width, subject_height = subject.size
    available = int(round(output_size * (1.0 - inset_ratio * 2.0)))
    scale = min(available / subject_width, available / subject_height)
    scaled_width = max(1, int(round(subject_width * scale)))
    scaled_height = max(1, int(round(subject_height * scale)))
    resized = subject.resize((scaled_width, scaled_height), Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", (output_size, output_size), (0, 0, 0, 0))
    left = (output_size - scaled_width) // 2
    top = (output_size - scaled_height) // 2
    canvas.alpha_composite(resized, (left, top))
    return canvas


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Prepare a square launcher icon canvas from a transparent source mark.",
    )
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--output-size", type=int, default=1024)
    parser.add_argument("--inset-ratio", type=float, default=0.14)
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    source = args.source
    output = args.output

    if not source.exists():
        print(f"Source image not found: {source}")
        return 1

    output.parent.mkdir(parents=True, exist_ok=True)

    with Image.open(source) as image:
        bbox = find_subject_bbox(image)
        prepared = render_icon_canvas(
            image,
            bbox,
            output_size=args.output_size,
            inset_ratio=args.inset_ratio,
        )
        prepared.save(output, format="PNG")

    print(f"Prepared icon source: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
