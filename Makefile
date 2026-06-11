.PHONY: check format lint lint-format

check: lint-format lint

format:
	stylua .

lint-format:
	stylua --check .

lint:
	selene .
