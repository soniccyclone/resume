PANDOC_VERSION := 3.5
PANDOC_URL := https://github.com/jgm/pandoc/releases/download/$(PANDOC_VERSION)/pandoc-$(PANDOC_VERSION)-linux-amd64.tar.gz

BIN_DIR := .bin
VENV := .venv
PANDOC := $(BIN_DIR)/pandoc
WEASYPRINT := $(VENV)/bin/weasyprint

TITLE := Nathan Barlow
SUBTITLE := Senior Software Engineer

HTML_OUT := _site/index.html
PDF_HTML := resume.html
PDF_OUT := Nathan_Barlow_Resume.pdf

.PHONY: help setup build html pdf clean distclean

help:
	@echo "Targets:"
	@echo "  setup      install pandoc (.bin/) and weasyprint (.venv/) locally"
	@echo "  html       render web version to $(HTML_OUT)"
	@echo "  pdf        render $(PDF_OUT)"
	@echo "  build      html + pdf"
	@echo "  clean      remove rendered output"
	@echo "  distclean  clean + remove .venv and .bin"

setup: $(PANDOC) $(WEASYPRINT)

$(PANDOC):
	@mkdir -p $(BIN_DIR)
	@echo "[+] downloading pandoc $(PANDOC_VERSION)"
	@curl -sSL $(PANDOC_URL) | tar -xz -C $(BIN_DIR) --strip-components=2 pandoc-$(PANDOC_VERSION)/bin/pandoc
	@$(PANDOC) --version | head -1

$(WEASYPRINT): requirements.txt
	@echo "[+] creating venv and installing weasyprint"
	@python3 -m venv $(VENV)
	@$(VENV)/bin/pip install --quiet --upgrade pip
	@$(VENV)/bin/pip install --quiet -r requirements.txt
	@$(WEASYPRINT) --version

build: html pdf

html: $(HTML_OUT)

$(HTML_OUT): Resume.org style.css $(PANDOC)
	@mkdir -p _site
	$(PANDOC) Resume.org \
		--standalone \
		--css=style.css \
		--metadata title="$(TITLE)" \
		--metadata subtitle="$(SUBTITLE)" \
		-o $(HTML_OUT)
	@cp style.css _site/style.css

pdf: $(PDF_OUT)

$(PDF_HTML): Resume.org style.css $(PANDOC)
	$(PANDOC) Resume.org \
		--standalone \
		--css=style.css \
		--self-contained \
		--metadata title="$(TITLE)" \
		--metadata subtitle="$(SUBTITLE)" \
		-o $(PDF_HTML)

$(PDF_OUT): $(PDF_HTML) $(WEASYPRINT)
	$(WEASYPRINT) $(PDF_HTML) $(PDF_OUT)

clean:
	rm -rf _site $(PDF_HTML) $(PDF_OUT)

distclean: clean
	rm -rf $(VENV) $(BIN_DIR)
