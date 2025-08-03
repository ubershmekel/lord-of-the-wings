import json
import os


def aseprite_to_godot_spriteframes(json_path, png_gdrespath, output_tres_path, uid_prefix="ducky"):
    with open(json_path, 'r') as f:
        data = json.load(f)

    frames = list(data['frames'].items())
    tags = data['meta'].get('frameTags', [])

    # Normalize texture path
    texture_path = png_gdrespath.replace('\\', '/')
    if not texture_path.startswith("res://"):
        raise ValueError(
            "png_path must be a Godot-style resource path (e.g., res://textures/ducky.png)")

    output = []
    output.append('[gd_resource type="SpriteFrames" load_steps={} format=3 uid="uid://{}"]'.format(
        len(frames) + 2, uid_prefix + "85cka"))
    output.append('')
    output.append(
        f'[ext_resource type="Texture2D" uid="uid://{uid_prefix}fdxv0i1gdsi5" path="{texture_path}" id="1"]')
    output.append('')

    # Generate AtlasTextures
    atlas_ids = []
    for idx, (frame_name, frame_data) in enumerate(frames):
        sub_id = f"{uid_prefix}_atlas_{idx}"
        atlas_ids.append(sub_id)
        x, y, w, h = (frame_data["frame"][k] for k in ("x", "y", "w", "h"))
        output.append(f'[sub_resource type="AtlasTexture" id="{sub_id}"]')
        output.append('atlas = ExtResource("1")')
        output.append(f'region = Rect2({x}, {y}, {w}, {h})\n')

    # Build animation blocks
    output.append('[resource]')
    output.append('animations = [')

    for tag_i, tag in enumerate(tags):
        name = tag["name"]
        from_idx = tag["from"]
        to_idx = tag["to"]
        output.append('{')
        output.append(f'"frames": [')

        for i in range(from_idx, to_idx + 1):
            output.append(
                f'{{\n"duration": 1.0,\n"texture": SubResource("{atlas_ids[i]}")\n}},')

        output.append('],')
        output.append('"loop": true,')
        output.append(f'"name": &"{name}",')
        output.append('"speed": 5.0')
        # No comma after last animation
        output.append('},' if tag_i < len(tags) - 1 else '}')

    output.append(']')

    with open(output_tres_path, 'w') as f:
        f.write('\n'.join(output))

    print(f"✅ Godot SpriteFrames .tres saved to: {output_tres_path}")


# Example usage:
# Assuming the script is in 'tools/' and assets are in 'textures/'
# Relative paths from the script's location:
# json_path: ../textures/ducky.json
# png_path: ../textures/ducky.png
# output_tres_path: ../textures/ducky.tres

script_dir = os.path.dirname(__file__)
# This should be the project root
base_dir = os.path.abspath(os.path.join(script_dir, os.pardir))

assets = [
    ('textures/ducky.json', 'textures/ducky.png', 'textures/ducky.tres'),
]

for json_path, png_path, output_tres_path in assets:
    aseprite_to_godot_spriteframes(
        json_path=os.path.join(base_dir, json_path),
        # png_path=os.path.join(base_dir, png_path),
        png_gdrespath='res://' + png_path,  # Use Godot-style path
        output_tres_path=os.path.join(base_dir, output_tres_path)
    )
