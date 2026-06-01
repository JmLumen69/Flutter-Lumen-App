import os

replacements = {
    '0xFF4FC3F7': '0xFF8B5CF6',
    '0xFF0288D1': '0xFF6D28D9',
    '0xFF0D1B2A': '0xFF0F0A1E',
    '0xFF152535': '0xFF1A1230',
    '0xFF1A3045': '0xFF1E1040',
    '0xFF1A3C5E': '0xFF2D1060',
    '0xFF8B9EB0': '0xFF9D8EC4',
    '0xFF5A6E7F': '0xFF6B5E8F',
    '0xFF0F2132': '0xFF120828',
    '0xFF263C52': '0xFF2D1B69',
    '0xFFF0F4F8': '0xFFF3F0FF',
    '0xFF1E2A38': '0xFF1E1535',
    'Boiser': 'Lumen',
    'boiser': 'lumen'
}

def replace_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    for old, new in replacements.items():
        content = content.replace(old, new)
        
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

def main():
    directory = r'c:\flutter\lumen\lib'
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                replace_in_file(filepath)

if __name__ == '__main__':
    main()
