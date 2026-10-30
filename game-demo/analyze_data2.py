import re

with open(r'D:\Android\NTA Project Reverse Engineering\game-demo\data.js', 'r') as f:
    content = f.read()

# Find all top-level keys by matching "key": pattern at start of line
lines = content.split('\n')
top_level = []
for line in lines:
    match = re.match(r'^\s*"(\w+)"\s*:', line)
    if match:
        top_level.append(match.group(1))

print('Top-level keys:', top_level)

# Find map section properly
map_start = content.find('"map": {')
if map_start >= 0:
    # Find matching closing brace
    depth = 1
    pos = map_start + len('"map": {')
    while pos < len(content) and depth > 0:
        if content[pos] == '{':
            depth += 1
        elif content[pos] == '}':
            depth -= 1
        pos += 1
    map_section = content[map_start:pos]
    print(f'\nMap section length: {len(map_section)}')
    
    # Find playerCapital
    pc = re.search(r'"playerCapital"\s*:\s*\{([^}]+)\}', map_section)
    if pc:
        print('\nplayerCapital:', pc.group(1))
    
    # Find enemyCapital
    ec = re.search(r'"enemyCapital"\s*:\s*\{([^}]+)\}', map_section)
    if ec:
        print('\nenemyCapital:', ec.group(1))
    
    # Find plots
    plots_match = re.search(r'"plots"\s*:\s*\[(.*?)\]', map_section, re.DOTALL)
    if plots_match:
        plot_count = len(re.findall(r'\{', plots_match.group(1)))
        print(f'\nPlots count: {plot_count}')
        # Show first few plots
        for i, plot in enumerate(re.findall(r'\{[^}]+\}', plots_match.group(1))[:5]):
            print(f'  Plot {i}: {plot[:100]}...')
    else:
        print('\nNo plots found!')

# Find heroes count
heroes_start = content.find('"heroes":')
if heroes_start >= 0:
    heroes_section = content[heroes_start:heroes_start+2000]
    hero_ids = re.findall(r'"id"\s*:\s*"([^"]+)"', heroes_section)
    print(f'\nHeroes found: {len(hero_ids)}')
    print('Sample:', hero_ids[:10])
