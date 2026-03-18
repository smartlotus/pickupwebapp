import os
from PIL import Image, ImageChops

def smart_crop_to_square(img_path, out_path, padding=40):
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    img = Image.open(img_path).convert('RGB')
    
    # Create a bg image of the same color as the top-left pixel (assumed background)
    bg = Image.new(img.mode, img.size, img.getpixel((0,0)))
    diff = ImageChops.difference(img, bg)
    
    # threshold to make diff more sensitive
    diff = ImageChops.add(diff, diff, 2.0, -100)
    bbox = diff.getbbox()
    
    if bbox:
        # crop to bounding box
        cropped = img.crop(bbox)
        
        # Calculate new size with padding
        w, h = cropped.size
        size = max(w, h) + padding * 2
        
        # Create a new square image with the background color
        new_img = Image.new('RGB', (size, size), img.getpixel((0,0)))
        
        # Paste the cropped image in the center
        paste_pos = ((size - w) // 2, (size - h) // 2)
        new_img.paste(cropped, paste_pos)
        
        # Save as PNG
        new_img.save(out_path, "PNG")
        print("Success")
    else:
        # If no bounding box found, just save the original image as PNG
        img.save(out_path, "PNG")
        print("Success (No bounding box)")

if __name__ == '__main__':
    img_path = r'C:\Users\28389\.gemini\antigravity\brain\23f618f5-2a63-4e56-8048-850bef3fa919\media__1772899831405.jpg'
    out_path = r'c:\Users\28389\Desktop\new\omni_capsule\assets\icon.png'
    smart_crop_to_square(img_path, out_path)
