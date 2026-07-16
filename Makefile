# Not `bats -r .` — the kit synced into its own .claude/.agents would run the
# same tests again through the symlinks.
test:
	bats -r bin shared domains

.PHONY: test
