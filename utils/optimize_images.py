import os
import shutil
import sys
import argparse
from datetime import datetime
from PIL import Image

def create_backup_dir(root_dir):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = os.path.join(root_dir, 'image_backups', f'backup_{timestamp}')
    if not os.path.exists(backup_path):
        os.makedirs(backup_path)
    return backup_path

def backup_file(file_path, root_dir, backup_dir):
    try:
        # Create relative path structure in backup dir
        rel_path = os.path.relpath(file_path, root_dir)
        dest_path = os.path.join(backup_dir, rel_path)
        
        # Create subdirectories if needed
        os.makedirs(os.path.dirname(dest_path), exist_ok=True)
        
        # Copy file
        shutil.copy2(file_path, dest_path)
        return True
    except Exception as e:
        print(f"❌ Backup failed for {file_path}: {e}")
        return False

def optimize_image(file_path, root_dir, backup_dir, max_size, quality, min_size):
    try:
        original_size = os.path.getsize(file_path)

        # Skip small files
        if original_size < min_size:
            return False, 0, 0, None

        # Backup first!
        if not backup_file(file_path, root_dir, backup_dir):
            return False, 0, 0, "Backup failed"

        with Image.open(file_path) as img:
            # Check if image is valid
            if img.format not in ['PNG', 'JPEG']:
                return False, 0, 0, f"Unsupported format: {img.format}"

            is_png = img.format == 'PNG'

            # Resize if too big (check both width and height)
            max_dimension = max(img.width, img.height)
            if max_dimension > max_size:
                ratio = max_size / max_dimension
                new_size_tuple = (int(img.width * ratio), int(img.height * ratio))
                img = img.resize(new_size_tuple, Image.Resampling.LANCZOS)

            # Convert RGBA to RGB for JPEG (PNG keeps transparency)
            if img.mode == 'RGBA' and not is_png:
                # Create white background
                rgb_img = Image.new('RGB', img.size, (255, 255, 255))
                rgb_img.paste(img, mask=img.split()[3])  # Use alpha channel as mask
                img = rgb_img

            # Save based on format
            if is_png:
                # PNG: lossless compression only
                img.save(file_path, 'PNG', optimize=True)
            else:
                # JPEG: lossy compression with quality setting
                img.save(file_path, 'JPEG', optimize=True, quality=quality)

        new_size = os.path.getsize(file_path)
        saved = original_size - new_size

        if saved > 0:
            reduction_pct = (saved / original_size) * 100
            print(f"✅ {os.path.basename(file_path)}: {original_size/1024:.1f}KB -> {new_size/1024:.1f}KB ({reduction_pct:.1f}% reduction)")
            return True, original_size, new_size, None
        else:
            return False, original_size, new_size, "No size reduction"

    except Exception as e:
        return False, 0, 0, str(e)

def parse_args():
    parser = argparse.ArgumentParser(
        description='Optimize images in assets folder with backup',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  python optimize_images.py                # Use defaults (all assets)
  python optimize_images.py -t encyclopedia  # Optimize assets/encyclopedia only
  python optimize_images.py -t images/etc    # Optimize assets/images/etc only
  python optimize_images.py --quality 70   # Lower quality for more compression
        '''
    )
    parser.add_argument(
        '-t', '--target',
        type=str,
        default=None,
        help='Folder name under assets/ (e.g., "encyclopedia" -> assets/encyclopedia)'
    )
    parser.add_argument(
        '--max-size',
        type=int,
        default=1024,
        help='Maximum width/height in pixels (default: 1024)'
    )
    parser.add_argument(
        '--quality',
        type=int,
        default=75,
        help='JPEG quality 0-100, lower = smaller file (default: 75)'
    )
    parser.add_argument(
        '--min-size',
        type=int,
        default=500 * 1024,
        help='Minimum file size in bytes to optimize (default: 512000 = 500KB)'
    )
    return parser.parse_args()

def main():
    args = parse_args()

    root_dir = os.getcwd()

    # Auto-prefix with 'assets/' if target is specified
    if args.target:
        target_path = os.path.join('assets/images', args.target)
    else:
        target_path = 'assets/images'

    target_dir = os.path.join(root_dir, target_path)

    if not os.path.exists(target_dir):
        print(f"Error: Target directory '{target_dir}' does not exist")
        sys.exit(1)

    print("=" * 60)
    print("  IMAGE OPTIMIZER")
    print("=" * 60)
    print(f"Target Directory: {target_dir}")
    print(f"Settings:")
    print(f"  - Max dimension: {args.max_size}px")
    print(f"  - JPEG quality: {args.quality}")
    print(f"  - Min file size: {args.min_size / 1024:.0f}KB")
    print(f"\nScanning for images...")

    # Create backup directory
    backup_dir = create_backup_dir(root_dir)
    print(f"Backup location: {backup_dir}\n")
    print("-" * 60)

    total_saved = 0
    count = 0
    skipped = 0
    failed_files = []

    for root, dirs, files in os.walk(target_dir):
        # Skip backup folder itself
        if 'image_backups' in root:
            continue

        for file in files:
            if file.lower().endswith(('.png', '.jpg', '.jpeg')):
                file_path = os.path.join(root, file)
                optimized, original, new, error = optimize_image(
                    file_path, root_dir, backup_dir,
                    args.max_size, args.quality, args.min_size
                )

                if optimized:
                    total_saved += (original - new)
                    count += 1
                elif error:
                    failed_files.append((file, error))
                    print(f"⚠️  {file}: {error}")
                else:
                    skipped += 1

    print("-" * 60)
    print("\n✨ OPTIMIZATION COMPLETE!\n")
    print(f"Files optimized: {count}")
    print(f"Files skipped: {skipped} (too small or no reduction)")
    print(f"Total saved: {total_saved / 1024 / 1024:.2f} MB")

    if failed_files:
        print(f"\n⚠️  Failed files: {len(failed_files)}")
        for filename, error in failed_files[:5]:  # Show first 5
            print(f"   - {filename}: {error}")
        if len(failed_files) > 5:
            print(f"   ... and {len(failed_files) - 5} more")

    print(f"\nBackup: {backup_dir}")
    print("=" * 60)

if __name__ == "__main__":
    main()
