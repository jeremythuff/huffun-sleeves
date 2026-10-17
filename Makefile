HUFFUN_SOURCE ?= ../huffun-sleeve-graph-p35
HUFFUN_IMAGE ?= local/huffun:p35
HUFFUN_DEV_IMAGE ?= local/huffun-dev:p35
export HUFFUN_IMAGE HUFFUN_DEV_IMAGE
.PHONY: stage test check verify
stage:
	python3 tools/stage.py '$(HUFFUN_SOURCE)'
test: stage
	$(MAKE) -C '$(HUFFUN_SOURCE)' test TEST='.scratch/sleeves-p35/tests/*.test.ts'
check: stage
	$(MAKE) -C '$(HUFFUN_SOURCE)' sleeve ARGS='check-repo .scratch/sleeves-p35'
verify: test check
	$(MAKE) -C '$(HUFFUN_SOURCE)' verify
