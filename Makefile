.PHONY: validate checksums lint dist clean

validate:
	python3 scripts/validate.py

checksums:
	shasum -a 256 pet.json spritesheet.webp > SHA256SUMS

lint:
	shellcheck -s sh packaging/bin/clippy-pet scripts/install.sh packaging/dist/make-tarballs.sh

dist: validate
	./packaging/dist/make-tarballs.sh

clean:
	rm -rf dist .build
