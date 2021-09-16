GOPATH  ?= $(HOME)/go
MCMAKER := $(GOPATH)/bin/mcmaker
DST := ../source-crs
CHK := .chk

GEN_DIRS := $(dir $(wildcard */builder.sh))
GEN_TGTS := $(patsubst %/,$(DST)/%.yaml,$(GEN_DIRS))
CHK_TGTS := $(patsubst %/,$(CHK)/%.diff,$(GEN_DIRS))

.PHONY: all clean force cleanchk check

all: $(GEN_TGTS)

clean:
	rm -rf $(GEN_TGTS) $(CHK)

force: clean all

cleanchk:
	rm -rf $(CHK)

check: cleanchk $(CHK_TGTS)

$(DST)/%.yaml: %/builder.sh %/*
	(cd $(<D); bash $(<F)) >$@

$(CHK)/%.yaml: %/builder.sh %/*
	@[[ -d $(@D) ]] || mkdir -p $(@D)
	(cd $(<D); bash $(<F)) >$@

$(CHK)/%.diff: $(CHK)/%.yaml
	diff -u $(DST)/$(<F) $< >$@

$(MCMAKER):
	go install github.com/lack/mcmaker@v0.0.4
