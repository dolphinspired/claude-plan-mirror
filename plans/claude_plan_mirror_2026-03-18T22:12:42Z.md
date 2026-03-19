# Plan: bark.sh

## Context
User wants a shell script that outputs "bark", following the same pattern as meow.sh.

## Implementation

Create `bark.sh` in the repo root:

```bash
#!/usr/bin/env bash
echo "bark"
```

Make it executable: `chmod +x bark.sh`

## Verification

Run `./bark.sh` — output should be a single line: `bark`.
