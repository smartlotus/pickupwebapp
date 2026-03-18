import os
from PIL import Image, ImageChops

def crop_icon(img_path, out_path):
    img = Image.open(img_path).convert('RGBA')
    
    # The background is white (255, 255, 255). 
    # We want to crop to the black part.
    # Create a white background to find the difference
    bg = Image.new('RGBA', img.size, (255, 255, 255, 255))
    diff = ImageChops.difference(img, bg)
    
    # Convert diff to grayscale to get bbox
    bbox = diff.convert('L').getbbox()
    
    if bbox:
        # Crop to the bounding box
        cropped = img.crop(bbox)
        
        # Now, we want a pure black background.
        # But wait, the icon itself has rounded corners.
        # If we just put it on a black background, the rounded corners will disappear into it, 
        # which is exactly what "full black background" implies.
        
        # Get the size
        w, h = cropped.size
        size = max(w, h)
        
        # Create a new pure black square image
        new_img = Image.new('RGBA', (size, size), (0, 0, 0, 255))
        
        # Paste the cropped part in the center
        # Since we want it to be "all black", we only care about the white logo part 
        # and the black body of the icon.
        # It's better to just use the cropped image and paste it.
        paste_pos = ((size - w) // 2, (size - h) // 2)
        new_img.paste(cropped, paste_pos, cropped) # use alpha if any
        
        # Finally, convert to RGB for the launcher icon
        final_img = new_img.convert('RGB')
        final_img.save(out_path, "PNG")
        print(f"Icon successfully cropped and saved to {out_path}")
    else:
        print("Could not find bounding box, saving original.")
        img.convert('RGB').save(out_path, "PNG")

if __name__ == '__main__':
    src = r'C:\Users\28389\.gemini\antigravity\brain\11589424-88c8-4cd9-97aa-ff056bfa7886\media__1773498799536.png'
    dest = r'c:\Users\28389\Desktop\new\omni_capsule\assets\icon.png'
    crop_icon(src, dest)
