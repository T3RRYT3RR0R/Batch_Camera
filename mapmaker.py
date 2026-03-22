#!/usr/bin/env python3
"""Interactive ASCII map editor inspired by DemoMap.txt.

The editor lets you place reusable structures in bitmap/pixel space and export
that scene into a plain text ASCII map. Objects are defined through an
extensible catalog so new terrain features can be added without changing the
editor workflow.
"""

from __future__ import annotations

import argparse
import json
import math
from dataclasses import asdict, dataclass, field
from pathlib import Path
import tkinter as tk
from tkinter import filedialog, messagebox, ttk
from typing import Dict, Iterable, List, Optional, Sequence, Tuple


DEFAULT_CANVAS_WIDTH = 240
DEFAULT_CANVAS_HEIGHT = 120
DEFAULT_EXPORT_COLUMNS = 120
DEFAULT_EXPORT_ROWS = 60
PREVIEW_COLUMNS = 80
PREVIEW_ROWS = 40
GRID_SIZE = 6
HANDLE_SIZE = 8
MIN_SIZE = 8
CANVAS_SCALE = 4


@dataclass(frozen=True)
class ObjectDefinition:
    """A reusable object/terrain definition.

    sprite: Base ASCII art that will be scaled into the placed bounding box.
    terrain: Whether the sprite should tile when stretched.
    layer: Higher layer objects render on top of lower layer ones.
    category: Used to group palette entries in the UI.
    """

    key: str
    label: str
    category: str
    sprite: Tuple[str, ...]
    layer: int = 0
    terrain: bool = False

    @property
    def width(self) -> int:
        return max((len(row) for row in self.sprite), default=1)

    @property
    def height(self) -> int:
        return max(len(self.sprite), 1)


@dataclass
class MapObject:
    object_key: str
    x: int
    y: int
    width: int
    height: int
    z_index: int = 0
    object_id: str = field(default_factory=str)

    def bounds(self) -> Tuple[int, int, int, int]:
        return self.x, self.y, self.x + self.width, self.y + self.height


class ObjectCatalog:
    """Extensible object catalog for palette/UI/export."""

    def __init__(self, definitions: Iterable[ObjectDefinition]):
        self._definitions: Dict[str, ObjectDefinition] = {
            definition.key: definition for definition in definitions
        }

    @classmethod
    def from_payload(cls, payload: Sequence[dict]) -> "ObjectCatalog":
        return cls(ObjectDefinition(**item) for item in payload)

    def get(self, key: str) -> ObjectDefinition:
        return self._definitions[key]

    def keys(self) -> List[str]:
        return list(self._definitions)

    def grouped(self) -> Dict[str, List[ObjectDefinition]]:
        groups: Dict[str, List[ObjectDefinition]] = {}
        for definition in self._definitions.values():
            groups.setdefault(definition.category, []).append(definition)
        return dict(sorted(groups.items(), key=lambda item: item[0]))

    def to_jsonable(self) -> List[dict]:
        return [asdict(definition) for definition in self._definitions.values()]


