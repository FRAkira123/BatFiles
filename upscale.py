import sys
import os
import time
from spandrel import ModelLoader
from PIL import Image
import torchvision.transforms.functional as F
import torch
from torch.amp import autocast # Import autocast from torch.amp

# Check for command-line argument
if len(sys.argv) < 2:
    print("Usage: python upscale.py <image_path>")
    sys.exit(1)

input_image_path = sys.argv[1]
if not os.path.exists(input_image_path):
    print(f"Error: Input image not found at {input_image_path}")
    sys.exit(1)

# Determine device
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Using device: {device}")
# Check if autocast is possible
use_amp = device.type == 'cuda'
print(f"Using Automatic Mixed Precision (AMP): {use_amp}")

# Charger le modèle and move to device
model = ModelLoader().load_from_file("E:\\Programme\\Spandrel\\upscale\\4xNomosWebPhoto_RealPLKSR.safetensors")
model.eval()
model.to(device)

# Charger l'image
input_image = Image.open(input_image_path).convert("RGB") # Ensure image is RGB
width, height = input_image.size # Get image dimensions
print(f"Input image loaded: {input_image_path} ({width}x{height})") # Print input info

# Convertir l'image en tenseur, ajouter une dimension batch, and move to device
input_tensor = F.to_tensor(input_image).unsqueeze(0).to(device)

# Effectuer l'upscaling
print("Starting upscaling process...") # Added start message
start_time = time.time() # Record start time
with torch.no_grad(): # Désactiver le calcul du gradient pour l'inférence
    # Use autocast with device type
    with autocast(device_type=device.type, enabled=use_amp):
        output_tensor = model(input_tensor)
end_time = time.time() # Record end time
print("Upscaling finished.") # Added end message
duration = end_time - start_time # Calculate duration
print(f"Upscaling took {duration:.2f} seconds.") # Print duration

# Move output tensor to CPU before converting to PIL image
output_image = F.to_pil_image(output_tensor.cpu().squeeze(0)) # Retirer la dimension batch

# Construct output path
base, ext = os.path.splitext(input_image_path)
output_image_path = f"{base}_upscaled{ext}"

output_image.save(output_image_path)
print(f"Upscaled image saved to: {output_image_path}")

#4xNomosWebPhoto_RealPLKSR.safetensors