INSTALL_DIR := $(HOME)/.claude/hooks
SCRIPT := src/mirror_plan.sh

deploy:
	cp $(SCRIPT) $(INSTALL_DIR)/mirror_plan.sh