DEFAULT_CATALOG = ObjectCatalog(
    [
        ObjectDefinition(
            key="tree_cluster",
            label="Tree Cluster",
            category="Nature",
            layer=30,
            sprite=(
                "  }-{  ",
                " }}|{{ ",
                "}} W {{",
                "  | |  ",
                " o+o+o ",
            ),
        ),
        ObjectDefinition(
            key="bench",
            label="Bench",
            category="Props",
            layer=40,
            sprite=(
                "i-----i",
                "|_____|",
            ),
        ),
        ObjectDefinition(
            key="house",
            label="House",
            category="Buildings",
            layer=20,
            sprite=(
                "  _____  ",
                " /RRRRR\\ ",
                "|+o+o+o||",
                "|o+[ ]+||",
                "|+o+o+o||",
            ),
        ),
        ObjectDefinition(
            key="long_building",
            label="Long Building",
            category="Buildings",
            layer=20,
            sprite=(
                " _____  _____  _____ ",
                "/RRRRR\\/RRRRR\\/RRRRR\\",
                "|+o+o+o|+o+o+o|+o+o+o|",
                "|o+[ ]+|o+[ ]+|o+[ ]+|",
                "|+o+o+o|+o+o+o|+o+o+o|",
            ),
        ),
        ObjectDefinition(
            key="wall",
            label="Wall",
            category="Infrastructure",
            layer=10,
            terrain=True,
            sprite=(
                "||",
                "--",
            ),
        ),
        ObjectDefinition(
            key="road",
            label="Road",
            category="Infrastructure",
            layer=5,
            terrain=True,
            sprite=(
                "....====....",
                "============",
                "....====....",
            ),
        ),
        ObjectDefinition(
            key="water",
            label="Water",
            category="Terrain",
            layer=1,
            terrain=True,
            sprite=(
                "~~~~~~",
                "~≈≈≈≈~",
                "~~~~~~",
            ),
        ),
        ObjectDefinition(
            key="garden",
            label="Garden",
            category="Terrain",
            layer=2,
            terrain=True,
            sprite=(
                "+o+o+o",
                "o+o+o+",
            ),
        ),
    ]
)


def normalize_rows(rows: Sequence[str]) -> List[str]:
    width = max((len(row) for row in rows), default=0)
    return [row.ljust(width) for row in rows]


def scaled_sprite(definition: ObjectDefinition, width: int, height: int) -> List[str]:
    """Scale or tile a sprite to the requested size."""

    width = max(1, width)
    height = max(1, height)
    base = normalize_rows(definition.sprite)
    src_h = len(base)
    src_w = len(base[0]) if base else 1

    output: List[str] = []
    for y in range(height):
        if definition.terrain:
            source_row = base[y % src_h]
        else:
            src_y = min(src_h - 1, math.floor(y * src_h / height))
            source_row = base[src_y]

        row_chars = []
        for x in range(width):
            if definition.terrain:
                char = source_row[x % src_w]
            else:
                src_x = min(src_w - 1, math.floor(x * src_w / width))
                char = source_row[src_x]
            row_chars.append(char)
        output.append("".join(row_chars))
    return output


def rasterize_scene(
    objects: Sequence[MapObject],
    catalog: ObjectCatalog,
    width: int,
    height: int,
) -> List[str]:
    """Render placed objects into a text grid."""

    canvas = [[" " for _ in range(width)] for _ in range(height)]
    ordered = sorted(
        objects,
        key=lambda obj: (catalog.get(obj.object_key).layer, obj.z_index, obj.object_id),
    )

    for obj in ordered:
        definition = catalog.get(obj.object_key)
        sprite = scaled_sprite(definition, obj.width, obj.height)
        for dy, row in enumerate(sprite):
            target_y = obj.y + dy
            if not (0 <= target_y < height):
                continue
            for dx, char in enumerate(row):
                target_x = obj.x + dx
                if not (0 <= target_x < width):
                    continue
                if char != " ":
                    canvas[target_y][target_x] = char
    return ["".join(row).rstrip() for row in canvas]


class MapDocument:
    def __init__(self, canvas_width: int, canvas_height: int):
        self.canvas_width = canvas_width
        self.canvas_height = canvas_height
        self.objects: List[MapObject] = []
        self._next_id = 1

    def add_object(self, definition: ObjectDefinition, x: int, y: int) -> MapObject:
        width = max(definition.width * 2, MIN_SIZE)
        height = max(definition.height * 2, MIN_SIZE)
        obj = MapObject(
            object_key=definition.key,
            x=max(0, min(x, self.canvas_width - width)),
            y=max(0, min(y, self.canvas_height - height)),
            width=min(width, self.canvas_width),
            height=min(height, self.canvas_height),
            z_index=len(self.objects),
            object_id=f"obj-{self._next_id}",
        )
        self._next_id += 1
        self.objects.append(obj)
        return obj

    def delete_object(self, target: MapObject) -> None:
        self.objects = [obj for obj in self.objects if obj.object_id != target.object_id]

    def to_payload(self) -> dict:
        return {
            "canvas_width": self.canvas_width,
            "canvas_height": self.canvas_height,
            "objects": [asdict(obj) for obj in self.objects],
        }

    @classmethod
    def from_payload(cls, payload: dict) -> "MapDocument":
        doc = cls(payload["canvas_width"], payload["canvas_height"])
        doc.objects = [MapObject(**item) for item in payload.get("objects", [])]
        next_numeric = 1
        for obj in doc.objects:
            if obj.object_id.startswith("obj-"):
                suffix = obj.object_id.split("obj-", 1)[1]
                if suffix.isdigit():
                    next_numeric = max(next_numeric, int(suffix) + 1)
        doc._next_id = next_numeric
        return doc


