SHELL := /bin/sh
OFFSET := $(shell package/scripts/stamp_offset.sh)
MD_SRC := $(wildcard docs/*.md)
PDF_OUT := $(patsubst docs/%.md,package/output/%.pdf,$(MD_SRC))

all: pdf site

pdf: $(PDF_OUT)

package/output/%.pdf: docs/%.md package/templates/pandoc-template.tex
	@mkdir -p package/output
	pandoc $< --pdf-engine=pdflatex --template=package/templates/pandoc-template.tex -V offset="$(OFFSET)" -o $@

site:
	@mkdir -p site
	@touch site/index.html

clean:
	rm -rf package/output

.PHONY: all pdf site clean
