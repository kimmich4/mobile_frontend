import os
import subprocess

test_dir = 'test/viewmodels'
files = [f for f in os.listdir(test_dir) if f.endswith('_test.dart')]

for f in files:
    print(f"Running {f}...")
    path = os.path.join(test_dir, f)
    result = subprocess.run(['flutter', 'test', path], capture_output=True, text=True)
    if result.returncode != 0:
        print(f"FAILED: {f}")
        print(result.stdout)
        print(result.stderr)
    else:
        print(f"PASSED: {f}")
