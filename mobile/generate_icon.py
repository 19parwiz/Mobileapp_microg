from PIL import Image, ImageDraw
import math

# Create a 512x512 image with soft green background
width, height = 512, 512
image = Image.new('RGBA', (width, height), (240, 250, 240, 255))  # Very soft green background
draw = ImageDraw.Draw(image)

# Define colors
dark_green = (34, 139, 34, 255)      # Forest green
medium_green = (60, 179, 113, 255)   # Medium sea green
light_green = (144, 238, 144, 255)   # Light green

# Center point
center_x, center_y = width // 2, height // 2

# Draw soil/pot base (subtle)
soil_y = center_y + 80
draw.ellipse([center_x - 100, soil_y - 20, center_x + 100, soil_y + 60], 
             fill=(120, 100, 80, 200), outline=(100, 80, 60, 200), width=2)

# Function to draw a curved leaf/sprout
def draw_leaf(x_base, y_base, angle, length, color):
    """Draw a curved leaf using multiple circles"""
    steps = 8
    for i in range(steps):
        t = i / steps
        # Curve the leaf
        curve_x = x_base + math.sin(math.radians(angle)) * length * t + math.cos(math.radians(angle)) * t * 20
        curve_y = y_base - math.cos(math.radians(angle)) * length * t
        
        # Draw segment
        radius = 8 - (i * 0.8)  # Taper towards tip
        draw.ellipse([curve_x - radius, curve_y - radius, 
                     curve_x + radius, curve_y + radius], 
                    fill=color, outline=color)

# Draw main stem
stem_x = center_x
stem_y = soil_y - 40
draw.line([(stem_x, soil_y), (stem_x, stem_y - 40)], fill=medium_green, width=6)

# Draw sprout leaves - 4 leaves arranged in a circle
leaf_angles = [45, 135, 225, 315]
leaf_colors = [dark_green, medium_green, dark_green, medium_green]

for angle, color in zip(leaf_angles, leaf_colors):
    start_x = stem_x
    start_y = stem_y - 30
    draw_leaf(start_x, start_y, angle, 120, color)

# Draw top central sprout (tallest)
draw_leaf(stem_x, stem_y - 60, 90, 150, dark_green)

# Add subtle highlight leaves
for angle in [0, 90, 180, 270]:
    offset_angle = angle + 45
    start_x = stem_x + math.cos(math.radians(angle)) * 40
    start_y = stem_y - 20
    draw_leaf(start_x, start_y, offset_angle, 80, light_green)

# Save the image
image.save('app_icon.png')
print("✅ App icon created: app_icon.png (512x512 PNG)")
print("📁 Location: d:\\DiplomaMobileAPP\\mobile\\app_icon.png")
