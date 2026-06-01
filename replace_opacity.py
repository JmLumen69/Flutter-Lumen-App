import os

def replace_in_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        original_content = content
        # Replace .withOpacity( with .withValues(alpha: 
        content = content.replace('.withOpacity(', '.withValues(alpha: ')
            
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated {filepath}")
    except (UnicodeDecodeError, PermissionError):
        pass

def main():
    directory = r'c:\flutter\lumen\lib'
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                replace_in_file(filepath)

if __name__ == '__main__':
    main()
