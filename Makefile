# This Makefile attempts to follow the best-practice set out by Alexis King
# in "An opinionated guide to Haskell in 2018" where we build developer tooling
# as part of the project environment rather than globally. This ensures that
# tools like `ghcmod` are using the same version of GHC as our target runtime to
# get the most relevant results.
#
# https://lexi-lambda.github.io/blog/2018/02/10/an-opinionated-guide-to-haskell-in-2018/
clean:
	@stack clean

PATH_GLOB={app,src,test}
FIND_CMD=fd

# This should only need to be done once per developer machine.
setup: clean
	stack build --no-docker --copy-compiler-tool stylish-haskell hlint apply-refact

_HLINT=hlint {} \;
hlint:
	@fd -e hs . ${PATH_GLOB} -x $(_HLINT)

_STYLISH=stylish-haskell -i {} \;
stylish-haskell:
	@fd -e hs . ${PATH_GLOB} -x $(_STYLISH)

_BRITTANY=brittany --write-mode=inplace {} \;
brittany:
	@fd -e hs . ${PATH_GLOB} -x $(_BRITTANY)

lint-all: stylish-haskell hlint brittany

test:
	@stack test --test-arguments "--color always"
