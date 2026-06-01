import os

replacements = {
    'Boiser': 'Lumen',
    'boiser': 'lumen'
}

exclude_dirs = {'.git', '.dart_tool', 'build', '.idea', 'windows', 'macos', 'linux'}

def replace_in_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        original_content = content
        for old, new in replacements.items():
            content = content.replace(old, new)
            
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated {filepath}")
    except (UnicodeDecodeError, PermissionError):
        pass

def main():
    directory = r'c:\flutter\lumen'
    for root, dirs, files in os.walk(directory):
        dirs[:] = [d for d in dirs if d not in exclude_dirs]
        for file in files:
            # Skip python scripts or image files if any
            if file.endswith('.py') or file.endswith('.png') or file.endswith('.jpg'):
                continue
            filepath = os.path.join(root, file)
            replace_in_file(filepath)

if __name__ == '__main__':
    main()
