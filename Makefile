ZPLUG_ROOT  := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ZSPEC       := $(ZPLUG_ROOT)/bin/zspec
ZSPEC_URL   := https://raw.githubusercontent.com/b4b4r07/zspec/master/bin/zspec
MANPAGE     := $(ZPLUG_ROOT)/doc/man/man1/zplug.1
MANPATH     := /usr/local/share/man/man1
LICENSE_URL := http://b4b4r07.mit-license.org
LICENSE_TXT := $(ZPLUG_ROOT)/doc/LICENSE-MIT.txt

SKIP_FILES := __clone__ __releases__ __install__ __update__ __load__
TEST_FILES := $(shell find $(ZPLUG_ROOT)/test -name *_test.zsh | sort)
SKIP_TESTS := $(foreach f, $(SKIP_FILES), $(shell find $(ZPLUG_ROOT)/test -name $(f)_test.zsh))
MINI_TESTS := $(filter-out $(SKIP_TESTS), $(TEST_FILES))

.PHONY: all install man zspec minitest test license

all:

install: man license
	@cat $(LICENSE_TXT)

man:
	@test -f $(MANPATH)/zplug.1 || cp -v -f $(MANPAGE) $(MANPATH)

zspec:
	@test -f $(ZSPEC) || curl -L $(ZSPEC_URL) -o $(ZSPEC)
	@test -x $(ZSPEC) || chmod 755 $(ZSPEC)

minitest: zspec
	@ZPLUG_ROOT=$(ZPLUG_ROOT) $(ZSPEC) $(MINI_TESTS)

test: zspec
	@ZPLUG_ROOT=$(ZPLUG_ROOT) $(ZSPEC) $(TEST_FILES)

license:
	@curl -fsSL -o $(LICENSE_TXT) $(LICENSE_URL)