class ASCIIMapEditor:
    def __init__(self, root: tk.Tk, catalog: ObjectCatalog, document: MapDocument):
        self.root = root
        self.catalog = catalog
        self.document = document
        self.selected_object_key = tk.StringVar(value=catalog.keys()[0])
        self.selected_map_object: Optional[MapObject] = None
        self.status_text = tk.StringVar(value="Ready")
        self.preview_scale_x = PREVIEW_COLUMNS / document.canvas_width
        self.preview_scale_y = PREVIEW_ROWS / document.canvas_height
        self.drag_mode: Optional[str] = None
        self.drag_anchor: Tuple[int, int] = (0, 0)
        self.original_bounds: Tuple[int, int, int, int] = (0, 0, 0, 0)
        self.current_file: Optional[Path] = None
        self._build_ui()
        self.redraw_canvas()
        self.refresh_preview()

    def _build_ui(self) -> None:
        self.root.title("ASCII Map Editor")
        self.root.geometry("1380x860")

        self.root.columnconfigure(1, weight=1)
        self.root.rowconfigure(0, weight=1)

        sidebar = ttk.Frame(self.root, padding=10)
        sidebar.grid(row=0, column=0, sticky="ns")
        self.sidebar = sidebar

        workspace = ttk.Frame(self.root, padding=10)
        workspace.grid(row=0, column=1, sticky="nsew")
        workspace.columnconfigure(0, weight=3)
        workspace.columnconfigure(1, weight=2)
        workspace.rowconfigure(0, weight=1)

        ttk.Label(sidebar, text="Palette", font=("TkDefaultFont", 12, "bold")).pack(anchor="w")
        self.palette_container = ttk.Frame(sidebar)
        self.palette_container.pack(fill="x", pady=(4, 0))
        self.populate_palette()

        actions = ttk.LabelFrame(sidebar, text="Actions", padding=8)
        actions.pack(fill="x", pady=8)
        ttk.Button(actions, text="Delete selected", command=self.delete_selected).pack(fill="x", pady=2)
        ttk.Button(actions, text="Bring to front", command=self.bring_to_front).pack(fill="x", pady=2)
        ttk.Button(actions, text="Export ASCII", command=self.export_ascii).pack(fill="x", pady=2)
        ttk.Button(actions, text="Save project", command=self.save_project).pack(fill="x", pady=2)
        ttk.Button(actions, text="Load project", command=self.load_project).pack(fill="x", pady=2)

        help_frame = ttk.LabelFrame(sidebar, text="How it works", padding=8)
        help_frame.pack(fill="x", pady=8)
        ttk.Label(
            help_frame,
            text=(
                "• Click empty canvas to place the selected object\n"
                "• Click an object to select it\n"
                "• Drag selected object to move it\n"
                "• Drag the lower-right handle to resize it\n"
                "• Export converts the bitmap scene into ASCII"
            ),
            justify="left",
        ).pack(anchor="w")

        self.canvas = tk.Canvas(
            workspace,
            bg="#111111",
            width=self.document.canvas_width * CANVAS_SCALE,
            height=self.document.canvas_height * CANVAS_SCALE,
            highlightthickness=1,
            highlightbackground="#555555",
        )
        self.canvas.grid(row=0, column=0, sticky="nsew", padx=(0, 10))
        self.canvas.bind("<Button-1>", self.on_canvas_down)
        self.canvas.bind("<B1-Motion>", self.on_canvas_drag)
        self.canvas.bind("<ButtonRelease-1>", self.on_canvas_up)

        preview_panel = ttk.Frame(workspace)
        preview_panel.grid(row=0, column=1, sticky="nsew")
        preview_panel.rowconfigure(1, weight=1)
        preview_panel.columnconfigure(0, weight=1)

        ttk.Label(preview_panel, text="ASCII preview", font=("TkDefaultFont", 12, "bold")).grid(
            row=0, column=0, sticky="w"
        )
        self.preview_text = tk.Text(
            preview_panel,
            wrap="none",
            width=PREVIEW_COLUMNS,
            height=PREVIEW_ROWS,
            font=("Courier New", 8),
        )
        self.preview_text.grid(row=1, column=0, sticky="nsew")
        self.preview_text.configure(state="disabled")

        status = ttk.Label(self.root, textvariable=self.status_text, relief="sunken", anchor="w")
        status.grid(row=1, column=0, columnspan=2, sticky="ew")

        self.root.bind("<Delete>", lambda event: self.delete_selected())
        self.root.bind("<Control-s>", lambda event: self.save_project())
        self.root.bind("<Control-o>", lambda event: self.load_project())
        self.root.bind("<Control-e>", lambda event: self.export_ascii())


    def populate_palette(self) -> None:
        for child in self.palette_container.winfo_children():
            child.destroy()
        available_keys = self.catalog.keys()
        if not available_keys:
            return
        if self.selected_object_key.get() not in available_keys:
            self.selected_object_key.set(available_keys[0])
        for category, definitions in self.catalog.grouped().items():
            frame = ttk.LabelFrame(self.palette_container, text=category, padding=8)
            frame.pack(fill="x", pady=4)
            for definition in definitions:
                ttk.Radiobutton(
                    frame,
                    text=definition.label,
                    value=definition.key,
                    variable=self.selected_object_key,
                ).pack(anchor="w")

    def set_status(self, message: str) -> None:
        self.status_text.set(message)

    def canvas_to_map(self, event: tk.Event) -> Tuple[int, int]:
        return int(event.x / CANVAS_SCALE), int(event.y / CANVAS_SCALE)

    def hit_test(self, x: int, y: int) -> Optional[MapObject]:
        for obj in sorted(self.document.objects, key=lambda item: item.z_index, reverse=True):
            left, top, right, bottom = obj.bounds()
            if left <= x <= right and top <= y <= bottom:
                return obj
        return None

    def resize_handle_hit(self, obj: MapObject, x: int, y: int) -> bool:
        _, _, right, bottom = obj.bounds()
        return abs(x - right) <= 3 and abs(y - bottom) <= 3

    def on_canvas_down(self, event: tk.Event) -> None:
        x, y = self.canvas_to_map(event)
        target = self.hit_test(x, y)
        if target:
            self.selected_map_object = target
            self.original_bounds = target.bounds()
            self.drag_anchor = (x, y)
            if self.resize_handle_hit(target, x, y):
                self.drag_mode = "resize"
                self.set_status(f"Resizing {self.catalog.get(target.object_key).label}")
            else:
                self.drag_mode = "move"
                self.set_status(f"Moving {self.catalog.get(target.object_key).label}")
        else:
            definition = self.catalog.get(self.selected_object_key.get())
            self.selected_map_object = self.document.add_object(definition, x, y)
            self.drag_mode = "move"
            self.drag_anchor = (x, y)
            self.original_bounds = self.selected_map_object.bounds()
            self.set_status(f"Placed {definition.label}")
        self.redraw_canvas()
        self.refresh_preview()

    def on_canvas_drag(self, event: tk.Event) -> None:
        if not self.selected_map_object or not self.drag_mode:
            return

        x, y = self.canvas_to_map(event)
        obj = self.selected_map_object
        left, top, right, bottom = self.original_bounds

        if self.drag_mode == "move":
            dx = x - self.drag_anchor[0]
            dy = y - self.drag_anchor[1]
            obj.x = max(0, min(self.document.canvas_width - obj.width, left + dx))
            obj.y = max(0, min(self.document.canvas_height - obj.height, top + dy))
        elif self.drag_mode == "resize":
            obj.width = max(MIN_SIZE, min(self.document.canvas_width - obj.x, right - left + (x - self.drag_anchor[0])))
            obj.height = max(MIN_SIZE, min(self.document.canvas_height - obj.y, bottom - top + (y - self.drag_anchor[1])))

        self.redraw_canvas()
        self.refresh_preview()

    def on_canvas_up(self, event: tk.Event) -> None:
        self.drag_mode = None
        self.set_status("Ready")

    def delete_selected(self) -> None:
        if not self.selected_map_object:
            return
        label = self.catalog.get(self.selected_map_object.object_key).label
        self.document.delete_object(self.selected_map_object)
        self.selected_map_object = None
        self.set_status(f"Deleted {label}")
        self.redraw_canvas()
        self.refresh_preview()

    def bring_to_front(self) -> None:
        if not self.selected_map_object:
            return
        self.selected_map_object.z_index = max((obj.z_index for obj in self.document.objects), default=0) + 1
        self.set_status("Moved selection to front")
        self.redraw_canvas()
        self.refresh_preview()

    def redraw_canvas(self) -> None:
        self.canvas.delete("all")
        for gx in range(0, self.document.canvas_width * CANVAS_SCALE, GRID_SIZE * CANVAS_SCALE):
            self.canvas.create_line(gx, 0, gx, self.document.canvas_height * CANVAS_SCALE, fill="#222222")
        for gy in range(0, self.document.canvas_height * CANVAS_SCALE, GRID_SIZE * CANVAS_SCALE):
            self.canvas.create_line(0, gy, self.document.canvas_width * CANVAS_SCALE, gy, fill="#222222")

        for obj in sorted(self.document.objects, key=lambda item: item.z_index):
            definition = self.catalog.get(obj.object_key)
            x1, y1, x2, y2 = [value * CANVAS_SCALE for value in obj.bounds()]
            fill = "#2b5a88" if definition.category in {"Terrain", "Infrastructure"} else "#3f6b3f"
            self.canvas.create_rectangle(x1, y1, x2, y2, outline="#dddddd", fill=fill)
            self.canvas.create_text(
                x1 + 4,
                y1 + 4,
                text=definition.label,
                anchor="nw",
                fill="#ffffff",
                font=("TkDefaultFont", 9, "bold"),
            )
            preview_rows = scaled_sprite(definition, max(1, min(20, obj.width // 2)), max(1, min(8, obj.height // 2)))
            for index, row in enumerate(preview_rows[:4]):
                self.canvas.create_text(
                    x1 + 4,
                    y1 + 22 + (index * 10),
                    text=row[:24],
                    anchor="nw",
                    fill="#f7f0c0",
                    font=("Courier New", 8),
                )
            if self.selected_map_object and obj.object_id == self.selected_map_object.object_id:
                self.canvas.create_rectangle(x1, y1, x2, y2, outline="#ffcc00", width=2)
                self.canvas.create_rectangle(
                    x2 - HANDLE_SIZE,
                    y2 - HANDLE_SIZE,
                    x2,
                    y2,
                    outline="#ffcc00",
                    fill="#ffcc00",
                )

    def refresh_preview(self) -> None:
        preview_objects = [
            MapObject(
                object_key=obj.object_key,
                x=max(0, int(obj.x * self.preview_scale_x)),
                y=max(0, int(obj.y * self.preview_scale_y)),
                width=max(1, int(obj.width * self.preview_scale_x)),
                height=max(1, int(obj.height * self.preview_scale_y)),
                z_index=obj.z_index,
                object_id=obj.object_id,
            )
            for obj in self.document.objects
        ]
        rendered = rasterize_scene(preview_objects, self.catalog, PREVIEW_COLUMNS, PREVIEW_ROWS)
        content = "\n".join(rendered)
        self.preview_text.configure(state="normal")
        self.preview_text.delete("1.0", tk.END)
        self.preview_text.insert("1.0", content)
        self.preview_text.configure(state="disabled")

    def export_ascii(self) -> None:
        path = filedialog.asksaveasfilename(
            title="Export ASCII map",
            defaultextension=".txt",
            filetypes=[("Text files", "*.txt"), ("All files", "*.*")],
        )
        if not path:
            return
        rendered = rasterize_scene(
            [
                MapObject(
                    object_key=obj.object_key,
                    x=max(0, int(obj.x * (DEFAULT_EXPORT_COLUMNS / self.document.canvas_width))),
                    y=max(0, int(obj.y * (DEFAULT_EXPORT_ROWS / self.document.canvas_height))),
                    width=max(1, int(obj.width * (DEFAULT_EXPORT_COLUMNS / self.document.canvas_width))),
                    height=max(1, int(obj.height * (DEFAULT_EXPORT_ROWS / self.document.canvas_height))),
                    z_index=obj.z_index,
                    object_id=obj.object_id,
                )
                for obj in self.document.objects
            ],
            self.catalog,
            DEFAULT_EXPORT_COLUMNS,
            DEFAULT_EXPORT_ROWS,
        )
        header = "REM " + " ".join(sorted({char for row in rendered for char in row if char.strip()}))
        Path(path).write_text(header + "\n\n" + "\n".join(rendered) + "\n", encoding="utf-8")
        self.set_status(f"Exported ASCII map to {path}")
        messagebox.showinfo("Export complete", f"ASCII map saved to\n{path}")

    def save_project(self) -> None:
        path = filedialog.asksaveasfilename(
            title="Save project",
            defaultextension=".json",
            filetypes=[("JSON files", "*.json"), ("All files", "*.*")],
        )
        if not path:
            return
        payload = {
            "catalog": self.catalog.to_jsonable(),
            "document": self.document.to_payload(),
        }
        Path(path).write_text(json.dumps(payload, indent=2), encoding="utf-8")
        self.current_file = Path(path)
        self.set_status(f"Saved project to {path}")

    def load_project(self) -> None:
        path = filedialog.askopenfilename(
            title="Load project",
            filetypes=[("JSON files", "*.json"), ("All files", "*.*")],
        )
        if not path:
            return
        payload = json.loads(Path(path).read_text(encoding="utf-8"))
        if payload.get("catalog"):
            self.catalog = ObjectCatalog.from_payload(payload["catalog"])
            self.populate_palette()
        self.document = MapDocument.from_payload(payload["document"])
        self.preview_scale_x = PREVIEW_COLUMNS / self.document.canvas_width
        self.preview_scale_y = PREVIEW_ROWS / self.document.canvas_height
        self.selected_map_object = None
        self.current_file = Path(path)
        self.redraw_canvas()
        self.refresh_preview()
        self.set_status(f"Loaded project from {path}")


def build_argument_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Interactive ASCII map editor/exporter.")
    parser.add_argument("--width", type=int, default=DEFAULT_CANVAS_WIDTH, help="Canvas width in bitmap units.")
    parser.add_argument("--height", type=int, default=DEFAULT_CANVAS_HEIGHT, help="Canvas height in bitmap units.")
    return parser


def main() -> None:
    parser = build_argument_parser()
    parser.add_argument(
        "--catalog",
        type=Path,
        help="Optional JSON file containing object definitions to extend or replace the defaults.",
    )
    args = parser.parse_args()
    root = tk.Tk()
    document = MapDocument(args.width, args.height)
    catalog = DEFAULT_CATALOG
    if args.catalog:
        payload = json.loads(args.catalog.read_text(encoding="utf-8"))
        catalog = ObjectCatalog.from_payload(payload)
    ASCIIMapEditor(root, catalog, document)
    root.mainloop()


if __name__ == "__main__":
    main()
