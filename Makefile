# contracts — araçlar sabit sürümlü Docker image'larıyla çalışır; lokalde Node gerekmez.
# Windows: Git Bash'ten çalıştır (make yoksa: winget install ezwinports.make).

SPECTRAL := stoplight/spectral:6.15.0
PRETTIER := tmknom/prettier:3.2.5

# Git Bash yolları Docker'a giderken bozulmasın (bkz. CLAUDE.md "Bilinen tuzaklar").
export MSYS_NO_PATHCONV := 1
PWD_HOST := $(shell pwd -W 2>/dev/null || pwd)
DOCKER_RUN := docker run --rm -v "$(PWD_HOST):/work" -w /work

SPECS := $(wildcard openapi/*.yaml asyncapi/*.yaml)

.PHONY: help lint fmt

help: ## Hedefleri listele
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-6s %s\n", $$1, $$2}'

lint: ## Spectral ile OpenAPI + AsyncAPI lint (uyarı da hata)
	$(DOCKER_RUN) $(SPECTRAL) lint $(SPECS) --fail-severity=warn

fmt: ## Prettier ile YAML ve Markdown biçimle
	$(DOCKER_RUN) $(PRETTIER) --write "**/*.{yaml,yml,md}"
