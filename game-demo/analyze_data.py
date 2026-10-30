with open(r'D:\Android\NTA Project Reverse Engineering\game-demo\data.js', 'r') as f:
    content = f.read()

# Find map-related keys
import re
keys = re.findall(r'"(\w+)":\s*[\[\{]', content)
print('Top-level keys:', keys)

# Find map section
map_match = re.search(r'"map"\s*:\s*\{(.*?)\n\s*\}', content, re.DOTALL)
if map_match:
    print('\nMap section found:')
    print(map_match.group(1)[:2000])

# Count heroes
heroes_match = re.search(r'"heroes"\s*:\s*\[(.*?)\]', content, re.DOTALL)
if heroes_match:
    hero_ids = re.findall(r'"id"\s*:\s*"([^"]+)"', heroes_match.group(1))
    print(f'\nHeroes count: {len(hero_ids)}')
    print('Sample:', hero_ids[:5])

# Check for plot data
plots_match = re.search(r'"plots"\s*:\s*\[(.*?)\]', content, re.DOTALL)
if plots_match:
    print('\nPlots count:', len(re.findall(r'\{', plots_match.group(1))))
    # Show first plot
    first_plot = re.search(r'\{([^}]+)\}', plots_match.group(1))
    if first_plot:
        print('First plot:', first_plot.group(1)[:300])
