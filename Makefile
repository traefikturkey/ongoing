.PHONY: run
SITE_PACKAGES := $(shell pip show pip | grep '^Location' | cut -f2 -d':')
run: $(SITE_PACKAGES)
	python3 app/app.py

$(SITE_PACKAGES): requirements.txt
	pip install -r requirements.txt
	touch requirements.txt