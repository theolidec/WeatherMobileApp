from PIL import Image, ImageDraw, ImageFont
import os

def generate_icon(size, output_path):
    # Create a new image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw a simple weather icon (sun)
    center = size // 2
    radius = size // 3
    
    # Draw sun
    draw.ellipse(
        [
            (center - radius, center - radius),
            (center + radius, center + radius)
        ],
        fill='#FFD700'  # Gold color
    )
    
    # Save the image
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, 'PNG')

# Generate different sizes for Android
def generate_android_icons():
    sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    for folder, size in sizes.items():
        path = f'android/app/src/main/res/{folder}/ic_launcher.png'
        generate_icon(size, path)
        print(f'Generated {path} ({size}x{size})')

# Generate iOS App Icons
def generate_ios_icons():
    sizes = [
        (20, 1), (20, 2), (20, 3),  # Notification
        (29, 1), (29, 2), (29, 3),  # Settings
        (40, 1), (40, 2), (40, 3),  # Spotlight
        (60, 2), (60, 3),           # iPhone App
        (76, 1), (76, 2),           # iPad App
        (83.5, 2),                  # iPad Pro
    ]
    
    for size, scale in sizes:
        actual_size = int(size * scale)
        path = f'ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-{size}@{scale}x.png'
        generate_icon(actual_size, path)
        print(f'Generated {path} ({actual_size}x{actual_size})')

if __name__ == '__main__':
    print('Generating Android icons...')
    generate_android_icons()
    
    print('\nGenerating iOS icons...')
    generate_ios_icons()
    
    print('\nIcons generation complete!')
