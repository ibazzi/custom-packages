#
# Copyright (C) 2018 Alex Xu <ibazzi@qq.com>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bash-completion
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/scop/bash-completion.git
PKG_SOURCE_VERSION:=e209afb2d0c96ee6bfe83da8b2742a8f8e88d372

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/bash-completion
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Command line command completions for the Bash shell
  DEPENDS:=+bash
  URL:=https://github.com/scop/bash-completion
endef

define Package/bash-completion/description
  bash-completion is a collection of command line command completions for the Bash shell,
  collection of helper functions to assist in creating new completions, and set of 
  facilities for loading completions automatically on demand, as well as installing them.
endef

define Package/bash-completion/install
	$(CP) $(PKG_INSTALL_DIR)/* $(1)/
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,bash-completion))
