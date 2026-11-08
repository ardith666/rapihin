import os
from PIL import Image, ImageDraw, ImageFont

os.makedirs("assets", exist_ok=True)
width, height = 660, 420
image = Image.new("RGBA", (width, height), (26, 28, 36, 255))
draw = ImageDraw.Draw(image)

# Background subtle gradient
for y in range(height):
    ratio = y / height
    r = int(24 * (1 - ratio) + 16 * ratio)
    g = int(27 * (1 - ratio) + 18 * ratio)
    b = int(38 * (1 - ratio) + 26 * ratio)
    draw.line([(0, y), (width, y)], fill=(r, g, b, 255))

# Draw sleek card in center
card_box = (40, 50, width - 40, height - 60)
draw.rounded_rectangle(card_box, radius=20, fill=(35, 39, 52, 220), outline=(60, 66, 88, 255), width=1)

# Title & Instruction
try:
    font_large = ImageFont.truetype("/System/Library/Fonts/SFProRounded.ttf", 20)
    font_sub = ImageFont.truetype("/System/Library/Fonts/SFPro.ttf", 13)
except Exception:
    font_large = ImageFont.load_default()
    font_sub = ImageFont.load_default()

title_text = "Install Rapihin"
sub_text = "Drag to Applications to install"

# Draw text centered
title_w = draw.textlength(title_text, font=font_large)
draw.text(((width - title_w) / 2, 75), title_text, fill=(240, 243, 250, 255), font=font_large)

sub_w = draw.textlength(sub_text, font=font_sub)
draw.text(((width - sub_w) / 2, 105), sub_text, fill=(145, 155, 175, 255), font=font_sub)

# Draw central stylish arrow between 175 (app) and 485 (Applications)
arrow_y = 220
arrow_start_x = 265
arrow_end_x = 395

# Glow behind arrow
for offset in range(-2, 3):
    draw.line([(arrow_start_x, arrow_y + offset), (arrow_end_x - 10, arrow_y + offset)], fill=(80, 120, 240, 40), width=4)

# Main arrow shaft
draw.line([(arrow_start_x, arrow_y), (arrow_end_x - 10, arrow_y)], fill=(120, 160, 255, 220), width=3)

# Arrow head
arrow_head = [
    (arrow_end_x, arrow_y),
    (arrow_end_x - 14, arrow_y - 8),
    (arrow_end_x - 10, arrow_y),
    (arrow_end_x - 14, arrow_y + 8)
]
draw.polygon(arrow_head, fill=(120, 160, 255, 255))

image.save("assets/dmg_background.png")
print("✅ Created assets/dmg_background.png")
