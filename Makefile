.PHONY: validate checksums

validate:
	python3 scripts/validate.py

checksums:
	shasum -a 256 pet.json spritesheet.webp > SHA256SUMS
