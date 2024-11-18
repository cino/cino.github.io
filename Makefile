post:
	hugo new content/$(shell date +%Y)/$(shell date +%m)-$(shell date +%d)-$(name)/index.md

.PHONY: post
