from __future__ import annotations

import sys
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


def build_square_crop(
    image_size: tuple[int, int],
    bbox: tuple[int, int, int, int],
    padding_ratio: float = 0.10,
) -> tuple[int, int, int, int]:
    image_width, image_height = image_size
    min_x, min_y, max_x, max_y = bbox
    bbox_width = max_x - min_x
    bbox_height = max_y - min_y

    side = int(max(bbox_width, bbox_height) * (1.0 + padding_ratio * 2.0))
    side = min(side, image_width, image_height)

    center_x = (min_x + max_x) / 2.0
    center_y = (min_y + max_y) / 2.0

    left = int(round(center_x - side / 2.0))
    top = int(round(center_y - side / 2.0))

    left = max(0, min(left, image_width - side))
    top = max(0, min(top, image_height - side))

    return left, top, left + side, top + side


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: python prepare_app_icon.py <source> <output>")
        return 1

    source = Path(sys.argv[1])
    output = Path(sys.argv[2])

    if not source.exists():
        print(f"Source image not found: {source}")
        return 1

    output.parent.mkdir(parents=True, exist_ok=True)

    with Image.open(source) as image:
        bbox = find_subject_bbox(image)
        crop = build_square_crop(image.size, bbox)
        prepared = image.convert("RGBA").crop(crop).resize(
            (1024, 1024),
            Image.Resampling.LANCZOS,
        )
        prepared.save(output, format="PNG")

    print(f"Prepared icon source: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
