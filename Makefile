.PHONY: validate checksums lint test dist v1 docs docs-serve clean

export DISABLE_MKDOCS_2_WARNING=true

validate:
	python3 scripts/validate.py

checksums:
	shasum -a 256 pet.json spritesheet.webp > SHA256SUMS

lint:
	shellcheck -s sh packaging/bin/clippy-pet scripts/install.sh packaging/dist/make-tarballs.sh packaging/linux/build.sh packaging/appimage/build.sh packaging/appimage/AppRun tests/install-sh.sh tests/home-manager-doc-example.sh

# Linux only (CI runs it in debian:stable); on macOS: docker run --rm -v "$$PWD":/src -w /src debian:stable sh tests/install-sh.sh
test:
	sh tests/install-sh.sh

dist: validate
	./packaging/dist/make-tarballs.sh

v1: validate
	python3 scripts/build-v1-spritesheet.py dist/spritesheet-v1.webp

docs:
	mkdocs build --strict

docs-serve:
	mkdocs serve

clean:
	rm -rf dist .build site
