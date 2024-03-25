.PHONY: run
SITE_PACKAGES := $(shell pip show pip | grep '^Location' | cut -d' ' -f2-)
run: $(SITE_PACKAGES)
	python3 app/app.py

$(SITE_PACKAGES): requirements.txt
	pip install -r requirements.txt
